import '../../domain/date_utils.dart';
import '../../domain/habit_schedule.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/habit.dart' as domain;
import '../../domain/models/finance_summary.dart';
import '../../domain/models/habit_log.dart';
import '../../domain/models/spending_breakdown.dart';
import '../database/app_database.dart' as db;
import 'mappers.dart';

class FinanceRepository {
  FinanceRepository(this._db);

  final db.AppDatabase _db;

  /// Rangkuman keuangan untuk semua habit bersatuan rupiah dalam rentang
  /// [start, endInclusive] (kedua ujung termasuk). Habit `atMost` (batas
  /// pengeluaran) dihitung sebagai pengeluaran & budget; habit `atLeast`
  /// (mis. target tabungan) dihitung sebagai setoran tabungan.
  ///
  /// [excludeHabitIds] — habit yang sedang menunggu penghapusan permanen dari
  /// Home (deferred delete: kartu langsung hilang dari list Home lewat
  /// `pendingDeleteHabitIdsProvider`, tapi baris DB baru benar-benar terhapus
  /// beberapa detik kemudian setelah snackbar undo hilang). Dikecualikan di
  /// sini juga supaya halaman Finance ikut langsung "melupakan" habit itu,
  /// bukan menunggu delete fisik selesai (lihat `finance_providers.dart`).
  Future<FinanceSummary> computeSummary(
    DateTime start,
    DateTime endInclusive, {
    Set<int> excludeHabitIds = const {},
    FinanceTrendBucket trendBucket = FinanceTrendBucket.day,
  }) async {
    final habits = (await _db.habitDao.getAll())
        .map(mapHabit)
        .where((h) => h.isRupiah && !excludeHabitIds.contains(h.id))
        .toList();
    if (habits.isEmpty) return FinanceSummary.empty;

    final habitIds = habits.map((h) => h.id).toSet();
    final logs = (await _db.habitLogDao.getLogsInRange(start, endInclusive))
        .map(mapHabitLog)
        .where((l) => habitIds.contains(l.habitId))
        .toList();

    final logsByHabit = <int, List<HabitLog>>{};
    for (final log in logs) {
      logsByHabit.putIfAbsent(log.habitId, () => []).add(log);
    }

    final breakdownEntries =
        (await _db.habitSpendingBreakdownDao.getEntriesInRange(start, endInclusive))
            .map(mapSpendingBreakdownEntry)
            .whereType<SpendingBreakdownEntry>()
            .where((e) => habitIds.contains(e.habitId))
            .toList();
    final breakdownByHabit = <int, List<SpendingBreakdownEntry>>{};
    for (final entry in breakdownEntries) {
      breakdownByHabit.putIfAbsent(entry.habitId, () => []).add(entry);
    }

    var totalExpense = 0;
    var totalBudget = 0;
    var totalSavingsDeposit = 0;
    var totalSavingsTarget = 0;
    final habitStats = <FinanceHabitStat>[];

    for (final habit in habits) {
      final habitLogs = logsByHabit[habit.id] ?? const <HabitLog>[];
      final totalValue =
          habitLogs.fold<int>(0, (sum, l) => sum + l.progressValue);

      // Target dihitung dari berapa banyak instance goalPeriod habit ini
      // sendiri (hari/minggu/bulan) yang tercakup dalam jendela [start,
      // endInclusive] — bukan dari `habitLogs.length` (jumlah hari yang
      // kebetulan ada log). Itu penting supaya habit weekly/monthly dilihat
      // benar walau jendela tampilan Finance (Daily/Weekly/Monthly toggle)
      // tidak sama dengan goalPeriod-nya sendiri — mis. habit weekly dilihat
      // dalam tampilan Monthly seharusnya dibandingkan ke goalValue dikali
      // jumlah minggu dalam bulan itu, bukan dikali jumlah hari yang dicatat.
      // Habit daily dengan override weekend (`goalValueWeekend`) punya target
      // yang beda per hari — dijumlahkan hari demi hari lewat `goalValueFor`
      // alih-alih `goalValue * periodCount` yang mengasumsikan nilai sama
      // setiap hari. `weekly`/`monthly` tidak pernah punya override ini,
      // jadi tetap pakai perkalian lama.
      // For savings habits (`atLeast`, e.g. a Nabung/Save Money target), the
      // target shown alongside "amount saved so far" must only cover days
      // that have actually happened — a weekly/monthly window still spans
      // days in the future relative to "today", and projecting the full
      // period's target made an in-progress week/month look like it needed
      // far more saved than what's realistically achievable yet (bug: a
      // just-started weekly target showed the FULL week's total on day 1).
      // Spending budgets (`atMost`) intentionally keep the full-period
      // target as-is — that's a fixed cap to spend against, and
      // `FinanceSummary.paceAt` already does its own separate elapsed-vs-
      // spent pacing comparison for those.
      final targetEnd = habit.goalDirection == GoalDirection.atLeast
          ? _clampToElapsed(endInclusive)
          : endInclusive;
      final totalTarget = habit.goalPeriod == GoalPeriod.daily
          ? _dailyTargetSum(habit, start, targetEnd)
          : habit.goalValue * countPeriodsOverlapping(habit.goalPeriod, start, targetEnd);

      // "Achieved" juga dihitung per-instance periode (jumlah progress di
      // dalam periode itu dibandingkan ke goalValue), bukan per hari log —
      // satu hari log sendirian jarang mencapai/melanggar target penuh satu
      // minggu/bulan, jadi menilai per hari akan salah menghitung.
      final sumByPeriod = <DateTime, int>{};
      for (final log in habitLogs) {
        final key = periodBoundsFor(habit.goalPeriod, log.date).$1;
        sumByPeriod[key] = (sumByPeriod[key] ?? 0) + log.progressValue;
      }
      final loggedPeriods = sumByPeriod.length;
      final achievedPeriods = sumByPeriod.entries
          .where((e) => habit.isAchieved(e.value, date: e.key))
          .length;

      if (habit.goalDirection == GoalDirection.atMost) {
        totalExpense += totalValue;
        totalBudget += totalTarget;
      } else {
        totalSavingsDeposit += totalValue;
        totalSavingsTarget += totalTarget;
      }

      habitStats.add(FinanceHabitStat(
        habit: habit,
        totalValue: totalValue,
        totalTarget: totalTarget,
        loggedPeriods: loggedPeriods,
        achievedPeriods: achievedPeriods,
        breakdown: _aggregateBreakdown(breakdownByHabit[habit.id] ?? const []),
      ));
    }
    habitStats.sort((a, b) => b.totalValue.compareTo(a.totalValue));

    final expenseHabitIds = habits
        .where((h) => h.goalDirection == GoalDirection.atMost)
        .map((h) => h.id)
        .toSet();
    final trendByDate = <DateTime, int>{};
    for (final log in logs) {
      if (!expenseHabitIds.contains(log.habitId)) continue;
      final day = DateTime(log.date.year, log.date.month, log.date.day);
      trendByDate[day] = (trendByDate[day] ?? 0) + log.progressValue;
    }
    final dailyTrend = trendBucket == FinanceTrendBucket.week
        ? _bucketTrendByWeek(trendByDate)
        : (trendByDate.entries
                .map((e) => FinanceDayPoint(date: e.key, totalExpense: e.value))
                .toList()
              ..sort((a, b) => a.date.compareTo(b.date)));

    final categoryBreakdown = _aggregateBreakdown(breakdownEntries);

    return FinanceSummary(
      periodStart: start,
      periodEndInclusive: endInclusive,
      totalExpense: totalExpense,
      totalBudget: totalBudget,
      totalSavingsDeposit: totalSavingsDeposit,
      totalSavingsTarget: totalSavingsTarget,
      habitStats: habitStats,
      dailyTrend: dailyTrend,
      categoryBreakdown: categoryBreakdown,
      currencyPrefix: habits.first.currencyPrefix,
    );
  }

  /// Groups [trendByDate] (day → total expense) into calendar-week buckets
  /// (Monday-start), each point's `date` = the bucket's Monday (clamped to
  /// not precede the first day actually present) and `bucketEndInclusive` =
  /// the last day with data in that week — used for the Monthly-tab trend
  /// chart so it shows ~4-5 bars instead of ~30 daily ones.
  List<FinanceDayPoint> _bucketTrendByWeek(Map<DateTime, int> trendByDate) {
    if (trendByDate.isEmpty) return const [];
    final sortedDays = trendByDate.keys.toList()..sort();
    final byWeekStart = <DateTime, List<DateTime>>{};
    for (final day in sortedDays) {
      // ISO week starts Monday: weekday 1=Mon..7=Sun.
      final weekStart = day.subtract(Duration(days: day.weekday - 1));
      byWeekStart.putIfAbsent(weekStart, () => []).add(day);
    }
    final points = byWeekStart.entries.map((e) {
      final daysInWeek = e.value;
      final total = daysInWeek.fold<int>(0, (sum, d) => sum + (trendByDate[d] ?? 0));
      return FinanceDayPoint(
        date: daysInWeek.first,
        bucketEndInclusive: daysInWeek.last,
        totalExpense: total,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  /// Clamps [end] to today when it's still in the future — leaves past
  /// periods (fully-elapsed [end]) untouched, so navigating to a previous
  /// week/month still shows that period's real, complete target.
  DateTime _clampToElapsed(DateTime end) {
    final now = today();
    return end.isAfter(now) ? now : end;
  }

  /// Jumlah target [habit] (daily) untuk tiap hari dalam [start, end] yang
  /// habit-nya aktif ditagih (`isHabitActiveOn`), pakai goalValue efektif
  /// hari itu (`goalValueFor` — beda kalau ada override weekend).
  int _dailyTargetSum(domain.Habit habit, DateTime start, DateTime end) {
    var sum = 0;
    for (var day = dateOnly(start); !day.isAfter(dateOnly(end)); day = day.add(const Duration(days: 1))) {
      if (isHabitActiveOn(habit, day)) sum += habit.goalValueFor(day);
    }
    return sum;
  }

  /// Sums [entries] by (category, label) — entries with no sub-category
  /// detail (label null/empty) under the same category collapse into one
  /// row, while distinct sub-category labels ("Bensin" vs "Parkir") stay
  /// separate rows.
  List<FinanceSpendingCategoryStat> _aggregateBreakdown(
    List<SpendingBreakdownEntry> entries,
  ) {
    if (entries.isEmpty) return const [];
    final totals = <String, FinanceSpendingCategoryStat>{};
    for (final entry in entries) {
      final key = '${entry.category.name}::${entry.label ?? ''}';
      final existing = totals[key];
      totals[key] = FinanceSpendingCategoryStat(
        category: entry.category,
        label: entry.label,
        totalAmount: (existing?.totalAmount ?? 0) + entry.amount,
      );
    }
    final stats = totals.values.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return stats;
  }
}

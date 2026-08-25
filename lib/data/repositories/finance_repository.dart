import '../../domain/habit_schedule.dart';
import '../../domain/models/enums.dart';
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
  Future<FinanceSummary> computeSummary(
    DateTime start,
    DateTime endInclusive,
  ) async {
    final habits = (await _db.habitDao.getAll())
        .map(mapHabit)
        .where((h) => h.isRupiah)
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
      final periodCount = countPeriodsOverlapping(habit.goalPeriod, start, endInclusive);
      final totalTarget = habit.goalValue * periodCount;

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
      final achievedPeriods =
          sumByPeriod.values.where(habit.isAchieved).length;

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
    final dailyTrend = trendByDate.entries
        .map((e) => FinanceDayPoint(date: e.key, totalExpense: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return FinanceSummary(
      periodStart: start,
      periodEndInclusive: endInclusive,
      totalExpense: totalExpense,
      totalBudget: totalBudget,
      totalSavingsDeposit: totalSavingsDeposit,
      totalSavingsTarget: totalSavingsTarget,
      habitStats: habitStats,
      dailyTrend: dailyTrend,
    );
  }

  /// Sums [entries] by (category, label) — template categories (dailyNeeds/
  /// urgent/health) collapse into one row each since [label] is always null
  /// for them, while distinct custom labels ("Bensin" vs "Parkir") stay
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

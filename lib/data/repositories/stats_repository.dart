import '../../domain/habit_schedule.dart';
import '../../domain/models/category.dart';
import '../../domain/models/dashboard_summary.dart';
import '../../domain/models/day_summary.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_log.dart';
import '../database/app_database.dart' as db;
import 'mappers.dart';

class StatsRepository {
  StatsRepository(this._db);

  final db.AppDatabase _db;

  /// Habit finance (mis. batas pengeluaran) sengaja dikecualikan dari semua
  /// agregasi Dashboard — datanya cuma relevan/ditampilkan di halaman
  /// Keuangan supaya tidak membingungkan campur dengan habit non-finance.
  Future<List<Habit>> _dashboardEligibleHabits() async {
    final allHabits = (await _db.habitDao.getAll()).map(mapHabit).toList();
    final categories =
        (await _db.categoryDao.getAllActive()).map(mapCategory).toList();
    final categoryById = {for (final c in categories) c.id: c};
    return allHabits.where((h) {
      final category = categoryById[h.categoryId];
      return category == null || !isFinanceCategory(category);
    }).toList();
  }

  /// Total progressValue habit [habitId] dalam periode goal-nya sendiri
  /// (lihat [periodBoundsFor]) yang memuat tanggal dengan kunci [periodKey],
  /// dijumlahkan dari semua log dalam periode itu — bukan cuma log satu hari
  /// — supaya progress habit weekly/monthly tetap "nyambung" ketika hari
  /// berganti, bukannya balik ke 0 (sama seperti `progress_providers.dart`).
  Map<String, int> _periodProgressByHabit(List<Habit> habits, List<HabitLog> logs) {
    final habitById = {for (final h in habits) h.id: h};
    final totals = <String, int>{};
    for (final log in logs) {
      final habit = habitById[log.habitId];
      if (habit == null) continue;
      final periodStart = periodBoundsFor(habit.goalPeriod, log.date).$1;
      final key = _periodKey(log.habitId, periodStart);
      totals[key] = (totals[key] ?? 0) + log.progressValue;
    }
    return totals;
  }

  String _periodKey(int habitId, DateTime periodStart) =>
      '${habitId}_${periodStart.year}-${periodStart.month}-${periodStart.day}';

  /// [habitIds] kosong berarti tanpa filter (semua habit ikut dihitung) —
  /// non-kosong membatasi agregasi cuma ke habit yang id-nya ada di set itu
  /// (dipakai filter icon habit di layar Dashboard gabungan).
  Future<DashboardSummary> computeDashboard({Set<int> habitIds = const {}}) async {
    final allHabits = await _dashboardEligibleHabits();
    final habits = habitIds.isEmpty
        ? allHabits
        : allHabits.where((h) => habitIds.contains(h.id)).toList();
    final categories =
        (await _db.categoryDao.getAllActive()).map(mapCategory).toList();
    final logs = (await _db.habitLogDao.getAllLogs()).map(mapHabitLog).toList();

    if (habits.isEmpty || logs.isEmpty) return DashboardSummary.empty;

    final habitById = {for (final h in habits) h.id: h};
    final trackedDays = <DateTime>{};
    var totalLogs = 0;
    var doneLogs = 0.0;

    final habitTotals = <int, (int total, double done)>{};
    final monthTotals = <DateTime, (int total, double done)>{};

    for (final log in logs) {
      final habit = habitById[log.habitId];
      if (habit == null) continue;

      final credit = habit.progressCredit(log.progressValue);

      trackedDays.add(DateTime(log.date.year, log.date.month, log.date.day));
      totalLogs++;
      doneLogs += credit;

      final habitPrev = habitTotals[habit.id] ?? (0, 0.0);
      habitTotals[habit.id] = (habitPrev.$1 + 1, habitPrev.$2 + credit);

      final monthKey = DateTime(log.date.year, log.date.month);
      final monthPrev = monthTotals[monthKey] ?? (0, 0.0);
      monthTotals[monthKey] = (monthPrev.$1 + 1, monthPrev.$2 + credit);
    }

    final habitStats = habitTotals.entries
        .map((e) => HabitStat(
              habit: habitById[e.key]!,
              totalLogs: e.value.$1,
              doneLogs: e.value.$2,
            ))
        .toList()
      ..sort((a, b) => b.successRate.compareTo(a.successRate));

    final categoryById = {for (final c in categories) c.id: c};

    // Rata-rata per kategori dihitung dari successRate MASING-MASING habit
    // (unweighted per habit), bukan dijumlah dari log mentah — kalau tidak,
    // 1 habit yang sudah 100% tapi habit lain di kategori sama belum pernah
    // dilog sama sekali bisa membuat seluruh kategori tampak 100% padahal
    // habit-habit lain itu belum tersentuh.
    final categoryHabitRates = <int, List<double>>{};
    for (final stat in habitStats) {
      categoryHabitRates
          .putIfAbsent(stat.habit.categoryId, () => [])
          .add(stat.successRate);
    }
    final categoryStats = categoryHabitRates.entries
        .where((e) => categoryById.containsKey(e.key))
        .map((e) {
          final rates = e.value;
          final avg = rates.reduce((a, b) => a + b) / rates.length;
          return CategoryStat(
            category: categoryById[e.key]!,
            totalLogs: rates.length,
            doneLogs: avg * rates.length,
          );
        })
        .toList()
      ..sort((a, b) => b.successRate.compareTo(a.successRate));

    final monthlyStats = monthTotals.entries
        .map((e) => MonthlyStat(
              month: e.key,
              totalLogs: e.value.$1,
              doneLogs: e.value.$2,
            ))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    return DashboardSummary(
      totalDaysTracked: trackedDays.length,
      totalLogs: totalLogs,
      doneLogs: doneLogs,
      categoryStats: categoryStats,
      habitStats: habitStats,
      monthlyStats: monthlyStats,
    );
  }

  /// Ringkasan tiap hari dalam bulan yang memuat [monthAnchor], dipakai untuk
  /// gradasi warna kalender Dashboard. Sama seperti [computeDashboard],
  /// [habitIds] kosong berarti tanpa filter.
  Future<List<DaySummary>> computeMonthSummaries(
    DateTime monthAnchor, {
    Set<int> habitIds = const {},
  }) async {
    final allHabits = await _dashboardEligibleHabits();
    final habits = habitIds.isEmpty
        ? allHabits
        : allHabits.where((h) => habitIds.contains(h.id)).toList();
    final firstDay = DateTime(monthAnchor.year, monthAnchor.month, 1);
    final lastDay = DateTime(monthAnchor.year, monthAnchor.month + 1, 0);
    // Diperlebar 6 hari di tiap sisi supaya minggu yang menjorok ke bulan
    // sebelum/sesudahnya tetap terhitung penuh untuk habit weekly (lihat
    // [_periodProgressByHabit]).
    final logs = (await _db.habitLogDao.getLogsInRange(
      firstDay.subtract(const Duration(days: 6)),
      lastDay.add(const Duration(days: 6)),
    ))
        .map(mapHabitLog)
        .toList();
    final periodProgress = _periodProgressByHabit(habits, logs);

    final summaries = <DaySummary>[];
    for (var day = firstDay;
        !day.isAfter(lastDay);
        day = day.add(const Duration(days: 1))) {
      var total = 0;
      var done = 0.0;
      for (final habit in habits) {
        if (!isHabitActiveOn(habit, day)) continue;
        total++;
        final periodStart = periodBoundsFor(habit.goalPeriod, day).$1;
        final sum = periodProgress[_periodKey(habit.id, periodStart)] ?? 0;
        done += habit.progressCredit(sum);
      }
      summaries.add(DaySummary(date: day, totalCount: total, doneCount: done));
    }
    return summaries;
  }

  Future<DaySummary> computeDaySummary(DateTime date) async {
    final habits = await _dashboardEligibleHabits();
    final (weekStart, weekEnd) = periodBoundsFor(GoalPeriod.weekly, date);
    final (monthStart, monthEnd) = periodBoundsFor(GoalPeriod.monthly, date);
    final rangeStart = weekStart.isBefore(monthStart) ? weekStart : monthStart;
    final rangeEnd = weekEnd.isAfter(monthEnd) ? weekEnd : monthEnd;
    final logs = (await _db.habitLogDao.getLogsInRange(rangeStart, rangeEnd))
        .map(mapHabitLog)
        .toList();
    final periodProgress = _periodProgressByHabit(habits, logs);

    var total = 0;
    var done = 0.0;
    for (final habit in habits) {
      if (!isHabitActiveOn(habit, date)) continue;
      total++;
      final periodStart = periodBoundsFor(habit.goalPeriod, date).$1;
      final sum = periodProgress[_periodKey(habit.id, periodStart)] ?? 0;
      done += habit.progressCredit(sum);
    }
    return DaySummary(date: date, totalCount: total, doneCount: done);
  }
}

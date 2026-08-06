import '../../domain/habit_schedule.dart';
import '../../domain/models/dashboard_summary.dart';
import '../../domain/models/day_summary.dart';
import '../database/app_database.dart' as db;
import 'mappers.dart';

class StatsRepository {
  StatsRepository(this._db);

  final db.AppDatabase _db;

  /// [habitIds] kosong berarti tanpa filter (semua habit ikut dihitung) —
  /// non-kosong membatasi agregasi cuma ke habit yang id-nya ada di set itu
  /// (dipakai filter icon habit di layar Dashboard gabungan).
  Future<DashboardSummary> computeDashboard({Set<int> habitIds = const {}}) async {
    final allHabits = (await _db.habitDao.getAll()).map(mapHabit).toList();
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
    var doneLogs = 0;

    final habitTotals = <int, (int total, int done)>{};
    final categoryTotals = <int, (int total, int done)>{};
    final monthTotals = <DateTime, (int total, int done)>{};

    for (final log in logs) {
      final habit = habitById[log.habitId];
      if (habit == null) continue;

      trackedDays.add(DateTime(log.date.year, log.date.month, log.date.day));
      totalLogs++;
      if (log.isDone) doneLogs++;

      final habitPrev = habitTotals[habit.id] ?? (0, 0);
      habitTotals[habit.id] =
          (habitPrev.$1 + 1, habitPrev.$2 + (log.isDone ? 1 : 0));

      final catPrev = categoryTotals[habit.categoryId] ?? (0, 0);
      categoryTotals[habit.categoryId] =
          (catPrev.$1 + 1, catPrev.$2 + (log.isDone ? 1 : 0));

      final monthKey = DateTime(log.date.year, log.date.month);
      final monthPrev = monthTotals[monthKey] ?? (0, 0);
      monthTotals[monthKey] =
          (monthPrev.$1 + 1, monthPrev.$2 + (log.isDone ? 1 : 0));
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
    final categoryStats = categoryTotals.entries
        .where((e) => categoryById.containsKey(e.key))
        .map((e) => CategoryStat(
              category: categoryById[e.key]!,
              totalLogs: e.value.$1,
              doneLogs: e.value.$2,
            ))
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
    final allHabits = (await _db.habitDao.getAll()).map(mapHabit).toList();
    final habits = habitIds.isEmpty
        ? allHabits
        : allHabits.where((h) => habitIds.contains(h.id)).toList();
    final firstDay = DateTime(monthAnchor.year, monthAnchor.month, 1);
    final lastDay = DateTime(monthAnchor.year, monthAnchor.month + 1, 0);
    final logs = (await _db.habitLogDao.getLogsInRange(firstDay, lastDay))
        .map(mapHabitLog)
        .toList();

    final logByHabitDate = {
      for (final log in logs)
        '${log.habitId}_${log.date.year}-${log.date.month}-${log.date.day}':
            log,
    };

    final summaries = <DaySummary>[];
    for (var day = firstDay;
        !day.isAfter(lastDay);
        day = day.add(const Duration(days: 1))) {
      var total = 0;
      var done = 0;
      for (final habit in habits) {
        if (!isHabitActiveOn(habit, day)) continue;
        total++;
        final key = '${habit.id}_${day.year}-${day.month}-${day.day}';
        final log = logByHabitDate[key];
        if (log != null && log.isDone) done++;
      }
      summaries.add(DaySummary(date: day, totalCount: total, doneCount: done));
    }
    return summaries;
  }

  Future<DaySummary> computeDaySummary(DateTime date) async {
    final habits = (await _db.habitDao.getAll()).map(mapHabit).toList();
    final logs =
        (await _db.habitLogDao.getLogsForDate(date)).map(mapHabitLog).toList();
    final logByHabit = {for (final log in logs) log.habitId: log};

    var total = 0;
    var done = 0;
    for (final habit in habits) {
      if (!isHabitActiveOn(habit, date)) continue;
      total++;
      final log = logByHabit[habit.id];
      if (log != null && log.isDone) done++;
    }
    return DaySummary(date: date, totalCount: total, doneCount: done);
  }
}

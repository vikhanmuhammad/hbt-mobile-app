import '../../domain/models/enums.dart';
import '../../domain/models/finance_summary.dart';
import '../../domain/models/habit_log.dart';
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

    var totalExpense = 0;
    var totalBudget = 0;
    var totalSavingsDeposit = 0;
    final habitStats = <FinanceHabitStat>[];

    for (final habit in habits) {
      final habitLogs = logsByHabit[habit.id] ?? const <HabitLog>[];
      final totalValue =
          habitLogs.fold<int>(0, (sum, l) => sum + l.progressValue);
      final achievedDays =
          habitLogs.where((l) => habit.isAchieved(l.progressValue)).length;
      final totalTarget = habit.goalValue * habitLogs.length;

      if (habit.goalDirection == GoalDirection.atMost) {
        totalExpense += totalValue;
        totalBudget += totalTarget;
      } else {
        totalSavingsDeposit += totalValue;
      }

      habitStats.add(FinanceHabitStat(
        habit: habit,
        totalValue: totalValue,
        totalTarget: totalTarget,
        loggedDays: habitLogs.length,
        achievedDays: achievedDays,
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
      habitStats: habitStats,
      dailyTrend: dailyTrend,
    );
  }
}

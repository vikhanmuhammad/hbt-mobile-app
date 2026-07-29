import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'habit_log_dao.g.dart';

@DriftAccessor(tables: [HabitLogs])
class HabitLogDao extends DatabaseAccessor<AppDatabase>
    with _$HabitLogDaoMixin {
  HabitLogDao(super.db);

  Future<List<HabitLog>> getAllLogs() => select(habitLogs).get();

  Stream<List<HabitLog>> watchLogsForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return (select(habitLogs)..where((l) => l.date.equals(day))).watch();
  }

  Future<List<HabitLog>> getLogsForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return (select(habitLogs)..where((l) => l.date.equals(day))).get();
  }

  Future<List<HabitLog>> getLogsInRange(DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    return (select(habitLogs)
          ..where((l) =>
              l.date.isBiggerOrEqualValue(startDay) &
              l.date.isSmallerOrEqualValue(endDay)))
        .get();
  }

  Future<List<HabitLog>> getLogsForHabit(int habitId) {
    return (select(habitLogs)..where((l) => l.habitId.equals(habitId))).get();
  }

  Future<HabitLog?> getLog(int habitId, DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return (select(habitLogs)
          ..where((l) => l.habitId.equals(habitId) & l.date.equals(day)))
        .getSingleOrNull();
  }

  /// Set nilai progress untuk habit pada tanggal tertentu. `isDone` dihitung
  /// otomatis oleh caller (progressValue >= goalValue) sebelum dipanggil.
  Future<void> upsertProgress({
    required int habitId,
    required DateTime date,
    required int progressValue,
    required bool isDone,
  }) async {
    final day = DateTime(date.year, date.month, date.day);
    await into(habitLogs).insertOnConflictUpdate(
      HabitLogsCompanion.insert(
        habitId: habitId,
        date: day,
        progressValue: Value(progressValue),
        isDone: Value(isDone),
      ),
    );
  }

  Future<void> deleteLogsForHabit(int habitId) async {
    await (delete(habitLogs)..where((l) => l.habitId.equals(habitId))).go();
  }
}

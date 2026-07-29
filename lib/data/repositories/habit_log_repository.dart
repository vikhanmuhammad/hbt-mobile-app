import '../../domain/models/habit.dart';
import '../../domain/models/habit_log.dart';
import '../database/app_database.dart' as db;
import 'mappers.dart';

class HabitLogRepository {
  HabitLogRepository(this._db);

  final db.AppDatabase _db;

  Stream<List<HabitLog>> watchLogsForDate(DateTime date) {
    return _db.habitLogDao
        .watchLogsForDate(date)
        .map((rows) => rows.map(mapHabitLog).toList());
  }

  Future<List<HabitLog>> getLogsForDate(DateTime date) async {
    final rows = await _db.habitLogDao.getLogsForDate(date);
    return rows.map(mapHabitLog).toList();
  }

  Future<List<HabitLog>> getLogsInRange(DateTime start, DateTime end) async {
    final rows = await _db.habitLogDao.getLogsInRange(start, end);
    return rows.map(mapHabitLog).toList();
  }

  Future<List<HabitLog>> getLogsForHabit(int habitId) async {
    final rows = await _db.habitLogDao.getLogsForHabit(habitId);
    return rows.map(mapHabitLog).toList();
  }

  Future<HabitLog?> getLog(int habitId, DateTime date) async {
    final row = await _db.habitLogDao.getLog(habitId, date);
    return row == null ? null : mapHabitLog(row);
  }

  /// Set progress mutlak untuk habit pada tanggal tertentu. `isDone` dihitung
  /// otomatis: progressValue >= goalValue (CLAUDE.md §4).
  Future<void> setProgress({
    required Habit habit,
    required DateTime date,
    required int progressValue,
  }) async {
    final clamped = progressValue < 0 ? 0 : progressValue;
    await _db.habitLogDao.upsertProgress(
      habitId: habit.id,
      date: date,
      progressValue: clamped,
      isDone: clamped >= habit.goalValue,
    );
  }

  /// Toggle cepat untuk habit dengan goalValue 1 (checklist biasa).
  Future<void> toggleDone({
    required Habit habit,
    required DateTime date,
    required bool currentlyDone,
  }) async {
    await setProgress(
      habit: habit,
      date: date,
      progressValue: currentlyDone ? 0 : habit.goalValue,
    );
  }

  Future<void> incrementProgress({
    required Habit habit,
    required DateTime date,
    required int currentValue,
    int step = 1,
  }) async {
    await setProgress(
      habit: habit,
      date: date,
      progressValue: currentValue + step,
    );
  }
}

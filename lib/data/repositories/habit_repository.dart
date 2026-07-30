import 'package:drift/drift.dart' show Value;

import '../../domain/models/enums.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/task_days.dart';
import '../database/app_database.dart' as db;
import 'mappers.dart';

class HabitRepository {
  HabitRepository(this._db);

  final db.AppDatabase _db;

  Stream<List<Habit>> watchByCategory(int categoryId) {
    return _db.habitDao
        .watchByCategory(categoryId)
        .map((rows) => rows.map(mapHabit).toList());
  }

  Stream<List<Habit>> watchAllActive() {
    return _db.habitDao
        .watchAllActive()
        .map((rows) => rows.map(mapHabit).toList());
  }

  Future<List<Habit>> getAllActive() async {
    final rows = await _db.habitDao.getAllActive();
    return rows.map(mapHabit).toList();
  }

  Future<List<Habit>> getAll() async {
    final rows = await _db.habitDao.getAll();
    return rows.map(mapHabit).toList();
  }

  Future<Habit?> getById(int id) async {
    final row = await _db.habitDao.getById(id);
    return row == null ? null : mapHabit(row);
  }

  Future<int> createHabit({
    required int categoryId,
    required String name,
    String? description,
    required GoalPeriod goalPeriod,
    required int goalValue,
    String goalUnit = 'x',
    required List<String> taskDays,
    required TimeRange timeRange,
    required bool reminderEnabled,
    String? reminderTime,
    required DateTime startDate,
    DateTime? endDate,
  }) {
    return _db.habitDao.insertHabit(
      db.HabitsCompanion.insert(
        categoryId: categoryId,
        name: name,
        description: Value(description),
        goalPeriod: goalPeriod.name,
        goalValue: Value(goalValue),
        goalUnit: Value(goalUnit),
        taskDays: TaskDays.encode(taskDays),
        timeRange: Value(timeRange.name),
        reminderEnabled: Value(reminderEnabled),
        reminderTime: Value(reminderTime),
        startDate: startDate,
        endDate: Value(endDate),
      ),
    );
  }

  Future<void> updateHabit(Habit habit) async {
    await _db.habitDao.updateHabit(
      db.HabitsCompanion(
        id: Value(habit.id),
        categoryId: Value(habit.categoryId),
        name: Value(habit.name),
        description: Value(habit.description),
        goalPeriod: Value(habit.goalPeriod.name),
        goalValue: Value(habit.goalValue),
        goalUnit: Value(habit.goalUnit),
        taskDays: Value(TaskDays.encode(habit.taskDays)),
        timeRange: Value(habit.timeRange.name),
        reminderEnabled: Value(habit.reminderEnabled),
        reminderTime: Value(habit.reminderTime),
        startDate: Value(habit.startDate),
        endDate: Value(habit.endDate),
        isActive: Value(habit.isActive),
        createdAt: Value(habit.createdAt),
      ),
    );
  }

  Future<void> setActive(int habitId, bool isActive) =>
      _db.habitDao.setActive(habitId, isActive);

  Future<void> deleteHabit(int habitId) async {
    await _db.habitLogDao.deleteLogsForHabit(habitId);
    await _db.habitDao.deleteHabit(habitId);
  }

  /// Hapus semua kategori, habit, dan riwayat progress. Dipakai untuk reset
  /// demo onboarding di Settings — pastikan notifikasi terjadwal sudah
  /// dibatalkan dulu di sisi caller sebelum memanggil ini.
  Future<void> deleteAllData() => _db.clearAllData();
}

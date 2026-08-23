import 'package:drift/drift.dart' show Value;

import '../../domain/models/enums.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_template.dart';
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
    String? nameId,
    String? description,
    String? icon,
    required GoalPeriod goalPeriod,
    required int goalValue,
    String goalUnit = 'x',
    GoalDirection goalDirection = GoalDirection.atLeast,
    required List<String> taskDays,
    required TimeRange timeRange,
    required bool reminderEnabled,
    String? reminderTime,
    required DateTime startDate,
    DateTime? endDate,
    int sortOrder = 0,
    bool isCustom = true,
    String? templateKey,
  }) {
    return _db.habitDao.insertHabit(
      db.HabitsCompanion.insert(
        categoryId: categoryId,
        name: name,
        nameId: Value(nameId),
        description: Value(description),
        icon: Value(icon),
        goalPeriod: goalPeriod.name,
        goalValue: Value(goalValue),
        goalUnit: Value(goalUnit),
        goalDirection: Value(goalDirection.name),
        taskDays: TaskDays.encode(taskDays),
        timeRange: Value(timeRange.name),
        reminderEnabled: Value(reminderEnabled),
        reminderTime: Value(reminderTime),
        startDate: startDate,
        endDate: Value(endDate),
        sortOrder: Value(sortOrder),
        isCustom: Value(isCustom),
        templateKey: Value(templateKey),
      ),
    );
  }

  Future<void> updateHabit(Habit habit) async {
    await _db.habitDao.updateHabit(
      db.HabitsCompanion(
        id: Value(habit.id),
        categoryId: Value(habit.categoryId),
        name: Value(habit.name),
        nameId: Value(habit.nameId),
        description: Value(habit.description),
        icon: Value(habit.icon),
        goalPeriod: Value(habit.goalPeriod.name),
        goalValue: Value(habit.goalValue),
        goalUnit: Value(habit.goalUnit),
        goalDirection: Value(habit.goalDirection.name),
        taskDays: Value(TaskDays.encode(habit.taskDays)),
        timeRange: Value(habit.timeRange.name),
        reminderEnabled: Value(habit.reminderEnabled),
        reminderTime: Value(habit.reminderTime),
        startDate: Value(habit.startDate),
        endDate: Value(habit.endDate),
        isActive: Value(habit.isActive),
        sortOrder: Value(habit.sortOrder),
        createdAt: Value(habit.createdAt),
        isCustom: Value(habit.isCustom),
        templateKey: Value(habit.templateKey),
      ),
    );
  }

  /// Routine backfill sekali-jalan (dipicu dari `AppBootstrap`, dijaga oleh
  /// `SettingsRepository.templateBackfillDone`): cocokkan habit lama yang
  /// belum punya `templateKey` ke 131 template bawaan lewat `name` (persis,
  /// case-insensitive/trim) — kalau cocok, kunci sebagai bawaan
  /// (`isCustom=false`) dan isi `nameId`/`templateKey`. Habit yang tidak
  /// cocok (custom asli, atau pernah di-rename) dibiarkan `isCustom=true`
  /// (default aman dari migrasi) supaya tetap bisa diedit user.
  Future<void> backfillTemplateProvenance(List<CategoryTemplate> categoryTemplates) async {
    final byNormalizedName = <String, HabitTemplate>{
      for (final category in categoryTemplates)
        for (final template in category.habits) _normalize(template.name): template,
    };

    final rows = await _db.habitDao.getAll();
    for (final row in rows) {
      if (row.templateKey != null) continue;
      final match = byNormalizedName[_normalize(row.name)];
      if (match == null) continue;
      await _db.habitDao.setTemplateProvenance(
        row.id,
        isCustom: false,
        nameId: match.nameId,
        templateKey: match.key,
      );
    }
  }

  String _normalize(String value) => value.trim().toLowerCase();

  Future<void> setActive(int habitId, bool isActive) =>
      _db.habitDao.setActive(habitId, isActive);

  Future<void> setSortOrder(int habitId, int sortOrder) =>
      _db.habitDao.setSortOrder(habitId, sortOrder);

  Future<void> deleteHabit(int habitId) async {
    await _db.habitLogDao.deleteLogsForHabit(habitId);
    await _db.habitDao.deleteHabit(habitId);
  }

  /// Hapus semua kategori, habit, dan riwayat progress. Dipakai untuk reset
  /// demo onboarding di Settings — pastikan notifikasi terjadwal sudah
  /// dibatalkan dulu di sisi caller sebelum memanggil ini.
  Future<void> deleteAllData() => _db.clearAllData();
}

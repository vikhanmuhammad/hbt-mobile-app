import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'habit_dao.g.dart';

@DriftAccessor(tables: [Habits])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.db);

  Stream<List<Habit>> watchAllActive() {
    return (select(habits)..where((h) => h.isActive.equals(true))).watch();
  }

  Stream<List<Habit>> watchByCategory(int categoryId) {
    return (select(habits)
          ..where((h) =>
              h.categoryId.equals(categoryId) & h.isActive.equals(true)))
        .watch();
  }

  Future<List<Habit>> getAllActive() {
    return (select(habits)..where((h) => h.isActive.equals(true))).get();
  }

  Future<List<Habit>> getAll() => select(habits).get();

  Future<Habit?> getById(int id) {
    return (select(habits)..where((h) => h.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertHabit(HabitsCompanion entry) {
    return into(habits).insert(entry);
  }

  /// Inserts every entry as one Drift batch (one transaction, one round
  /// trip) instead of N separate `insertHabit` calls — each of those was
  /// its own SQLite commit, which is what made adding several habits at
  /// once from the multi-select flow feel like N separate slow saves in a
  /// row instead of one fast one.
  Future<void> insertHabits(List<HabitsCompanion> entries) {
    return batch((b) => b.insertAll(habits, entries));
  }

  Future<bool> updateHabit(HabitsCompanion entry) {
    return update(habits).replace(entry);
  }

  Future<void> setActive(int id, bool isActive) async {
    await (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(isActive: Value(isActive)),
    );
  }

  Future<void> setSortOrder(int id, int sortOrder) async {
    await (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(sortOrder: Value(sortOrder)),
    );
  }

  /// Dipakai oleh routine backfill dwibahasa sekali-jalan (lihat
  /// `HabitRepository.backfillTemplateProvenance`) — set `isCustom`/
  /// `nameId`/`templateKey` tanpa menyentuh field lain.
  Future<void> setTemplateProvenance(
    int id, {
    required bool isCustom,
    String? nameId,
    String? templateKey,
  }) async {
    await (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        isCustom: Value(isCustom),
        nameId: Value(nameId),
        templateKey: Value(templateKey),
      ),
    );
  }

  Future<void> deleteHabit(int id) async {
    await (delete(habits)..where((h) => h.id.equals(id))).go();
  }

  Future<bool> hasHabitsInCategory(int categoryId) async {
    final result = await (select(habits)
          ..where((h) => h.categoryId.equals(categoryId)))
        .get();
    return result.isNotEmpty;
  }
}

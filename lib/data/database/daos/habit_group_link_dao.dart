import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'habit_group_link_dao.g.dart';

@DriftAccessor(tables: [HabitGroupLinks])
class HabitGroupLinkDao extends DatabaseAccessor<AppDatabase>
    with _$HabitGroupLinkDaoMixin {
  HabitGroupLinkDao(super.db);

  Stream<List<HabitGroupLink>> watchAll() {
    return select(habitGroupLinks).watch();
  }

  Stream<List<HabitGroupLink>> watchForHabit(int habitId) {
    return (select(habitGroupLinks)..where((l) => l.habitId.equals(habitId)))
        .watch();
  }

  Stream<List<HabitGroupLink>> watchForGroupHabit(String groupHabitId) {
    return (select(habitGroupLinks)
          ..where((l) => l.groupHabitId.equals(groupHabitId)))
        .watch();
  }

  Stream<List<HabitGroupLink>> watchForGroup(String groupId) {
    return (select(habitGroupLinks)..where((l) => l.groupId.equals(groupId)))
        .watch();
  }

  Future<List<HabitGroupLink>> getForHabit(int habitId) {
    return (select(habitGroupLinks)..where((l) => l.habitId.equals(habitId)))
        .get();
  }

  Future<HabitGroupLink?> getByGroupHabit(int habitId, String groupHabitId) {
    return (select(habitGroupLinks)
          ..where((l) =>
              l.habitId.equals(habitId) &
              l.groupHabitId.equals(groupHabitId)))
        .getSingleOrNull();
  }

  Future<int> insertLink(HabitGroupLinksCompanion entry) {
    return into(habitGroupLinks).insert(entry);
  }

  Future<void> setLastSyncedAt(int id, DateTime syncedAt) async {
    await (update(habitGroupLinks)..where((l) => l.id.equals(id))).write(
      HabitGroupLinksCompanion(lastSyncedAt: Value(syncedAt)),
    );
  }

  Future<void> deleteLink(int id) async {
    await (delete(habitGroupLinks)..where((l) => l.id.equals(id))).go();
  }

  Future<void> deleteLinksForHabit(int habitId) async {
    await (delete(habitGroupLinks)..where((l) => l.habitId.equals(habitId)))
        .go();
  }

  Future<void> deleteLinksForGroupHabit(String groupHabitId) async {
    await (delete(habitGroupLinks)
          ..where((l) => l.groupHabitId.equals(groupHabitId)))
        .go();
  }
}

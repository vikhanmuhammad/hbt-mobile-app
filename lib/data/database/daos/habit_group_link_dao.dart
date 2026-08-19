import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'habit_group_link_dao.g.dart';

@DriftAccessor(tables: [HabitGroupLinks])
class HabitGroupLinkDao extends DatabaseAccessor<AppDatabase>
    with _$HabitGroupLinkDaoMixin {
  HabitGroupLinkDao(super.db);

  Stream<List<HabitGroupLink>> watchForHabit(int habitId, String uid) {
    return (select(habitGroupLinks)
          ..where((l) => l.habitId.equals(habitId) & l.uid.equals(uid)))
        .watch();
  }

  Stream<List<HabitGroupLink>> watchForGroupHabit(String groupHabitId, String uid) {
    return (select(habitGroupLinks)
          ..where((l) => l.groupHabitId.equals(groupHabitId) & l.uid.equals(uid)))
        .watch();
  }

  Stream<List<HabitGroupLink>> watchForGroup(String groupId, String uid) {
    return (select(habitGroupLinks)
          ..where((l) => l.groupId.equals(groupId) & l.uid.equals(uid)))
        .watch();
  }

  Future<List<HabitGroupLink>> getForHabit(int habitId, String uid) {
    return (select(habitGroupLinks)
          ..where((l) => l.habitId.equals(habitId) & l.uid.equals(uid)))
        .get();
  }

  /// Every link this account has made, across every group/habit — used to
  /// best-effort clean up this account's Firestore leaderboard entries
  /// before a full local data wipe (e.g. "Replay the onboarding flow"),
  /// since those entries would otherwise sit there permanently stale.
  Future<List<HabitGroupLink>> getAllForUid(String uid) {
    return (select(habitGroupLinks)..where((l) => l.uid.equals(uid))).get();
  }

  /// Reactive version of [getAllForUid] — drives Home's "which of my habits
  /// are already online in a community" split.
  Stream<List<HabitGroupLink>> watchAllForUid(String uid) {
    return (select(habitGroupLinks)..where((l) => l.uid.equals(uid))).watch();
  }

  Future<HabitGroupLink?> getByGroupHabit(int habitId, String groupHabitId, String uid) {
    return (select(habitGroupLinks)
          ..where((l) =>
              l.habitId.equals(habitId) &
              l.groupHabitId.equals(groupHabitId) &
              l.uid.equals(uid)))
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

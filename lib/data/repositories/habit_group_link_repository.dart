import 'package:drift/drift.dart' show Value;

import '../../domain/models/community/habit_group_link.dart';
import '../database/app_database.dart' as db;
import 'mappers.dart';

class HabitGroupLinkRepository {
  HabitGroupLinkRepository(this._db);

  final db.AppDatabase _db;

  Stream<List<HabitGroupLink>> watchForHabit(int habitId, String uid) {
    return _db.habitGroupLinkDao
        .watchForHabit(habitId, uid)
        .map((rows) => rows.map(mapHabitGroupLink).toList());
  }

  Stream<List<HabitGroupLink>> watchForGroupHabit(String groupHabitId, String uid) {
    return _db.habitGroupLinkDao
        .watchForGroupHabit(groupHabitId, uid)
        .map((rows) => rows.map(mapHabitGroupLink).toList());
  }

  Stream<List<HabitGroupLink>> watchForGroup(String groupId, String uid) {
    return _db.habitGroupLinkDao
        .watchForGroup(groupId, uid)
        .map((rows) => rows.map(mapHabitGroupLink).toList());
  }

  Future<List<HabitGroupLink>> getForHabit(int habitId, String uid) async {
    final rows = await _db.habitGroupLinkDao.getForHabit(habitId, uid);
    return rows.map(mapHabitGroupLink).toList();
  }

  Future<int> link({
    required int habitId,
    required String groupId,
    required String groupHabitId,
    required String uid,
  }) {
    return _db.habitGroupLinkDao.insertLink(
      db.HabitGroupLinksCompanion.insert(
        habitId: habitId,
        groupId: groupId,
        groupHabitId: groupHabitId,
        uid: Value(uid),
      ),
    );
  }

  Future<void> markSynced(int linkId, DateTime syncedAt) =>
      _db.habitGroupLinkDao.setLastSyncedAt(linkId, syncedAt);

  Future<void> unlink(int linkId) => _db.habitGroupLinkDao.deleteLink(linkId);

  /// Clears any local link(s) to a Group Habit that just got deleted (by the
  /// admin) — this device's own bookkeeping only, so the Habits tab doesn't
  /// keep pointing a local habit at a challenge that no longer exists.
  Future<void> unlinkAllForGroupHabit(String groupHabitId) =>
      _db.habitGroupLinkDao.deleteLinksForGroupHabit(groupHabitId);
}

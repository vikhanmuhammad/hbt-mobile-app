import '../../domain/models/community/habit_group_link.dart';
import '../database/app_database.dart' as db;
import 'mappers.dart';

class HabitGroupLinkRepository {
  HabitGroupLinkRepository(this._db);

  final db.AppDatabase _db;

  Stream<List<HabitGroupLink>> watchAll() {
    return _db.habitGroupLinkDao
        .watchAll()
        .map((rows) => rows.map(mapHabitGroupLink).toList());
  }

  Stream<List<HabitGroupLink>> watchForHabit(int habitId) {
    return _db.habitGroupLinkDao
        .watchForHabit(habitId)
        .map((rows) => rows.map(mapHabitGroupLink).toList());
  }

  Future<List<HabitGroupLink>> getForHabit(int habitId) async {
    final rows = await _db.habitGroupLinkDao.getForHabit(habitId);
    return rows.map(mapHabitGroupLink).toList();
  }

  Future<int> link({
    required int habitId,
    required String groupId,
    required String groupHabitId,
  }) {
    return _db.habitGroupLinkDao.insertLink(
      db.HabitGroupLinksCompanion.insert(
        habitId: habitId,
        groupId: groupId,
        groupHabitId: groupHabitId,
      ),
    );
  }

  Future<void> markSynced(int linkId, DateTime syncedAt) =>
      _db.habitGroupLinkDao.setLastSyncedAt(linkId, syncedAt);

  Future<void> unlink(int linkId) => _db.habitGroupLinkDao.deleteLink(linkId);
}

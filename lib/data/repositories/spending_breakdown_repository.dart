import '../../domain/models/spending_breakdown.dart';
import '../database/app_database.dart' as db;
import 'mappers.dart';

class SpendingBreakdownRepository {
  SpendingBreakdownRepository(this._db);

  final db.AppDatabase _db;

  Future<void> addEntries({
    required int habitId,
    required DateTime date,
    required List<SpendingBreakdownDraft> entries,
  }) {
    return _db.habitSpendingBreakdownDao.insertEntries(
      habitId: habitId,
      date: date,
      entries: entries,
    );
  }

  Future<List<SpendingBreakdownEntry>> getEntriesInRange(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _db.habitSpendingBreakdownDao.getEntriesInRange(start, end);
    return rows.map(mapSpendingBreakdownEntry).toList();
  }
}

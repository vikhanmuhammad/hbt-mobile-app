import '../../domain/models/enums.dart';
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
    return rows.map(mapSpendingBreakdownEntry).whereType<SpendingBreakdownEntry>().toList();
  }

  Future<List<SpendingBreakdownEntry>> getEntriesForHabitAndDate(
    int habitId,
    DateTime date,
  ) async {
    final rows = await _db.habitSpendingBreakdownDao.getEntriesForHabitAndDate(habitId, date);
    return rows.map(mapSpendingBreakdownEntry).whereType<SpendingBreakdownEntry>().toList();
  }

  Future<void> updateEntry({
    required int id,
    required SpendingBreakdownCategory category,
    String? label,
    required int amount,
  }) {
    return _db.habitSpendingBreakdownDao.updateEntry(
      id: id,
      category: category,
      label: label,
      amount: amount,
    );
  }

  Future<void> deleteEntry(int id) {
    return _db.habitSpendingBreakdownDao.deleteEntry(id);
  }
}

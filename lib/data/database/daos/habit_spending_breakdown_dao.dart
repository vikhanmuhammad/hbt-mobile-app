import 'package:drift/drift.dart';

import '../../../domain/models/enums.dart';
import '../../../domain/models/spending_breakdown.dart';
import '../app_database.dart';
import '../tables.dart';

part 'habit_spending_breakdown_dao.g.dart';

@DriftAccessor(tables: [HabitSpendingBreakdowns])
class HabitSpendingBreakdownDao extends DatabaseAccessor<AppDatabase>
    with _$HabitSpendingBreakdownDaoMixin {
  HabitSpendingBreakdownDao(super.db);

  /// Appends [entries] as new rows for (habitId, date) — see the doc comment
  /// on `HabitSpendingBreakdowns` for why this is additive, not a replace.
  Future<void> insertEntries({
    required int habitId,
    required DateTime date,
    required List<SpendingBreakdownDraft> entries,
  }) async {
    if (entries.isEmpty) return;
    final day = DateTime(date.year, date.month, date.day);
    await batch((b) {
      b.insertAll(
        habitSpendingBreakdowns,
        entries
            .map((e) => HabitSpendingBreakdownsCompanion.insert(
                  habitId: habitId,
                  date: day,
                  categoryKey: e.category.name,
                  label: Value(e.label),
                  amount: e.amount,
                ))
            .toList(),
      );
    });
  }

  Future<List<HabitSpendingBreakdown>> getEntriesInRange(
    DateTime start,
    DateTime end,
  ) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    return (select(habitSpendingBreakdowns)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(startDay) &
              t.date.isSmallerOrEqualValue(endDay)))
        .get();
  }

  /// Rincian yang sudah tersimpan untuk [habitId] pada [date] — dipakai
  /// quick-progress-sheet supaya rincian yang sudah diinput sebelumnya tetap
  /// kelihatan saat sheet dibuka lagi hari yang sama, bukan seolah hilang
  /// (#breakdown-not-shown-on-reopen).
  Future<List<HabitSpendingBreakdown>> getEntriesForHabitAndDate(
    int habitId,
    DateTime date,
  ) {
    final day = DateTime(date.year, date.month, date.day);
    return (select(habitSpendingBreakdowns)
          ..where((t) => t.habitId.equals(habitId) & t.date.equals(day)))
        .get();
  }

  Future<void> deleteEntriesForHabit(int habitId) async {
    await (delete(habitSpendingBreakdowns)..where((t) => t.habitId.equals(habitId))).go();
  }

  /// Edits one previously-saved entry in place — lets a user fix a mistaken
  /// amount/category/sub-category without deleting and re-adding it.
  Future<void> updateEntry({
    required int id,
    required SpendingBreakdownCategory category,
    String? label,
    required int amount,
  }) async {
    await (update(habitSpendingBreakdowns)..where((t) => t.id.equals(id))).write(
      HabitSpendingBreakdownsCompanion(
        categoryKey: Value(category.name),
        label: Value(label),
        amount: Value(amount),
      ),
    );
  }

  Future<void> deleteEntry(int id) async {
    await (delete(habitSpendingBreakdowns)..where((t) => t.id.equals(id))).go();
  }
}

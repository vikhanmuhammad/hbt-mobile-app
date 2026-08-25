import 'enums.dart';

/// One saved, categorized slice of a spending habit's logged progress on a
/// given day (e.g. Rp30.000 tagged "Daily Needs") — see `SpendingBreakdownCategory`.
/// Multiple entries can exist per (habitId, date): each save from the quick
/// progress sheet appends rather than replaces, so a user can log lunch then
/// fuel separately across the same day.
class SpendingBreakdownEntry {
  const SpendingBreakdownEntry({
    required this.id,
    required this.habitId,
    required this.date,
    required this.category,
    required this.label,
    required this.amount,
  });

  final int id;
  final int habitId;
  final DateTime date;
  final SpendingBreakdownCategory category;

  /// Free-text description, only meaningful (and only ever set) when
  /// [category] is `custom`.
  final String? label;
  final int amount;
}

/// Not-yet-persisted breakdown entry entered in the quick progress sheet —
/// has no [SpendingBreakdownEntry.id]/date yet, since those are assigned when
/// the habit's progress is actually saved (`SpendingBreakdownRepository.addEntries`).
class SpendingBreakdownDraft {
  const SpendingBreakdownDraft({
    required this.category,
    this.label,
    required this.amount,
  });

  final SpendingBreakdownCategory category;
  final String? label;
  final int amount;
}

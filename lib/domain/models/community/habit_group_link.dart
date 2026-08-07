/// Relasi habit lokal ke Group Habit di Firestore — habit tetap 1 skema
/// biasa di sistem lokal, cuma "disumbangkan" progressnya lewat link ini
/// (update_v2.md §4/§8).
class HabitGroupLink {
  const HabitGroupLink({
    required this.id,
    required this.habitId,
    required this.groupId,
    required this.groupHabitId,
    required this.linkedAt,
    this.lastSyncedAt,
  });

  final int id;
  final int habitId;
  final String groupId;
  final String groupHabitId;
  final DateTime linkedAt;
  final DateTime? lastSyncedAt;
}

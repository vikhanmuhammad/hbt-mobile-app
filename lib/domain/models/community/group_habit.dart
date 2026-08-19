import '../community_enums.dart';

/// "Tantangan" habit spesifik di dalam sebuah Group — satu Group bisa punya
/// beberapa Group Habit sekaligus, tiap Group Habit adalah unit leaderboard
/// tersendiri (update_v2.md §2).
class GroupHabit {
  const GroupHabit({
    required this.id,
    required this.groupId,
    required this.name,
    required this.unit,
    this.icon,
    required this.leaderboardMode,
    required this.createdBy,
    required this.createdAt,
    this.goalValue,
    this.goalPeriod,
  });

  final String id;
  final String groupId;
  final String name;
  final String unit;
  final String? icon;
  final LeaderboardMode leaderboardMode;
  final String createdBy;
  final DateTime createdAt;

  /// Target amount/period this Group Habit was published with (copied from
  /// whichever local habit first published it) — used to tell "same habit,
  /// same target" from "same name, different target" when deciding whether
  /// linking/adopting should reuse an existing habit or create a new one.
  /// Nullable because Group Habits created before this field existed don't
  /// have it; treat null as "unknown" (never auto-match) rather than
  /// guessing. `goalPeriod` stores the raw `GoalPeriod` enum name.
  final int? goalValue;
  final String? goalPeriod;
}

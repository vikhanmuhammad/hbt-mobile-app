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
  });

  final String id;
  final String groupId;
  final String name;
  final String unit;
  final String? icon;
  final LeaderboardMode leaderboardMode;
  final String createdBy;
  final DateTime createdAt;
}

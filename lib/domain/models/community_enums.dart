enum GroupRole {
  admin,
  member;

  static GroupRole fromValue(String value) => GroupRole.values.firstWhere(
        (e) => e.name == value,
        orElse: () => GroupRole.member,
      );

  String get label => switch (this) {
        GroupRole.admin => 'Admin',
        GroupRole.member => 'Anggota',
      };
}

/// Metode ranking leaderboard, dipilih per Group Habit (bukan per Group) —
/// lihat update_v2.md §5.
enum LeaderboardMode {
  streak,
  progress,
  both;

  static LeaderboardMode fromValue(String value) =>
      LeaderboardMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => LeaderboardMode.streak,
      );

  String get label => switch (this) {
        LeaderboardMode.streak => 'Streak',
        LeaderboardMode.progress => 'Total Progress',
        LeaderboardMode.both => 'Streak & Progress',
      };
}

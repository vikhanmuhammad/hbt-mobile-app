import '../language.dart';

enum GroupRole {
  admin,
  member;

  static GroupRole fromValue(String value) => GroupRole.values.firstWhere(
        (e) => e.name == value,
        orElse: () => GroupRole.member,
      );

  String label(AppLang lang) => switch (lang) {
        AppLang.en => switch (this) {
            GroupRole.admin => 'Admin',
            GroupRole.member => 'Member',
          },
        AppLang.id => switch (this) {
            GroupRole.admin => 'Admin',
            GroupRole.member => 'Anggota',
          },
      };
}

/// Leaderboard ranking method, chosen per Group Habit (not per Group) —
/// see update_v2.md §5.
enum LeaderboardMode {
  streak,
  progress,
  both;

  static LeaderboardMode fromValue(String value) =>
      LeaderboardMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => LeaderboardMode.streak,
      );

  String label(AppLang lang) => switch (lang) {
        AppLang.en => switch (this) {
            LeaderboardMode.streak => 'Streak',
            LeaderboardMode.progress => 'Total Progress',
            LeaderboardMode.both => 'Streak & Progress',
          },
        AppLang.id => switch (this) {
            LeaderboardMode.streak => 'Streak',
            LeaderboardMode.progress => 'Total Progres',
            LeaderboardMode.both => 'Streak & Progres',
          },
      };
}

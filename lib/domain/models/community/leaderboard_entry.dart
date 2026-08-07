class LeaderboardEntry {
  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    this.avatarIcon,
    required this.streak,
    required this.progressValue,
    required this.lastUpdated,
  });

  final String uid;
  final String displayName;
  final String? avatarIcon;
  final int streak;
  final int progressValue;
  final DateTime lastUpdated;
}

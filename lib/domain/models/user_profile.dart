class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    this.age,
    this.photoPath,
    required this.themeKey,
    required this.createdAt,
  });

  final int id;
  final String name;
  final int? age;
  final String? photoPath;
  final String themeKey;
  final DateTime createdAt;
}

import '../community_enums.dart';

class GroupMember {
  const GroupMember({
    required this.uid,
    required this.displayName,
    this.avatarIcon,
    required this.role,
    required this.joinedAt,
  });

  final String uid;
  final String displayName;
  final String? avatarIcon;
  final GroupRole role;
  final DateTime joinedAt;

  bool get isAdmin => role == GroupRole.admin;
}

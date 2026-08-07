import 'group_member.dart';

/// "Wadah" pertemanan, private & invite-based — update_v2.md §2. Beda level
/// dengan [GroupHabit] (tantangan spesifik di dalam Group).
class AppGroup {
  const AppGroup({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
    required this.members,
  });

  final String id;
  final String name;
  final String? photoUrl;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;
  final List<GroupMember> members;

  GroupMember? memberByUid(String uid) {
    for (final m in members) {
      if (m.uid == uid) return m;
    }
    return null;
  }

  bool isAdmin(String uid) => memberByUid(uid)?.isAdmin ?? false;
}

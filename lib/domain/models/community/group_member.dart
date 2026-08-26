import '../community_enums.dart';

class GroupMember {
  const GroupMember({
    required this.uid,
    required this.displayName,
    this.avatarIcon,
    this.photoBase64,
    required this.role,
    required this.joinedAt,
  });

  final String uid;
  final String displayName;
  final String? avatarIcon;
  // Small base64-encoded JPEG thumbnail of the member's profile photo — the
  // app has no Firebase Storage on the Spark plan, so photos travel inline
  // in the member map rather than as an uploaded file/URL. See
  // `AvatarImageService` for how it's produced.
  final String? photoBase64;
  final GroupRole role;
  final DateTime joinedAt;

  bool get isAdmin => role == GroupRole.admin;
}

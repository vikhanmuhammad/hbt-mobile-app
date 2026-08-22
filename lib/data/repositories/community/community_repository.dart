import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/community/app_group.dart';
import '../../../domain/models/community/chat_message.dart';
import '../../../domain/models/community/group_habit.dart';
import '../../../domain/models/community/group_member.dart';
import '../../../domain/models/community/leaderboard_entry.dart';
import '../../../domain/models/community_enums.dart';

class InviteCodeNotFound implements Exception {
  const InviteCodeNotFound();
}

class AlreadyGroupMember implements Exception {
  const AlreadyGroupMember();
}

/// Akses Firestore untuk fitur Community (Pro) — Group, Group Habit,
/// leaderboard, chat. Struktur dokumen mengikuti update_v2.md §8 &
/// `firestore.rules`: `groups/{groupId}` punya `members` (map uid -> info)
/// dan `memberUids` (array, didenormalisasi dari `members` supaya query
/// "grup saya" bisa lolos security rule tanpa listing publik).
class CommunityRepository {
  CommunityRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection('groups');

  CollectionReference<Map<String, dynamic>> get _invites =>
      _firestore.collection('invites');

  // ---------------------------------------------------------------------
  // Group
  // ---------------------------------------------------------------------

  Stream<List<AppGroup>> watchMyGroups(String uid) {
    return _groups
        .where('memberUids', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_groupFromDoc).toList());
  }

  Stream<AppGroup?> watchGroup(String groupId) {
    return _groups.doc(groupId).snapshots().map(
          (doc) => doc.exists ? _groupFromDoc(doc) : null,
        );
  }

  Future<AppGroup> createGroup({
    required String name,
    String? photoUrl,
    required String creatorUid,
    required String creatorDisplayName,
    String? creatorAvatarIcon,
  }) async {
    final groupRef = _groups.doc();
    final code = _generateInviteCode();
    final now = DateTime.now();

    final memberEntry = {
      'displayName': creatorDisplayName,
      'avatarIcon': creatorAvatarIcon,
      'role': GroupRole.admin.name,
      'joinedAt': Timestamp.fromDate(now),
    };

    final groupData = <String, dynamic>{
      'name': name,
      'photoUrl': photoUrl,
      'inviteCode': code,
      'createdBy': creatorUid,
      'createdAt': Timestamp.fromDate(now),
      'members': {creatorUid: memberEntry},
      'memberUids': [creatorUid],
    };

    final batch = _firestore.batch();
    batch.set(groupRef, groupData);
    batch.set(_invites.doc(code), {
      'groupId': groupRef.id,
      'createdBy': creatorUid,
      'createdAt': Timestamp.fromDate(now),
    });
    await batch.commit();

    return AppGroup(
      id: groupRef.id,
      name: name,
      photoUrl: photoUrl,
      inviteCode: code,
      createdBy: creatorUid,
      createdAt: now,
      members: [
        GroupMember(
          uid: creatorUid,
          displayName: creatorDisplayName,
          avatarIcon: creatorAvatarIcon,
          role: GroupRole.admin,
          joinedAt: now,
        ),
      ],
    );
  }

  /// Resolve kode invite -> groupId lewat `invites/{code}`, lalu tambahkan
  /// user sebagai member baru (role member) di `groups/{groupId}`. Lempar
  /// [InviteCodeNotFound] kalau kode tidak ada, [AlreadyGroupMember] kalau
  /// user sudah jadi anggota grup itu.
  Future<String> joinGroupByCode({
    required String code,
    required String uid,
    required String displayName,
    String? avatarIcon,
  }) async {
    final inviteDoc = await _invites.doc(code.trim().toUpperCase()).get();
    if (!inviteDoc.exists) throw const InviteCodeNotFound();
    final groupId = inviteDoc.data()!['groupId'] as String;

    final groupRef = _groups.doc(groupId);
    final groupDoc = await groupRef.get();
    if (!groupDoc.exists) throw const InviteCodeNotFound();

    final members = Map<String, dynamic>.from(
      groupDoc.data()!['members'] as Map<String, dynamic>? ?? {},
    );
    if (members.containsKey(uid)) throw const AlreadyGroupMember();

    await groupRef.update({
      'members.$uid': {
        'displayName': displayName,
        'avatarIcon': avatarIcon,
        'role': GroupRole.member.name,
        'joinedAt': Timestamp.fromDate(DateTime.now()),
      },
      'memberUids': FieldValue.arrayUnion([uid]),
    });

    return groupId;
  }

  Future<void> setMemberRole({
    required String groupId,
    required String targetUid,
    required GroupRole role,
  }) {
    return _groups.doc(groupId).update({
      'members.$targetUid.role': role.name,
    });
  }

  Future<void> removeMember({
    required String groupId,
    required String targetUid,
  }) {
    return _groups.doc(groupId).update({
      'members.$targetUid': FieldValue.delete(),
      'memberUids': FieldValue.arrayRemove([targetUid]),
    });
  }

  /// Self-removal — a member leaving a group of their own accord, as
  /// opposed to [removeMember] which is the admin-only kick action.
  /// Whether it's safe to call (e.g. not the group's only admin) is checked
  /// by the caller; Firestore rules only guarantee a member can remove
  /// themselves and no one else.
  Future<void> leaveGroup({
    required String groupId,
    required String uid,
  }) {
    return _groups.doc(groupId).update({
      'members.$uid': FieldValue.delete(),
      'memberUids': FieldValue.arrayRemove([uid]),
    });
  }

  /// Tears down a group: its Group Habits, the invite code that points to
  /// it, and the group doc itself. Admin-only (enforced by rules on each
  /// delete). Per-member leaderboard entries and chat messages are left as
  /// orphaned/unreachable data — Firestore has no cascading delete without
  /// Cloud Functions, chat messages are intentionally immutable (rules deny
  /// deleting them even here), and a member can only ever delete their own
  /// leaderboard entry, not everyone else's.
  Future<void> deleteGroup({
    required String groupId,
    required String inviteCode,
  }) async {
    final groupHabitsSnap =
        await _groups.doc(groupId).collection('groupHabits').get();
    final batch = _firestore.batch();
    for (final doc in groupHabitsSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_invites.doc(inviteCode));
    batch.delete(_groups.doc(groupId));
    await batch.commit();
  }

  // ---------------------------------------------------------------------
  // Group Habit
  // ---------------------------------------------------------------------

  Stream<List<GroupHabit>> watchGroupHabits(String groupId) {
    return _groups
        .doc(groupId)
        .collection('groupHabits')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(_groupHabitFromDoc).toList());
  }

  Future<GroupHabit> createGroupHabit({
    required String groupId,
    required String name,
    required String unit,
    String? icon,
    required LeaderboardMode leaderboardMode,
    required String createdBy,
    required int goalValue,
    required String goalPeriod,
    required String goalDirection,
  }) async {
    final now = DateTime.now();
    final ref = _groups.doc(groupId).collection('groupHabits').doc();
    await ref.set({
      'name': name,
      'unit': unit,
      'icon': icon,
      'leaderboardMode': leaderboardMode.name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(now),
      'goalValue': goalValue,
      'goalPeriod': goalPeriod,
      'goalDirection': goalDirection,
    });
    return GroupHabit(
      id: ref.id,
      groupId: groupId,
      name: name,
      unit: unit,
      icon: icon,
      leaderboardMode: leaderboardMode,
      createdBy: createdBy,
      createdAt: now,
      goalValue: goalValue,
      goalPeriod: goalPeriod,
      goalDirection: goalDirection,
    );
  }

  Future<void> deleteGroupHabit({
    required String groupId,
    required String groupHabitId,
  }) {
    return _groups
        .doc(groupId)
        .collection('groupHabits')
        .doc(groupHabitId)
        .delete();
  }

  // ---------------------------------------------------------------------
  // Leaderboard
  // ---------------------------------------------------------------------

  Stream<List<LeaderboardEntry>> watchLeaderboard({
    required String groupId,
    required String groupHabitId,
  }) {
    return _groups
        .doc(groupId)
        .collection('groupHabits')
        .doc(groupHabitId)
        .collection('leaderboard')
        .snapshots()
        .map((snap) => snap.docs.map(_leaderboardEntryFromDoc).toList());
  }

  /// Dipanggil dari `CommunitySyncService` tiap kali progress habit yang
  /// linked berubah — hanya angka agregat (streak, total progress) yang
  /// dikirim, bukan `HabitLogs` harian penuh (privasi, update_v2.md §7).
  Future<void> upsertLeaderboardEntry({
    required String groupId,
    required String groupHabitId,
    required String uid,
    required String displayName,
    String? avatarIcon,
    required int streak,
    required int progressValue,
  }) {
    return _groups
        .doc(groupId)
        .collection('groupHabits')
        .doc(groupHabitId)
        .collection('leaderboard')
        .doc(uid)
        .set({
      'displayName': displayName,
      'avatarIcon': avatarIcon,
      'streak': streak,
      'progressValue': progressValue,
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Called when a user unlinks their habit from a Group Habit — without
  /// this, their streak/progress stayed visible on the leaderboard even
  /// though nothing local is contributing to it anymore.
  Future<void> deleteLeaderboardEntry({
    required String groupId,
    required String groupHabitId,
    required String uid,
  }) {
    return _groups
        .doc(groupId)
        .collection('groupHabits')
        .doc(groupHabitId)
        .collection('leaderboard')
        .doc(uid)
        .delete();
  }

  // ---------------------------------------------------------------------
  // Chat
  // ---------------------------------------------------------------------

  Stream<List<ChatMessage>> watchMessages(String groupId, {int limit = 100}) {
    return _groups
        .doc(groupId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(_chatMessageFromDoc).toList());
  }

  Future<void> sendMessage({
    required String groupId,
    required String senderUid,
    required String senderName,
    required String text,
  }) {
    return _groups.doc(groupId).collection('messages').add({
      'senderUid': senderUid,
      'senderName': senderName,
      'text': text,
      'sentAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ---------------------------------------------------------------------
  // Mapping helpers
  // ---------------------------------------------------------------------

  AppGroup _groupFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final membersMap =
        Map<String, dynamic>.from(data['members'] as Map<String, dynamic>? ?? {});
    return AppGroup(
      id: doc.id,
      name: data['name'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      inviteCode: data['inviteCode'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      members: membersMap.entries.map((e) {
        final m = Map<String, dynamic>.from(e.value as Map<String, dynamic>);
        return GroupMember(
          uid: e.key,
          displayName: m['displayName'] as String? ?? '',
          avatarIcon: m['avatarIcon'] as String?,
          role: GroupRole.fromValue(m['role'] as String? ?? 'member'),
          joinedAt: (m['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList(),
    );
  }

  GroupHabit _groupHabitFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return GroupHabit(
      id: doc.id,
      groupId: doc.reference.parent.parent!.id,
      name: data['name'] as String? ?? '',
      unit: data['unit'] as String? ?? '',
      icon: data['icon'] as String?,
      leaderboardMode:
          LeaderboardMode.fromValue(data['leaderboardMode'] as String? ?? 'streak'),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      goalValue: (data['goalValue'] as num?)?.toInt(),
      goalPeriod: data['goalPeriod'] as String?,
      goalDirection: data['goalDirection'] as String?,
    );
  }

  LeaderboardEntry _leaderboardEntryFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return LeaderboardEntry(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      avatarIcon: data['avatarIcon'] as String?,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      progressValue: (data['progressValue'] as num?)?.toInt() ?? 0,
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ChatMessage _chatMessageFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatMessage(
      id: doc.id,
      senderUid: data['senderUid'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String _generateInviteCode() {
    return const Uuid().v4().replaceAll('-', '').substring(0, 8).toUpperCase();
  }
}

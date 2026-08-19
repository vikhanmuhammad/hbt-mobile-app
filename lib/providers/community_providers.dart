import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/community/community_repository.dart';
import '../data/repositories/habit_group_link_repository.dart';
import '../domain/models/community/app_group.dart';
import '../domain/models/community/chat_message.dart';
import '../domain/models/community/group_habit.dart';
import '../domain/models/community/habit_group_link.dart';
import '../domain/models/community/leaderboard_entry.dart';
import '../services/auth_service.dart';
import '../services/community_sync_service.dart';
import '../services/entitlement_service.dart';
import 'core_providers.dart';

part 'community_providers.g.dart';

// ---------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => AuthService();

@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) =>
    ref.watch(authServiceProvider).authStateChanges;

@riverpod
String? currentUid(Ref ref) => ref.watch(authStateProvider).value?.uid;

@riverpod
String currentDisplayName(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  return user?.displayName ?? user?.email ?? 'User';
}

// ---------------------------------------------------------------------
// Entitlement (gating Pro/Free) — update_v2.md §1.1
// ---------------------------------------------------------------------

@Riverpod(keepAlive: true)
MockEntitlementService mockEntitlementService(Ref ref) {
  final service = MockEntitlementService(ref.watch(sharedPreferencesProvider));
  ref.onDispose(service.dispose);
  return service;
}

@Riverpod(keepAlive: true)
EntitlementService entitlementService(Ref ref) =>
    ref.watch(mockEntitlementServiceProvider);

/// Status Pro reaktif — dipakai seluruh entry point Community (tab
/// navigasi, deep link invite, dst). Toggle debug ada di Settings.
@riverpod
class IsPro extends _$IsPro {
  @override
  bool build() => ref.watch(entitlementServiceProvider).isPro;

  Future<void> setPro(bool value) async {
    await ref.read(mockEntitlementServiceProvider).setPro(value);
    state = value;
  }
}

// ---------------------------------------------------------------------
// Repositories & services
// ---------------------------------------------------------------------

@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) => FirebaseFirestore.instance;

@riverpod
CommunityRepository communityRepository(Ref ref) {
  return CommunityRepository(ref.watch(firestoreProvider));
}

@riverpod
HabitGroupLinkRepository habitGroupLinkRepository(Ref ref) {
  return HabitGroupLinkRepository(ref.watch(appDatabaseProvider));
}

@riverpod
CommunitySyncService communitySyncService(Ref ref) {
  return CommunitySyncService(
    linkRepository: ref.watch(habitGroupLinkRepositoryProvider),
    habitRepository: ref.watch(habitRepositoryProvider),
    habitLogRepository: ref.watch(habitLogRepositoryProvider),
    communityRepository: ref.watch(communityRepositoryProvider),
  );
}

/// Dipanggil dari layar Beranda/Dashboard setelah progress habit berhasil
/// disimpan — fire-and-forget, no-op kalau habit tidak linked ke Group Habit
/// manapun atau user belum sign-in Community sama sekali.
Future<void> syncCommunityHabit(WidgetRef ref, int habitId) async {
  final user = ref.read(authStateProvider).value;
  if (user == null) return;
  try {
    await ref.read(communitySyncServiceProvider).syncHabit(
          habitId: habitId,
          uid: user.uid,
          displayName: user.displayName ?? user.email ?? 'User',
          avatarIcon: null,
        );
  } catch (_) {
    // Sync Community bersifat best-effort (mis. offline) — jangan ganggu
    // alur tracking harian yang sudah tersimpan lokal.
  }
}

// ---------------------------------------------------------------------
// Streams
// ---------------------------------------------------------------------

@riverpod
Stream<List<AppGroup>> myGroups(Ref ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const <AppGroup>[]);
  return ref.watch(communityRepositoryProvider).watchMyGroups(uid);
}

@riverpod
Stream<AppGroup?> groupDetail(Ref ref, String groupId) {
  return ref.watch(communityRepositoryProvider).watchGroup(groupId);
}

@riverpod
Stream<List<GroupHabit>> groupHabits(Ref ref, String groupId) {
  return ref.watch(communityRepositoryProvider).watchGroupHabits(groupId);
}

@riverpod
Stream<List<LeaderboardEntry>> groupHabitLeaderboard(
  Ref ref,
  String groupId,
  String groupHabitId,
) {
  return ref.watch(communityRepositoryProvider).watchLeaderboard(
        groupId: groupId,
        groupHabitId: groupHabitId,
      );
}

@riverpod
Stream<List<ChatMessage>> groupMessages(Ref ref, String groupId) {
  return ref.watch(communityRepositoryProvider).watchMessages(groupId);
}

@riverpod
Stream<List<HabitGroupLink>> habitGroupLinksForHabit(Ref ref, int habitId) {
  return ref.watch(habitGroupLinkRepositoryProvider).watchForHabit(habitId);
}

/// Habits (on this device) currently linked to a specific Group Habit —
/// drives the Link/Unlink state shown in the group's Habits tab, so it's
/// clear which local habit (if any) is already contributing to a given
/// habit item instead of only offering "Link".
@riverpod
Stream<List<HabitGroupLink>> habitGroupLinksForGroupHabit(
  Ref ref,
  String groupHabitId,
) {
  return ref.watch(habitGroupLinkRepositoryProvider).watchForGroupHabit(groupHabitId);
}

/// All of this device's local links into a given Group, across every Group
/// Habit in it — used by the group's Habits tab to figure out which of the
/// viewer's own habits are already published, and which existing Group
/// Habits they haven't adopted yet.
@riverpod
Stream<List<HabitGroupLink>> habitGroupLinksForGroup(Ref ref, String groupId) {
  return ref.watch(habitGroupLinkRepositoryProvider).watchForGroup(groupId);
}

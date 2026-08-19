// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authService)
final authServiceProvider = AuthServiceProvider._();

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  AuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<AuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthService>(value),
    );
  }
}

String _$authServiceHash() => r'21d842d4dceafa3d239c0196a0f2b890d37c0b71';

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'0dfa6a5e9504b30df4a8db25c68c1606567338a2';

@ProviderFor(currentUid)
final currentUidProvider = CurrentUidProvider._();

final class CurrentUidProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  CurrentUidProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUidProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUidHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentUid(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentUidHash() => r'82b0b5869abac0dfde0b42bd075c9fc5f45bef12';

@ProviderFor(currentDisplayName)
final currentDisplayNameProvider = CurrentDisplayNameProvider._();

final class CurrentDisplayNameProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  CurrentDisplayNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentDisplayNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentDisplayNameHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return currentDisplayName(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$currentDisplayNameHash() =>
    r'779fd6e2aa1cdc27b06ba5f36bf8bfd7fa6a477f';

@ProviderFor(mockEntitlementService)
final mockEntitlementServiceProvider = MockEntitlementServiceProvider._();

final class MockEntitlementServiceProvider
    extends
        $FunctionalProvider<
          MockEntitlementService,
          MockEntitlementService,
          MockEntitlementService
        >
    with $Provider<MockEntitlementService> {
  MockEntitlementServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mockEntitlementServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mockEntitlementServiceHash();

  @$internal
  @override
  $ProviderElement<MockEntitlementService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MockEntitlementService create(Ref ref) {
    return mockEntitlementService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MockEntitlementService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MockEntitlementService>(value),
    );
  }
}

String _$mockEntitlementServiceHash() =>
    r'a49706f1e794e7f1b9d7e667af9dbb9bb929e5b6';

@ProviderFor(entitlementService)
final entitlementServiceProvider = EntitlementServiceProvider._();

final class EntitlementServiceProvider
    extends
        $FunctionalProvider<
          EntitlementService,
          EntitlementService,
          EntitlementService
        >
    with $Provider<EntitlementService> {
  EntitlementServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entitlementServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entitlementServiceHash();

  @$internal
  @override
  $ProviderElement<EntitlementService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EntitlementService create(Ref ref) {
    return entitlementService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntitlementService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntitlementService>(value),
    );
  }
}

String _$entitlementServiceHash() =>
    r'cc1ab29d6d65e558447801a3de0e943231e76f02';

/// Status Pro reaktif — dipakai seluruh entry point Community (tab
/// navigasi, deep link invite, dst). Toggle debug ada di Settings.

@ProviderFor(IsPro)
final isProProvider = IsProProvider._();

/// Status Pro reaktif — dipakai seluruh entry point Community (tab
/// navigasi, deep link invite, dst). Toggle debug ada di Settings.
final class IsProProvider extends $NotifierProvider<IsPro, bool> {
  /// Status Pro reaktif — dipakai seluruh entry point Community (tab
  /// navigasi, deep link invite, dst). Toggle debug ada di Settings.
  IsProProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isProProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isProHash();

  @$internal
  @override
  IsPro create() => IsPro();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isProHash() => r'93388a81a19cff4fac43f6518eda5e152cc66f6c';

/// Status Pro reaktif — dipakai seluruh entry point Community (tab
/// navigasi, deep link invite, dst). Toggle debug ada di Settings.

abstract class _$IsPro extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(firestore)
final firestoreProvider = FirestoreProvider._();

final class FirestoreProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  FirestoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firestoreHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return firestore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$firestoreHash() => r'864285def6284159b44f9598dcde96347e0c1dce';

@ProviderFor(communityRepository)
final communityRepositoryProvider = CommunityRepositoryProvider._();

final class CommunityRepositoryProvider
    extends
        $FunctionalProvider<
          CommunityRepository,
          CommunityRepository,
          CommunityRepository
        >
    with $Provider<CommunityRepository> {
  CommunityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communityRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communityRepositoryHash();

  @$internal
  @override
  $ProviderElement<CommunityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommunityRepository create(Ref ref) {
    return communityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommunityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommunityRepository>(value),
    );
  }
}

String _$communityRepositoryHash() =>
    r'4f73491c59ae42e6617b4f93b5f5a25cd267f465';

@ProviderFor(habitGroupLinkRepository)
final habitGroupLinkRepositoryProvider = HabitGroupLinkRepositoryProvider._();

final class HabitGroupLinkRepositoryProvider
    extends
        $FunctionalProvider<
          HabitGroupLinkRepository,
          HabitGroupLinkRepository,
          HabitGroupLinkRepository
        >
    with $Provider<HabitGroupLinkRepository> {
  HabitGroupLinkRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitGroupLinkRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitGroupLinkRepositoryHash();

  @$internal
  @override
  $ProviderElement<HabitGroupLinkRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HabitGroupLinkRepository create(Ref ref) {
    return habitGroupLinkRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitGroupLinkRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitGroupLinkRepository>(value),
    );
  }
}

String _$habitGroupLinkRepositoryHash() =>
    r'335583709d630ef5cdacbdbad59608ccb7ce62e8';

@ProviderFor(communitySyncService)
final communitySyncServiceProvider = CommunitySyncServiceProvider._();

final class CommunitySyncServiceProvider
    extends
        $FunctionalProvider<
          CommunitySyncService,
          CommunitySyncService,
          CommunitySyncService
        >
    with $Provider<CommunitySyncService> {
  CommunitySyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communitySyncServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communitySyncServiceHash();

  @$internal
  @override
  $ProviderElement<CommunitySyncService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommunitySyncService create(Ref ref) {
    return communitySyncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommunitySyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommunitySyncService>(value),
    );
  }
}

String _$communitySyncServiceHash() =>
    r'193143bf07506f9a31044d88270156ace436ce3f';

@ProviderFor(myGroups)
final myGroupsProvider = MyGroupsProvider._();

final class MyGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppGroup>>,
          List<AppGroup>,
          Stream<List<AppGroup>>
        >
    with $FutureModifier<List<AppGroup>>, $StreamProvider<List<AppGroup>> {
  MyGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myGroupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myGroupsHash();

  @$internal
  @override
  $StreamProviderElement<List<AppGroup>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppGroup>> create(Ref ref) {
    return myGroups(ref);
  }
}

String _$myGroupsHash() => r'ad10cae25d3487fff1e6c94d487083ae1d79bc04';

@ProviderFor(groupDetail)
final groupDetailProvider = GroupDetailFamily._();

final class GroupDetailProvider
    extends
        $FunctionalProvider<AsyncValue<AppGroup?>, AppGroup?, Stream<AppGroup?>>
    with $FutureModifier<AppGroup?>, $StreamProvider<AppGroup?> {
  GroupDetailProvider._({
    required GroupDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupDetailHash();

  @override
  String toString() {
    return r'groupDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AppGroup?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppGroup?> create(Ref ref) {
    final argument = this.argument as String;
    return groupDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupDetailHash() => r'9a3855be7aff7f1eb76d20850d47a5e707095e6f';

final class GroupDetailFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AppGroup?>, String> {
  GroupDetailFamily._()
    : super(
        retry: null,
        name: r'groupDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupDetailProvider call(String groupId) =>
      GroupDetailProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupDetailProvider';
}

@ProviderFor(groupHabits)
final groupHabitsProvider = GroupHabitsFamily._();

final class GroupHabitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupHabit>>,
          List<GroupHabit>,
          Stream<List<GroupHabit>>
        >
    with $FutureModifier<List<GroupHabit>>, $StreamProvider<List<GroupHabit>> {
  GroupHabitsProvider._({
    required GroupHabitsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupHabitsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupHabitsHash();

  @override
  String toString() {
    return r'groupHabitsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<GroupHabit>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupHabit>> create(Ref ref) {
    final argument = this.argument as String;
    return groupHabits(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupHabitsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupHabitsHash() => r'78bb7c32855232d862c8abec630858ccd8f5db4c';

final class GroupHabitsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<GroupHabit>>, String> {
  GroupHabitsFamily._()
    : super(
        retry: null,
        name: r'groupHabitsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupHabitsProvider call(String groupId) =>
      GroupHabitsProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupHabitsProvider';
}

@ProviderFor(groupHabitLeaderboard)
final groupHabitLeaderboardProvider = GroupHabitLeaderboardFamily._();

final class GroupHabitLeaderboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LeaderboardEntry>>,
          List<LeaderboardEntry>,
          Stream<List<LeaderboardEntry>>
        >
    with
        $FutureModifier<List<LeaderboardEntry>>,
        $StreamProvider<List<LeaderboardEntry>> {
  GroupHabitLeaderboardProvider._({
    required GroupHabitLeaderboardFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'groupHabitLeaderboardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupHabitLeaderboardHash();

  @override
  String toString() {
    return r'groupHabitLeaderboardProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<LeaderboardEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LeaderboardEntry>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return groupHabitLeaderboard(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupHabitLeaderboardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupHabitLeaderboardHash() =>
    r'1e559d3afd74cf4ceaa8a1706949ee5c8e44ce87';

final class GroupHabitLeaderboardFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<LeaderboardEntry>>,
          (String, String)
        > {
  GroupHabitLeaderboardFamily._()
    : super(
        retry: null,
        name: r'groupHabitLeaderboardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupHabitLeaderboardProvider call(String groupId, String groupHabitId) =>
      GroupHabitLeaderboardProvider._(
        argument: (groupId, groupHabitId),
        from: this,
      );

  @override
  String toString() => r'groupHabitLeaderboardProvider';
}

@ProviderFor(groupMessages)
final groupMessagesProvider = GroupMessagesFamily._();

final class GroupMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChatMessage>>,
          List<ChatMessage>,
          Stream<List<ChatMessage>>
        >
    with
        $FutureModifier<List<ChatMessage>>,
        $StreamProvider<List<ChatMessage>> {
  GroupMessagesProvider._({
    required GroupMessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupMessagesHash();

  @override
  String toString() {
    return r'groupMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ChatMessage>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ChatMessage>> create(Ref ref) {
    final argument = this.argument as String;
    return groupMessages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupMessagesHash() => r'f082c7bf98dd7b68d92654a25e60d7cbcce023d8';

final class GroupMessagesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ChatMessage>>, String> {
  GroupMessagesFamily._()
    : super(
        retry: null,
        name: r'groupMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupMessagesProvider call(String groupId) =>
      GroupMessagesProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupMessagesProvider';
}

@ProviderFor(habitGroupLinksForHabit)
final habitGroupLinksForHabitProvider = HabitGroupLinksForHabitFamily._();

final class HabitGroupLinksForHabitProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitGroupLink>>,
          List<HabitGroupLink>,
          Stream<List<HabitGroupLink>>
        >
    with
        $FutureModifier<List<HabitGroupLink>>,
        $StreamProvider<List<HabitGroupLink>> {
  HabitGroupLinksForHabitProvider._({
    required HabitGroupLinksForHabitFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'habitGroupLinksForHabitProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitGroupLinksForHabitHash();

  @override
  String toString() {
    return r'habitGroupLinksForHabitProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<HabitGroupLink>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HabitGroupLink>> create(Ref ref) {
    final argument = this.argument as int;
    return habitGroupLinksForHabit(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitGroupLinksForHabitProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitGroupLinksForHabitHash() =>
    r'9eb1a2643e4c4aeaef1ab8c8bade0c7e059f28ae';

final class HabitGroupLinksForHabitFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<HabitGroupLink>>, int> {
  HabitGroupLinksForHabitFamily._()
    : super(
        retry: null,
        name: r'habitGroupLinksForHabitProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitGroupLinksForHabitProvider call(int habitId) =>
      HabitGroupLinksForHabitProvider._(argument: habitId, from: this);

  @override
  String toString() => r'habitGroupLinksForHabitProvider';
}

/// Habits (on this device) currently linked to a specific Group Habit —
/// drives the Link/Unlink state shown in the group's Habits tab, so it's
/// clear which local habit (if any) is already contributing to a given
/// habit item instead of only offering "Link".

@ProviderFor(habitGroupLinksForGroupHabit)
final habitGroupLinksForGroupHabitProvider =
    HabitGroupLinksForGroupHabitFamily._();

/// Habits (on this device) currently linked to a specific Group Habit —
/// drives the Link/Unlink state shown in the group's Habits tab, so it's
/// clear which local habit (if any) is already contributing to a given
/// habit item instead of only offering "Link".

final class HabitGroupLinksForGroupHabitProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitGroupLink>>,
          List<HabitGroupLink>,
          Stream<List<HabitGroupLink>>
        >
    with
        $FutureModifier<List<HabitGroupLink>>,
        $StreamProvider<List<HabitGroupLink>> {
  /// Habits (on this device) currently linked to a specific Group Habit —
  /// drives the Link/Unlink state shown in the group's Habits tab, so it's
  /// clear which local habit (if any) is already contributing to a given
  /// habit item instead of only offering "Link".
  HabitGroupLinksForGroupHabitProvider._({
    required HabitGroupLinksForGroupHabitFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitGroupLinksForGroupHabitProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitGroupLinksForGroupHabitHash();

  @override
  String toString() {
    return r'habitGroupLinksForGroupHabitProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<HabitGroupLink>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HabitGroupLink>> create(Ref ref) {
    final argument = this.argument as String;
    return habitGroupLinksForGroupHabit(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitGroupLinksForGroupHabitProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitGroupLinksForGroupHabitHash() =>
    r'a2c7589bb4ee6e8c47e72b6ff61fae2c4fd8c154';

/// Habits (on this device) currently linked to a specific Group Habit —
/// drives the Link/Unlink state shown in the group's Habits tab, so it's
/// clear which local habit (if any) is already contributing to a given
/// habit item instead of only offering "Link".

final class HabitGroupLinksForGroupHabitFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<HabitGroupLink>>, String> {
  HabitGroupLinksForGroupHabitFamily._()
    : super(
        retry: null,
        name: r'habitGroupLinksForGroupHabitProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Habits (on this device) currently linked to a specific Group Habit —
  /// drives the Link/Unlink state shown in the group's Habits tab, so it's
  /// clear which local habit (if any) is already contributing to a given
  /// habit item instead of only offering "Link".

  HabitGroupLinksForGroupHabitProvider call(String groupHabitId) =>
      HabitGroupLinksForGroupHabitProvider._(
        argument: groupHabitId,
        from: this,
      );

  @override
  String toString() => r'habitGroupLinksForGroupHabitProvider';
}

/// All of this device's local links into a given Group, across every Group
/// Habit in it — used by the group's Habits tab to figure out which of the
/// viewer's own habits are already published, and which existing Group
/// Habits they haven't adopted yet.

@ProviderFor(habitGroupLinksForGroup)
final habitGroupLinksForGroupProvider = HabitGroupLinksForGroupFamily._();

/// All of this device's local links into a given Group, across every Group
/// Habit in it — used by the group's Habits tab to figure out which of the
/// viewer's own habits are already published, and which existing Group
/// Habits they haven't adopted yet.

final class HabitGroupLinksForGroupProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitGroupLink>>,
          List<HabitGroupLink>,
          Stream<List<HabitGroupLink>>
        >
    with
        $FutureModifier<List<HabitGroupLink>>,
        $StreamProvider<List<HabitGroupLink>> {
  /// All of this device's local links into a given Group, across every Group
  /// Habit in it — used by the group's Habits tab to figure out which of the
  /// viewer's own habits are already published, and which existing Group
  /// Habits they haven't adopted yet.
  HabitGroupLinksForGroupProvider._({
    required HabitGroupLinksForGroupFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitGroupLinksForGroupProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitGroupLinksForGroupHash();

  @override
  String toString() {
    return r'habitGroupLinksForGroupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<HabitGroupLink>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HabitGroupLink>> create(Ref ref) {
    final argument = this.argument as String;
    return habitGroupLinksForGroup(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitGroupLinksForGroupProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitGroupLinksForGroupHash() =>
    r'38b7d783dc436b871f8b0bdcd70dbe1755924be5';

/// All of this device's local links into a given Group, across every Group
/// Habit in it — used by the group's Habits tab to figure out which of the
/// viewer's own habits are already published, and which existing Group
/// Habits they haven't adopted yet.

final class HabitGroupLinksForGroupFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<HabitGroupLink>>, String> {
  HabitGroupLinksForGroupFamily._()
    : super(
        retry: null,
        name: r'habitGroupLinksForGroupProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// All of this device's local links into a given Group, across every Group
  /// Habit in it — used by the group's Habits tab to figure out which of the
  /// viewer's own habits are already published, and which existing Group
  /// Habits they haven't adopted yet.

  HabitGroupLinksForGroupProvider call(String groupId) =>
      HabitGroupLinksForGroupProvider._(argument: groupId, from: this);

  @override
  String toString() => r'habitGroupLinksForGroupProvider';
}

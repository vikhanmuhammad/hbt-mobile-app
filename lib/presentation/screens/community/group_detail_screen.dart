import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/community/app_group.dart';
import '../../../domain/models/community/chat_message.dart';
import '../../../domain/models/community/group_habit.dart';
import '../../../domain/models/community/group_member.dart';
import '../../../domain/models/community/leaderboard_entry.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/community_enums.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/habit.dart';
import '../../../domain/models/habit_template.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/community_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/habit_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../../providers/template_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/animations/staggered_entrance.dart';
import '../../widgets/animations/tap_scale.dart';
import '../../widgets/habit_icon.dart';
import '../../widgets/pro_feature_teaser.dart';
import '../../widgets/segmented_pill_toggle.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  // Set right before we ourselves cause the group to vanish (leave/delete),
  // so the exit screen below can show a message tailored to that action
  // instead of the generic "no longer available" fallback used when the
  // group vanishes for an external reason (kicked, deleted by someone else)
  // while this screen happens to be open.
  String? _exitMessage;
  bool _exitScheduled = false;

  void _scheduleExit(String message) {
    if (_exitScheduled) return;
    _exitScheduled = true;
    setState(() => _exitMessage = message);
    // Give the message a beat to be readable before navigating back to
    // Community's group list — this is also the safety net for the race
    // where the group stream emits "gone" before our own leave/delete
    // handler gets a chance to pop (see git history: previously this left
    // the screen permanently stuck showing "Group not found").
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groupAsync = ref.watch(groupDetailProvider(widget.groupId));

    return groupAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text(l10n.groupFailedToLoad('$e')))),
      data: (group) {
        if (group == null) {
          _scheduleExit(_exitMessage ?? l10n.groupNotAvailable);
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.group_off_rounded, size: 40),
                    const SizedBox(height: 16),
                    Text(_exitMessage ?? l10n.groupNotAvailable, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          );
        }
        return _GroupDetailContent(group: group, onExit: _scheduleExit);
      },
    );
  }
}

class _GroupDetailContent extends ConsumerStatefulWidget {
  const _GroupDetailContent({required this.group, required this.onExit});

  final AppGroup group;

  /// Tells the parent [GroupDetailScreen] why the group is about to vanish
  /// (we just left it / deleted it) so it can show that message instead of
  /// the generic fallback once the group stream catches up and emits null.
  final ValueChanged<String> onExit;

  @override
  ConsumerState<_GroupDetailContent> createState() => _GroupDetailContentState();
}

class _GroupDetailContentState extends ConsumerState<_GroupDetailContent> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyInviteCode() {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: widget.group.inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.groupInviteCodeCopied(widget.group.inviteCode))),
    );
  }

  Future<void> _leaveGroup() async {
    final l10n = AppLocalizations.of(context)!;
    final myUid = ref.read(currentUidProvider);
    if (myUid == null) return;
    final group = widget.group;
    final iAmAdmin = group.isAdmin(myUid);
    final otherAdminExists = group.members.any((m) => m.uid != myUid && m.isAdmin);

    // Leaving as the sole admin while other members remain would strand the
    // group with nobody able to manage it — block that specific case rather
    // than silently letting it happen.
    if (iAmAdmin && !otherAdminExists && group.members.length > 1) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.groupPromoteAdminFirstTitle),
            content: Text(l10n.groupPromoteAdminFirstBody),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonOk)),
            ],
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.groupLeaveTitle),
        content: Text(
          group.members.length == 1
              ? l10n.groupLeaveOnlyMemberBody
              : l10n.groupLeaveNeedInviteBody(group.name),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.groupLeaveConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(communityRepositoryProvider).leaveGroup(groupId: group.id, uid: myUid);
      // Not gated on `mounted`/popped directly here — the group stream can
      // emit "gone" and unmount this widget before this line runs, which
      // used to silently skip the pop and strand the user on a dead
      // "Group not found" screen. `widget.onExit` reaches the parent
      // GroupDetailScreen, which owns the actual pop and stays mounted.
      widget.onExit(l10n.groupLeftMessage(group.name));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.groupFailedToLeave('$e'))));
      }
    }
  }

  Future<void> _deleteGroup() async {
    final l10n = AppLocalizations.of(context)!;
    final group = widget.group;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.groupDeleteTitle),
        content: Text(l10n.groupDeleteBody(group.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(communityRepositoryProvider).deleteGroup(
            groupId: group.id,
            inviteCode: group.inviteCode,
          );
      widget.onExit(l10n.groupDeletedMessage(group.name));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.groupFailedToDelete('$e'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final group = widget.group;
    final myUid = ref.watch(currentUidProvider);
    final iAmAdmin = myUid != null && group.isAdmin(myUid);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          IconButton(
            tooltip: l10n.groupCopyInviteCode,
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: _copyInviteCode,
          ),
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'leave') _leaveGroup();
              if (action == 'delete') _deleteGroup();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'leave', child: Text(l10n.groupLeaveGroup)),
              if (iAmAdmin)
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    l10n.groupDeleteGroup,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.groupTabHabits),
            Tab(text: l10n.groupTabLeaderboard),
            Tab(text: l10n.groupTabChat),
            Tab(text: l10n.groupTabMembers),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HabitsTab(group: group),
          _LeaderboardTab(groupId: group.id),
          _ChatTab(groupId: group.id),
          _MembersTab(group: group),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Habits tab — "online-ifies" a member's own local habits into the group
// (point: community redesign). No more standalone "Create Group Habit"
// form/FAB: the very first time a local habit is published to a group it
// implicitly creates the Group Habit entry (name/unit/icon copied from it,
// leaderboardMode always `both` — no manual config step).
// ---------------------------------------------------------------------

class _HabitsTab extends ConsumerWidget {
  const _HabitsTab({required this.group});

  final AppGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final groupId = group.id;
    final groupHabitsAsync = ref.watch(groupHabitsProvider(groupId));
    final localHabitsAsync = ref.watch(allActiveHabitsProvider);
    final linksAsync = ref.watch(habitGroupLinksForGroupProvider(groupId));
    final myUid = ref.watch(currentUidProvider);
    final iAmAdmin = myUid != null && group.isAdmin(myUid);

    final groupHabits = groupHabitsAsync.value;
    final localHabits = localHabitsAsync.value;
    final links = linksAsync.value;

    if (groupHabits == null || localHabits == null || links == null) {
      final error = groupHabitsAsync.error ?? localHabitsAsync.error ?? linksAsync.error;
      if (error != null) return Center(child: Text(l10n.groupFailedToLoadGeneric('$error')));
      return const Center(child: CircularProgressIndicator());
    }

    final linkedLocalHabitIds = links.map((l) => l.habitId).toSet();
    final linkedGroupHabitIds = links.map((l) => l.groupHabitId).toSet();

    final myUnlinkedHabits = localHabits.where((h) => !linkedLocalHabitIds.contains(h.id)).toList();
    final communityUnlinkedHabits =
        groupHabits.where((gh) => !linkedGroupHabitIds.contains(gh.id)).toList();

    // Already-linked pairs, for the "Linked" section — resolves each link
    // back to its local Habit + GroupHabit so the row can show both names.
    final linkedRows = <(Habit, GroupHabit)>[];
    for (final link in links) {
      Habit? localHabit;
      for (final h in localHabits) {
        if (h.id == link.habitId) {
          localHabit = h;
          break;
        }
      }
      GroupHabit? groupHabit;
      for (final gh in groupHabits) {
        if (gh.id == link.groupHabitId) {
          groupHabit = gh;
          break;
        }
      }
      if (localHabit != null && groupHabit != null) linkedRows.add((localHabit, groupHabit));
    }

    if (myUnlinkedHabits.isEmpty && communityUnlinkedHabits.isEmpty && linkedRows.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.groupNoHabitsYetBody,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        try {
          final refreshed = ref.refresh(groupHabitsProvider(groupId).future);
          await refreshed;
        } catch (_) {
          // Errors surface via the AsyncValue `error` branch above.
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (myUnlinkedHabits.isNotEmpty) ...[
            _TabSectionLabel(l10n.groupYourHabits),
            const SizedBox(height: 8),
            for (var i = 0; i < myUnlinkedHabits.length; i++)
              Builder(
                builder: (context) {
                  // Matched against the FULL group habits list (not just the
                  // unlinked ones) — if this device already linked a
                  // *different* local habit to the matching entry, we still
                  // need to know that so "Publish" doesn't silently create a
                  // duplicate (see _YourHabitRow's alreadyTrackedByMe).
                  final match = findMatchingGroupHabit(groupHabits, myUnlinkedHabits[i]);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FadeSlideIn(
                      delay: staggeredDelay(i),
                      child: _YourHabitRow(
                        habit: myUnlinkedHabits[i],
                        groupId: groupId,
                        matchingGroupHabit: match,
                        matchAlreadyTrackedByMe:
                            match != null && linkedGroupHabitIds.contains(match.id),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
          ],
          if (communityUnlinkedHabits.isNotEmpty) ...[
            _TabSectionLabel(l10n.groupCommunityHabits),
            const SizedBox(height: 8),
            for (var i = 0; i < communityUnlinkedHabits.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FadeSlideIn(
                  delay: staggeredDelay(i),
                  child: _CommunityHabitRow(habit: communityUnlinkedHabits[i], canManage: iAmAdmin),
                ),
              ),
            const SizedBox(height: 16),
          ],
          if (linkedRows.isNotEmpty) ...[
            _TabSectionLabel(l10n.groupLinked),
            const SizedBox(height: 8),
            for (var i = 0; i < linkedRows.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FadeSlideIn(
                  delay: staggeredDelay(i),
                  child: _LinkedHabitRow(
                    localHabit: linkedRows[i].$1,
                    groupHabit: linkedRows[i].$2,
                    canManage: iAmAdmin,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

}

/// Finds a Group Habit that's effectively the *same habit* as [local] — same
/// name (plural/singular-insensitive) AND same target (goal value, unit,
/// period). Matching on name alone isn't enough: two habits can share a name
/// but track different targets (e.g. "Drink water" 6 glasses vs 8 glasses),
/// and treating those as interchangeable would silently merge unrelated
/// progress. Deliberately not a fuzzy matcher beyond that, so it never
/// wrongly links two genuinely different habits. Group Habits published
/// before goalValue/goalPeriod were tracked (both null) never match, since
/// there's no way to confirm the target — safer to let the user create a
/// second entry than to guess.
GroupHabit? findMatchingGroupHabit(List<GroupHabit> candidates, Habit local) {
  final normalizedName = _normalizeHabitName(local.name);
  for (final gh in candidates) {
    if (_normalizeHabitName(gh.name) != normalizedName) continue;
    // goalValue/goalPeriod have always been required for a match — no way
    // to confirm the target without them, so a Group Habit published
    // before they were tracked never matches (safer than guessing). But
    // goalDirection is newer than both: a Group Habit published before it
    // existed still has real goalValue/goalPeriod, so only compare
    // goalDirection when it's actually present, instead of also rejecting
    // that older (but otherwise perfectly identifiable) match outright.
    if (gh.goalValue == null || gh.goalPeriod == null) continue;
    if (gh.goalValue != local.goalValue) continue;
    if (gh.goalPeriod != local.goalPeriod.name) continue;
    if (gh.goalDirection != null && gh.goalDirection != local.goalDirection.name) continue;
    if (gh.unit.trim().toLowerCase() != local.goalUnit.trim().toLowerCase()) continue;
    return gh;
  }
  return null;
}

/// Inverse of [findMatchingGroupHabit] — given a Group Habit, finds a local
/// habit among [candidates] that's effectively the same thing. Used by
/// [adoptGroupHabit] so "Add to My Habits" links an existing matching habit
/// instead of always creating a new one.
Habit? _findMatchingLocalHabit(List<Habit> candidates, GroupHabit groupHabit) {
  if (groupHabit.goalValue == null || groupHabit.goalPeriod == null) return null;
  final normalizedName = _normalizeHabitName(groupHabit.name);
  for (final h in candidates) {
    if (_normalizeHabitName(h.name) != normalizedName) continue;
    if (h.goalValue != groupHabit.goalValue) continue;
    if (h.goalPeriod.name != groupHabit.goalPeriod) continue;
    if (groupHabit.goalDirection != null && h.goalDirection.name != groupHabit.goalDirection) {
      continue;
    }
    if (h.goalUnit.trim().toLowerCase() != groupHabit.unit.trim().toLowerCase()) continue;
    return h;
  }
  return null;
}

/// Lowercases, trims, collapses whitespace, and strips a trailing 's'/'es'
/// from each word — just enough to treat "Eat vegetables & fruit" and "Eat
/// vegetable & fruit" as the same habit without attempting real fuzzy
/// matching (which risks merging genuinely different habits).
String _normalizeHabitName(String name) {
  final words = name.trim().toLowerCase().split(RegExp(r'\s+'));
  final singularized = words.map((w) {
    if (w.length > 4 && w.endsWith('es')) return w.substring(0, w.length - 2);
    if (w.length > 3 && w.endsWith('s')) return w.substring(0, w.length - 1);
    return w;
  });
  return singularized.join(' ');
}

class _TabSectionLabel extends StatelessWidget {
  const _TabSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5),
    );
  }
}

/// One of the viewer's own local habits not yet linked to this group.
/// `matchingGroupHabit` (non-null when an existing Group Habit has the same
/// name) switches the action from "Publish" (creates a brand-new Group
/// Habit from this local habit) to "Link" (attaches directly to the
/// existing one instead of creating a duplicate) — unless
/// [matchAlreadyTrackedByMe] is true, meaning this device already linked a
/// *different* local habit of the viewer's to that same Group Habit, in
/// which case both actions are blocked (linking a second local habit to the
/// same Group Habit would just be a second, redundant contribution from the
/// same account, and "Publish" would create an outright duplicate entry).
class _YourHabitRow extends ConsumerStatefulWidget {
  const _YourHabitRow({
    required this.habit,
    required this.groupId,
    required this.matchingGroupHabit,
    required this.matchAlreadyTrackedByMe,
  });

  final Habit habit;
  final String groupId;
  final GroupHabit? matchingGroupHabit;
  final bool matchAlreadyTrackedByMe;

  @override
  ConsumerState<_YourHabitRow> createState() => _YourHabitRowState();
}

class _YourHabitRowState extends ConsumerState<_YourHabitRow> {
  bool _working = false;

  Future<void> _publishOrLink() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    // Resolved up front: this row gets torn down (moves out of "Your
    // Habits" into "Linked") the moment `link()` below succeeds, so
    // `ref.read(...)` after that point risks "used ref after unmounted".
    final user = ref.read(authStateProvider).value;
    final syncService = ref.read(communitySyncServiceProvider);
    setState(() => _working = true);
    try {
      final match = widget.matchingGroupHabit;
      final groupHabitId = match != null
          ? match.id
          : (await ref.read(communityRepositoryProvider).createGroupHabit(
                groupId: widget.groupId,
                name: widget.habit.name,
                nameId: widget.habit.nameId,
                unit: widget.habit.goalUnit,
                icon: widget.habit.icon,
                leaderboardMode: LeaderboardMode.both,
                createdBy: uid,
                goalValue: widget.habit.goalValue,
                goalPeriod: widget.habit.goalPeriod.name,
                goalDirection: widget.habit.goalDirection.name,
              ))
              .id;
      final linkId = await ref.read(habitGroupLinkRepositoryProvider).link(
            habitId: widget.habit.id,
            groupId: widget.groupId,
            groupHabitId: groupHabitId,
            uid: uid,
          );
      // This habit may already have a local history (it's being
      // linked/published, not freshly created) — push it to the
      // leaderboard and back it up right away instead of waiting for the
      // next progress update.
      if (user != null) {
        unawaited(backfillCommunityHabitLink(
          syncService: syncService,
          uid: user.uid,
          displayName: user.displayName ?? user.email ?? 'User',
          habitId: widget.habit.id,
          linkId: linkId,
          groupId: widget.groupId,
          groupHabitId: groupHabitId,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.groupFailedToLink('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);
    final matched = widget.matchingGroupHabit != null;
    return TapScale(
      child: Card(
        child: ListTile(
          leading: HabitIcon(icon: widget.habit.icon, size: 20),
          title: Text(widget.habit.displayName(lang)),
          subtitle: Text(
            widget.matchAlreadyTrackedByMe
                ? l10n.groupAlreadyTrackedViaOther
                : matched
                    ? l10n.groupMatchesExisting
                    : widget.habit.goalLabel(lang),
            style: theme.textTheme.bodySmall,
          ),
          trailing: widget.matchAlreadyTrackedByMe
              ? null
              : _working
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : TextButton(
                      onPressed: _publishOrLink,
                      child: Text(matched ? l10n.groupLinkAction : l10n.groupPublishAction),
                    ),
        ),
      ),
    );
  }
}

/// A Group Habit that already exists in this group but the viewer hasn't
/// adopted into their own local habits yet.
class _CommunityHabitRow extends ConsumerWidget {
  const _CommunityHabitRow({required this.habit, required this.canManage});

  final GroupHabit habit;

  /// Admin-only — lets an admin remove a habit from the *community* (the
  /// Firestore Group Habit doc + its leaderboard) without touching anyone's
  /// local habit or progress history, which live entirely on-device.
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // If this account already has a leaderboard entry here but no local
    // link (exactly the state left behind by an uninstall+reinstall, or the
    // dev-only "Replay the onboarding flow" reset — see removeGroupHabitFromCommunity's
    // doc comment on why progress is never deleted for those), surface this
    // as reconnecting past progress rather than a generic first-time add.
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);
    final myUid = ref.watch(currentUidProvider);
    final leaderboardAsync = ref.watch(groupHabitLeaderboardProvider(habit.groupId, habit.id));
    final isReconnect =
        myUid != null && (leaderboardAsync.value?.any((e) => e.uid == myUid) ?? false);

    return TapScale(
      child: Card(
        child: ListTile(
          leading: HabitIcon(icon: habit.icon, size: 20),
          title: Text(habit.displayName(lang)),
          subtitle: Text(
            isReconnect ? l10n.groupReconnectBefore : habit.unit,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isReconnect ? theme.colorScheme.primary : null,
              fontWeight: isReconnect ? FontWeight.w700 : null,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canManage)
                IconButton(
                  tooltip: l10n.groupRemoveFromCommunity,
                  icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                  onPressed: () => removeGroupHabitFromCommunity(context, ref, habit),
                ),
              TextButton(
                onPressed: () => adoptGroupHabit(context, ref, habit),
                child: Text(isReconnect ? l10n.groupReconnectAction : l10n.groupAddToMyHabits),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A habit the viewer already tracks locally and has linked to the group.
class _LinkedHabitRow extends ConsumerStatefulWidget {
  const _LinkedHabitRow({required this.localHabit, required this.groupHabit, required this.canManage});

  final Habit localHabit;
  final GroupHabit groupHabit;

  /// Admin-only — same "remove from community" action as
  /// [_CommunityHabitRow], available here too since the group habit might
  /// be one the admin themselves has linked.
  final bool canManage;

  @override
  ConsumerState<_LinkedHabitRow> createState() => _LinkedHabitRowState();
}

class _LinkedHabitRowState extends ConsumerState<_LinkedHabitRow> {
  bool _working = false;

  Future<void> _unlink() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    setState(() => _working = true);
    try {
      final links = await ref
          .read(habitGroupLinkRepositoryProvider)
          .getForHabit(widget.localHabit.id, uid);
      for (final link in links) {
        if (link.groupHabitId == widget.groupHabit.id) {
          await ref.read(habitGroupLinkRepositoryProvider).unlink(link.id);
        }
      }
      await ref.read(communityRepositoryProvider).deleteLeaderboardEntry(
            groupId: widget.groupHabit.groupId,
            groupHabitId: widget.groupHabit.id,
            uid: uid,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.groupFailedToUnlink('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);
    return Card(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      child: ListTile(
        leading: HabitIcon(icon: widget.localHabit.icon, size: 20),
        title: Text(widget.localHabit.displayName(lang)),
        subtitle: Text(
          l10n.groupLinkedTo(widget.groupHabit.displayName(lang)),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: _working
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.canManage)
                    IconButton(
                      tooltip: l10n.groupRemoveFromCommunity,
                      icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                      onPressed: () => removeGroupHabitFromCommunity(context, ref, widget.groupHabit),
                    ),
                  OutlinedButton(
                    onPressed: _unlink,
                    style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                    child: Text(l10n.groupUnlink),
                  ),
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Leaderboard tab — one leaderboard per habit item, switched via a
// horizontally scrollable chip row instead of a dropdown.
// ---------------------------------------------------------------------

class _LeaderboardTab extends ConsumerStatefulWidget {
  const _LeaderboardTab({required this.groupId});

  final String groupId;

  @override
  ConsumerState<_LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends ConsumerState<_LeaderboardTab> {
  String? _selectedHabitId;
  bool _showProgress = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);
    final habitsAsync = ref.watch(groupHabitsProvider(widget.groupId));

    return habitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(l10n.groupFailedToLoadGeneric('$e'))),
      data: (habits) {
        if (habits.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.groupNoLeaderboardYetBody,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final selected = habits.firstWhere(
          (h) => h.id == _selectedHabitId,
          orElse: () => habits.first,
        );

        return Column(
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: habits.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final h = habits[i];
                  return _HabitChip(
                    label: h.displayName(lang),
                    selected: h.id == selected.id,
                    onTap: () => setState(() => _selectedHabitId = h.id),
                  );
                },
              ),
            ),
            if (selected.leaderboardMode == LeaderboardMode.both) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedPillToggle<bool>(
                  segments: [
                    PillSegment(value: false, label: l10n.leaderboardStreak),
                    PillSegment(value: true, label: l10n.leaderboardProgress),
                  ],
                  selected: _showProgress,
                  onChanged: (v) => setState(() => _showProgress = v),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: _LeaderboardList(
                groupId: widget.groupId,
                groupHabit: selected,
                byProgress: selected.leaderboardMode == LeaderboardMode.progress ||
                    (selected.leaderboardMode == LeaderboardMode.both && _showProgress),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HabitChip extends StatelessWidget {
  const _HabitChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : (theme.brightness == Brightness.light ? AppColors.lightSurfaceAlt : AppColors.darkSurfaceAlt),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: selected ? Colors.white : theme.textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }
}

class _LeaderboardList extends ConsumerWidget {
  const _LeaderboardList({
    required this.groupId,
    required this.groupHabit,
    required this.byProgress,
  });

  final String groupId;
  final GroupHabit groupHabit;
  final bool byProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final groupHabitId = groupHabit.id;
    final entriesAsync = ref.watch(groupHabitLeaderboardProvider(groupId, groupHabitId));
    final myUid = ref.watch(currentUidProvider);

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(l10n.leaderboardFailedToLoad('$e'))),
      data: (entries) {
        final sorted = [...entries]
          ..sort((a, b) =>
              byProgress ? b.progressValue.compareTo(a.progressValue) : b.streak.compareTo(a.streak));

        return RefreshIndicator(
          onRefresh: () async {
            try {
              final refreshed =
                  ref.refresh(groupHabitLeaderboardProvider(groupId, groupHabitId).future);
              await refreshed;
            } catch (_) {
              // Errors surface via the AsyncValue `error` branch above.
            }
          },
          child: sorted.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.4,
                      child: Center(child: Text(l10n.leaderboardNoProgressYet)),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final entry = sorted[i];
                    final isMe = entry.uid == myUid;
                    return FadeSlideIn(
                      delay: staggeredDelay(i),
                      child: _LeaderboardTile(
                        rank: i + 1,
                        entry: entry,
                        groupHabit: groupHabit,
                        byProgress: byProgress,
                        isMe: isMe,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

// Gold / silver / bronze for the top 3 ranks — makes the leaderboard read
// at a glance instead of every row looking the same.
const _rankColors = {
  1: Color(0xFFD4AF37),
  2: Color(0xFFA8A9AD),
  3: Color(0xFFCD7F32),
};

String _relativeTime(DateTime dt, AppLocalizations l10n) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return l10n.leaderboardJustNow;
  if (diff.inMinutes < 60) return l10n.leaderboardMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.leaderboardHoursAgo(diff.inHours);
  if (diff.inDays < 7) return l10n.leaderboardDaysAgo(diff.inDays);
  return '${dt.day}/${dt.month}/${dt.year}';
}

class _LeaderboardTile extends ConsumerWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.entry,
    required this.groupHabit,
    required this.byProgress,
    required this.isMe,
  });

  final int rank;
  final LeaderboardEntry entry;
  final GroupHabit groupHabit;
  final bool byProgress;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final unit = groupHabit.unit;
    // Show both stats, not just whichever the toggle is currently sorting
    // by — "Lampirkan detail data setiap user" — so it's clear how someone
    // is doing overall, not only on the one metric currently sorted.
    final primaryValue = byProgress ? '${entry.progressValue}' : '${entry.streak}';
    final primaryUnit = byProgress ? unit : l10n.leaderboardDaysUnit;
    final secondaryLabel = byProgress
        ? l10n.leaderboardStreakLabel(entry.streak)
        : l10n.leaderboardTotalLabel('${entry.progressValue}', unit);
    final rankColor = _rankColors[rank];
    // "Add to My Habits" only makes sense on someone else's row, and only
    // if this device doesn't already have a local habit linked to this
    // Group Habit (HabitGroupLinks is a per-device local table, so any
    // existing link there already belongs to the current user).
    final linksAsync = isMe ? null : ref.watch(habitGroupLinksForGroupHabitProvider(groupHabit.id));
    final alreadyLinked = isMe || (linksAsync?.value?.isNotEmpty ?? true);

    return Card(
      color: isMe ? theme.colorScheme.primary.withValues(alpha: 0.08) : null,
      shape: isMe
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: rankColor ?? theme.colorScheme.surfaceContainerHighest,
              foregroundColor: rankColor != null ? Colors.white : null,
              child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.displayName + (isMe ? l10n.leaderboardYouSuffix : ''),
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.leaderboardUpdatedLabel(secondaryLabel, _relativeTime(entry.lastUpdated, l10n)),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  primaryValue,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(primaryUnit, style: theme.textTheme.labelSmall),
              ],
            ),
            if (!alreadyLinked) ...[
              const SizedBox(width: 4),
              IconButton(
                tooltip: l10n.groupAddToMyHabits,
                icon: Icon(Icons.add_circle_outline_rounded, color: theme.colorScheme.primary),
                onPressed: () => adoptGroupHabit(context, ref, groupHabit),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Adopts" a Group Habit into the viewer's own habit list. If the viewer
/// already has a local habit that's effectively the same thing (same name +
/// same goal value/unit/period, via [findMatchingGroupHabit]'s inverse),
/// that existing habit is linked directly instead of creating a duplicate.
/// Otherwise opens the Add Habit form pre-filled with the Group Habit's
/// name/unit/icon, and auto-links the newly created habit back to it on
/// save. Shared by the Habits tab's "Community Habits" section and the
/// Leaderboard tab's per-row "Add to My Habits" action.
/// Guesses a goal phrase (category) to pre-fill for an adopted Group
/// Habit, so the user doesn't have to pick one manually before saving
/// (`AddHabitFlowScreen`'s "Goal Phrase" dropdown is otherwise required).
/// Group Habits don't carry a category id (categories are per-device, not
/// shared over Firestore), so this is a best-effort guess, in order:
/// 1. A rupiah-unit habit always goes under the Finance goal phrase.
/// 2. If the name matches a built-in habit template (`habit_templates.json`),
///    use that template's own goal phrase.
/// 3. Otherwise just fall back to the first available category — the user
///    can still change it afterwards, this only saves them a forced stop.
/// Returns null only if the device has no categories at all yet.
Future<int?> _guessCategoryId(WidgetRef ref, GroupHabit groupHabit) async {
  final categories = ref.read(categoriesProvider).value ?? const <Category>[];
  if (categories.isEmpty) return null;

  if (groupHabit.unit.trim().toLowerCase() == 'rupiah') {
    for (final c in categories) {
      if (isFinanceCategory(c)) return c.id;
    }
  }

  final normalizedName = groupHabit.name.trim().toLowerCase();
  List<CategoryTemplate> categoryTemplates = const [];
  try {
    categoryTemplates = await ref.read(habitTemplatesProvider.future);
  } catch (_) {
    // Best-effort guess only — fall through to the plain default below.
  }
  for (final template in categoryTemplates) {
    final matchesTemplate =
        template.habits.any((h) => h.name.trim().toLowerCase() == normalizedName);
    if (!matchesTemplate) continue;
    for (final c in categories) {
      if (c.templateKey == template.key) return c.id;
    }
  }

  return categories.first.id;
}

Future<void> adoptGroupHabit(BuildContext context, WidgetRef ref, GroupHabit groupHabit) async {
  // Everything this function needs from `ref`/`context` is resolved right
  // here, before any `await` — this specific row gets torn down the moment
  // `link()` succeeds (the habit moves from "Community Habits" to
  // "Linked", rebuilding that list), so reading providers or `context`
  // *after* that point risks "used ref/context after unmounted" — which is
  // exactly what silently broke restore before. Nothing below this block
  // touches `ref` or `context` again.
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  final lang = ref.read(appLanguageProvider);
  final uid = ref.read(currentUidProvider);
  if (uid == null) return;
  final user = ref.read(authStateProvider).value;
  final syncService = ref.read(communitySyncServiceProvider);
  final backupRepository = ref.read(habitLogBackupRepositoryProvider);
  final logRepository = ref.read(habitLogRepositoryProvider);
  final linkRepository = ref.read(habitGroupLinkRepositoryProvider);
  final habitRepository = ref.read(habitRepositoryProvider);
  final categories = ref.read(categoriesProvider).value ?? const <Category>[];
  final isPro = ref.read(isProProvider);
  final localHabits = ref.read(allActiveHabitsProvider).value ?? const <Habit>[];

  final existingMatch = _findMatchingLocalHabit(localHabits, groupHabit);
  if (existingMatch != null) {
    try {
      final linkId = await linkRepository.link(
        habitId: existingMatch.id,
        groupId: groupHabit.groupId,
        groupHabitId: groupHabit.id,
        uid: uid,
      );
      // Same as `_YourHabitRowState._publishOrLink` — this existing local
      // habit may already have history, so push/backup it right away.
      if (user != null) {
        unawaited(backfillCommunityHabitLink(
          syncService: syncService,
          uid: user.uid,
          displayName: user.displayName ?? user.email ?? 'User',
          habitId: existingMatch.id,
          linkId: linkId,
          groupId: groupHabit.groupId,
          groupHabitId: groupHabit.id,
        ));
      }
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.groupLinkedExistingHabit(existingMatch.displayName(lang)))),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.groupFailedToLink('$e'))));
    }
    return;
  }

  // No matching local habit — create one directly from a short confirm
  // dialog instead of routing through the (editable) Habit Form. Letting
  // the user edit target/period/etc. here would risk it silently drifting
  // out of sync with what everyone else in the group is tracking against;
  // the resulting habit can still be fine-tuned afterwards (subject to the
  // same locked-fields-while-linked rule as any other linked habit).
  final guessedCategoryId = await _guessCategoryId(ref, groupHabit);
  if (guessedCategoryId == null) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.groupNoGoalPhraseAvailable)));
    return;
  }

  final goalPeriod =
      groupHabit.goalPeriod != null ? GoalPeriod.fromValue(groupHabit.goalPeriod!) : GoalPeriod.daily;
  final goalValue = groupHabit.goalValue ?? 1;
  final goalDirection = groupHabit.goalDirection != null
      ? GoalDirection.fromValue(groupHabit.goalDirection!)
      : GoalDirection.atLeast;
  final goalUnit = groupHabit.unit.trim().isEmpty ? 'x' : groupHabit.unit.trim();

  final isFinance = categories.any((c) => c.id == guessedCategoryId && isFinanceCategory(c));
  if (isFinance && !isPro) {
    if (context.mounted) {
      await showProRequiredDialog(
        context,
        message: l10n.addHabitFinanceProOnly,
      );
    }
    return;
  }
  if (!isPro) {
    final activeHabits = await habitRepository.getAllActive();
    // Keep in sync with `_freeActiveHabitLimit` in add_habit_flow_screen.dart.
    if (activeHabits.length >= 5) {
      if (context.mounted) {
        await showProRequiredDialog(
          context,
          message: l10n.addHabitFreeLimitMessage(5),
        );
      }
      return;
    }
  }

  if (!context.mounted) return;
  final targetLabel = goalUnit == 'x' ? '${goalValue}x' : '$goalValue $goalUnit';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.groupAddToHabitsTitle),
      content: Text(
        l10n.groupAddToHabitsBody(groupHabit.displayName(lang), targetLabel, goalPeriod.label(lang)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.commonAdd),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  try {
    final habitId = await habitRepository.createHabit(
      categoryId: guessedCategoryId,
      name: groupHabit.name,
      nameId: groupHabit.nameId,
      icon: groupHabit.icon,
      goalPeriod: goalPeriod,
      goalValue: goalValue,
      goalUnit: goalUnit,
      goalDirection: goalDirection,
      taskDays: const [allDaysKey],
      timeRange: TimeRange.anytime,
      reminderEnabled: false,
      // Backdated to when the Group Habit was first published, not
      // today — so reconnecting after an uninstall doesn't hide the
      // habit from every day before the reconnect.
      startDate: groupHabit.createdAt,
    );
    await linkRepository.link(
      habitId: habitId,
      groupId: groupHabit.groupId,
      groupHabitId: groupHabit.id,
      uid: uid,
    );

    // Pulls back any daily progress previously backed up for this Group
    // Habit under this account, so a reconnect after uninstall isn't left
    // with an empty history for the days before today. Kept separate from
    // the create+link try/catch above: a restore failure shouldn't look
    // like the whole "Add to My Habits" action failed (the habit itself
    // was created and linked fine either way) — but it also shouldn't be
    // silently swallowed, since that's exactly what made a previous restore
    // bug invisible.
    String restoreMessage;
    try {
      final restoredCount = await restoreCommunityHabitBackup(
        backupRepository: backupRepository,
        logRepository: logRepository,
        habitId: habitId,
        uid: uid,
        groupHabitId: groupHabit.id,
      );
      restoreMessage = restoredCount > 0
          ? l10n.groupAddedRestored(groupHabit.displayName(lang), restoredCount)
          : l10n.groupAddedPlain(groupHabit.displayName(lang));
    } catch (e) {
      restoreMessage = l10n.groupAddedRestoreFailed(groupHabit.displayName(lang), '$e');
    }
    messenger.showSnackBar(SnackBar(content: Text(restoreMessage)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.groupFailedToAddHabit('$e'))));
  }
}

/// Admin-only: removes a habit from the community — deletes the Group
/// Habit doc + its leaderboard from Firestore, and clears this device's own
/// local bookkeeping of it (other members' devices self-heal the same way
/// next time they open this group's Habits tab). Deliberately does NOT
/// touch anyone's local `Habit`/`HabitLog` rows — those stay exactly as
/// they were, on every member's device, this only un-publishes the shared
/// online record.
Future<void> removeGroupHabitFromCommunity(
  BuildContext context,
  WidgetRef ref,
  GroupHabit groupHabit,
) async {
  final l10n = AppLocalizations.of(context)!;
  final lang = ref.read(appLanguageProvider);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.groupRemoveFromCommunityTitle),
      content: Text(l10n.groupRemoveFromCommunityBody(groupHabit.displayName(lang))),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.commonRemove),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  try {
    await ref.read(communityRepositoryProvider).deleteGroupHabit(
          groupId: groupHabit.groupId,
          groupHabitId: groupHabit.id,
        );
    await ref.read(habitGroupLinkRepositoryProvider).unlinkAllForGroupHabit(groupHabit.id);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.groupFailedToRemove('$e'))));
    }
  }
}

// ---------------------------------------------------------------------
// Chat tab
// ---------------------------------------------------------------------

class _ChatTab extends ConsumerStatefulWidget {
  const _ChatTab({required this.groupId});

  final String groupId;

  @override
  ConsumerState<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<_ChatTab> {
  final _messageController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final uid = ref.read(currentUidProvider);
    final displayName = ref.read(currentDisplayNameProvider);
    if (uid == null) return;

    setState(() => _sending = true);
    _messageController.clear();
    try {
      await ref.read(communityRepositoryProvider).sendMessage(
            groupId: widget.groupId,
            senderUid: uid,
            senderName: displayName,
            text: text,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.chatFailedToSend('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messagesAsync = ref.watch(groupMessagesProvider(widget.groupId));
    final myUid = ref.watch(currentUidProvider);

    return Column(
      children: [
        Expanded(
          child: messagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text(l10n.chatFailedToLoad('$e'))),
            data: (messages) {
              return RefreshIndicator(
                onRefresh: () async {
                  try {
                    final refreshed = ref.refresh(groupMessagesProvider(widget.groupId).future);
                    await refreshed;
                  } catch (_) {
                    // Errors surface via the AsyncValue `error` branch above.
                  }
                },
                child: messages.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 300,
                            child: Center(child: Text(l10n.chatNoMessagesYet)),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, i) =>
                            _ChatBubble(message: messages[i], isMe: messages[i].senderUid == myUid),
                      ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: l10n.chatWriteMessageHint,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : _send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primary.withValues(alpha: 0.15) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe)
              Text(message.senderName, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text(message.text, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Members tab
// ---------------------------------------------------------------------

class _MembersTab extends ConsumerWidget {
  const _MembersTab({required this.group});

  final AppGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUid = ref.watch(currentUidProvider);
    final iAmAdmin = myUid != null && group.isAdmin(myUid);

    return RefreshIndicator(
      onRefresh: () async {
        try {
          final refreshed = ref.refresh(groupDetailProvider(group.id).future);
          await refreshed;
        } catch (_) {
          // Errors surface via the AsyncValue `error` branch on GroupDetailScreen.
        }
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        // +1 for the invite code card pinned above the member list.
        itemCount: group.members.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _InviteCodeCard(code: group.inviteCode),
            );
          }
          final member = group.members[i - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FadeSlideIn(
              delay: staggeredDelay(i - 1),
              child: _MemberTile(
                groupId: group.id,
                member: member,
                canManage: iAmAdmin && member.uid != myUid,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Group invite code, shown prominently in the Members tab so any member
/// (not just whoever created the group) can easily hand it to a friend for
/// "Join via Code" — previously only reachable via a share icon in the
/// AppBar, which was easy to miss.
class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({required this.code});

  final String code;

  void _copy(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.groupInviteCodeCopied(code))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.qr_code_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.membersInviteCodeLabel, style: theme.textTheme.labelSmall),
                  const SizedBox(height: 2),
                  Text(
                    code,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.groupCopyInviteCode,
              icon: const Icon(Icons.copy_rounded),
              onPressed: () => _copy(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends ConsumerWidget {
  const _MemberTile({required this.groupId, required this.member, required this.canManage});

  final String groupId;
  final GroupMember member;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
        title: Text(member.displayName),
        subtitle: Text(member.role.label(lang), style: theme.textTheme.bodySmall),
        trailing: canManage
            ? PopupMenuButton<String>(
                onSelected: (action) async {
                  final repo = ref.read(communityRepositoryProvider);
                  if (action == 'promote') {
                    await repo.setMemberRole(groupId: groupId, targetUid: member.uid, role: GroupRole.admin);
                  } else if (action == 'demote') {
                    await repo.setMemberRole(groupId: groupId, targetUid: member.uid, role: GroupRole.member);
                  } else if (action == 'kick') {
                    await repo.removeMember(groupId: groupId, targetUid: member.uid);
                  }
                },
                itemBuilder: (context) => [
                  if (member.role == GroupRole.member)
                    PopupMenuItem(value: 'promote', child: Text(l10n.membersMakeAdmin)),
                  if (member.role == GroupRole.admin)
                    PopupMenuItem(value: 'demote', child: Text(l10n.membersRemoveAdmin)),
                  PopupMenuItem(value: 'kick', child: Text(l10n.membersRemove)),
                ],
              )
            : null,
      ),
    );
  }
}

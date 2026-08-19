import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/community/app_group.dart';
import '../../../domain/models/community/chat_message.dart';
import '../../../domain/models/community/group_habit.dart';
import '../../../domain/models/community/group_member.dart';
import '../../../domain/models/community/leaderboard_entry.dart';
import '../../../domain/models/community_enums.dart';
import '../../../domain/models/habit.dart';
import '../../../providers/community_providers.dart';
import '../../../providers/habit_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/animations/staggered_entrance.dart';
import '../../widgets/animations/tap_scale.dart';
import '../../widgets/habit_icon.dart';
import '../../widgets/segmented_pill_toggle.dart';
import '../add_habit/add_habit_flow_screen.dart';

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
    final groupAsync = ref.watch(groupDetailProvider(widget.groupId));

    return groupAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Failed to load group: $e'))),
      data: (group) {
        if (group == null) {
          _scheduleExit(_exitMessage ?? 'This group is no longer available.');
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.group_off_rounded, size: 40),
                    const SizedBox(height: 16),
                    Text(_exitMessage ?? 'This group is no longer available.', textAlign: TextAlign.center),
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
    Clipboard.setData(ClipboardData(text: widget.group.inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invite code "${widget.group.inviteCode}" copied')),
    );
  }

  Future<void> _leaveGroup() async {
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
            title: const Text('Promote another admin first'),
            content: const Text(
              "You're the only admin in this group. Make another member an admin "
              'before you leave, or delete the group instead.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
            ],
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave group?'),
        content: Text(
          group.members.length == 1
              ? "You're the only member — leaving means you'll need the invite code "
                  'to rejoin later. Delete the group instead if you want to remove it for good.'
              : "You'll need a new invite code to rejoin \"${group.name}\" later.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Leave')),
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
      widget.onExit('You left "${group.name}".');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to leave group: $e')));
      }
    }
  }

  Future<void> _deleteGroup() async {
    final group = widget.group;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete group?'),
        content: Text(
          'This permanently deletes "${group.name}", its Group Habits, and its invite '
          "code for everyone in it. This can't be undone.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
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
      widget.onExit('"${group.name}" was deleted.');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete group: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final myUid = ref.watch(currentUidProvider);
    final iAmAdmin = myUid != null && group.isAdmin(myUid);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          IconButton(
            tooltip: 'Copy invite code',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: _copyInviteCode,
          ),
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'leave') _leaveGroup();
              if (action == 'delete') _deleteGroup();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'leave', child: Text('Leave Group')),
              if (iAmAdmin)
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete Group',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Habits'),
            Tab(text: 'Leaderboard'),
            Tab(text: 'Chat'),
            Tab(text: 'Members'),
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
    final groupId = group.id;
    final groupHabitsAsync = ref.watch(groupHabitsProvider(groupId));
    final localHabitsAsync = ref.watch(allActiveHabitsProvider);
    final linksAsync = ref.watch(habitGroupLinksForGroupProvider(groupId));

    final groupHabits = groupHabitsAsync.value;
    final localHabits = localHabitsAsync.value;
    final links = linksAsync.value;

    if (groupHabits == null || localHabits == null || links == null) {
      final error = groupHabitsAsync.error ?? localHabitsAsync.error ?? linksAsync.error;
      if (error != null) return Center(child: Text('Failed to load: $error'));
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
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "You don't have any habits yet — add one from Home first, then come back "
                  'here to bring it online with the group.',
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
            const _TabSectionLabel('Your Habits'),
            const SizedBox(height: 8),
            for (var i = 0; i < myUnlinkedHabits.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FadeSlideIn(
                  delay: staggeredDelay(i),
                  child: _YourHabitRow(
                    habit: myUnlinkedHabits[i],
                    groupId: groupId,
                    matchingGroupHabit: _findByName(communityUnlinkedHabits, myUnlinkedHabits[i].name),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
          if (communityUnlinkedHabits.isNotEmpty) ...[
            const _TabSectionLabel('Community Habits'),
            const SizedBox(height: 8),
            for (var i = 0; i < communityUnlinkedHabits.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FadeSlideIn(
                  delay: staggeredDelay(i),
                  child: _CommunityHabitRow(habit: communityUnlinkedHabits[i]),
                ),
              ),
            const SizedBox(height: 16),
          ],
          if (linkedRows.isNotEmpty) ...[
            const _TabSectionLabel('Linked'),
            const SizedBox(height: 8),
            for (var i = 0; i < linkedRows.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FadeSlideIn(
                  delay: staggeredDelay(i),
                  child: _LinkedHabitRow(localHabit: linkedRows[i].$1, groupHabit: linkedRows[i].$2),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Case/whitespace-insensitive exact-name match — the only auto-suggest
  /// convenience for point: community redesign (deliberately not a fuzzy
  /// matcher, so it never wrongly links two different habits).
  GroupHabit? _findByName(List<GroupHabit> candidates, String name) {
    final normalized = name.trim().toLowerCase();
    for (final gh in candidates) {
      if (gh.name.trim().toLowerCase() == normalized) return gh;
    }
    return null;
  }
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
/// `matchingGroupHabit` (non-null when an existing Group Habit has the exact
/// same name) switches the action from "Publish" (creates a brand-new Group
/// Habit from this local habit) to "Link" (attaches directly to the
/// existing one instead of creating a duplicate).
class _YourHabitRow extends ConsumerStatefulWidget {
  const _YourHabitRow({required this.habit, required this.groupId, required this.matchingGroupHabit});

  final Habit habit;
  final String groupId;
  final GroupHabit? matchingGroupHabit;

  @override
  ConsumerState<_YourHabitRow> createState() => _YourHabitRowState();
}

class _YourHabitRowState extends ConsumerState<_YourHabitRow> {
  bool _working = false;

  Future<void> _publishOrLink() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    setState(() => _working = true);
    try {
      final match = widget.matchingGroupHabit;
      final groupHabitId = match != null
          ? match.id
          : (await ref.read(communityRepositoryProvider).createGroupHabit(
                groupId: widget.groupId,
                name: widget.habit.name,
                unit: widget.habit.goalUnit,
                icon: widget.habit.icon,
                leaderboardMode: LeaderboardMode.both,
                createdBy: uid,
              ))
              .id;
      await ref.read(habitGroupLinkRepositoryProvider).link(
            habitId: widget.habit.id,
            groupId: widget.groupId,
            groupHabitId: groupHabitId,
            uid: uid,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to link: $e')));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matched = widget.matchingGroupHabit != null;
    return TapScale(
      child: Card(
        child: ListTile(
          leading: HabitIcon(icon: widget.habit.icon, size: 20),
          title: Text(widget.habit.name),
          subtitle: Text(
            matched ? 'Matches an existing community habit' : widget.habit.goalLabel,
            style: theme.textTheme.bodySmall,
          ),
          trailing: _working
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : TextButton(onPressed: _publishOrLink, child: Text(matched ? 'Link' : 'Publish')),
        ),
      ),
    );
  }
}

/// A Group Habit that already exists in this group but the viewer hasn't
/// adopted into their own local habits yet.
class _CommunityHabitRow extends ConsumerWidget {
  const _CommunityHabitRow({required this.habit});

  final GroupHabit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return TapScale(
      child: Card(
        child: ListTile(
          leading: HabitIcon(icon: habit.icon, size: 20),
          title: Text(habit.name),
          subtitle: Text(habit.unit, style: theme.textTheme.bodySmall),
          trailing: TextButton(
            onPressed: () => adoptGroupHabit(context, ref, habit),
            child: const Text('Add to My Habits'),
          ),
        ),
      ),
    );
  }
}

/// A habit the viewer already tracks locally and has linked to the group.
class _LinkedHabitRow extends ConsumerStatefulWidget {
  const _LinkedHabitRow({required this.localHabit, required this.groupHabit});

  final Habit localHabit;
  final GroupHabit groupHabit;

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to unlink: $e')));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      child: ListTile(
        leading: HabitIcon(icon: widget.localHabit.icon, size: 20),
        title: Text(widget.localHabit.name),
        subtitle: Text(
          'Linked to "${widget.groupHabit.name}"',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: _working
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : OutlinedButton(
                onPressed: _unlink,
                style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                child: const Text('Unlink'),
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
    final habitsAsync = ref.watch(groupHabitsProvider(widget.groupId));

    return habitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Failed to load: $e')),
      data: (habits) {
        if (habits.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No habits yet. Go to the Habits tab and publish one of your own to start '
                'the first leaderboard.',
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
                    label: h.name,
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
                  segments: const [
                    PillSegment(value: false, label: 'Streak'),
                    PillSegment(value: true, label: 'Progress'),
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
    final groupHabitId = groupHabit.id;
    final entriesAsync = ref.watch(groupHabitLeaderboardProvider(groupId, groupHabitId));
    final myUid = ref.watch(currentUidProvider);

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Failed to load leaderboard: $e')),
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
                      child: const Center(child: Text('No progress recorded yet.')),
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

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
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
    final unit = groupHabit.unit;
    // Show both stats, not just whichever the toggle is currently sorting
    // by — "Lampirkan detail data setiap user" — so it's clear how someone
    // is doing overall, not only on the one metric currently sorted.
    final primaryValue = byProgress ? '${entry.progressValue}' : '${entry.streak}';
    final primaryUnit = byProgress ? unit : 'days';
    final secondaryLabel =
        byProgress ? '${entry.streak}-day streak' : '${entry.progressValue} $unit total';
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
                    entry.displayName + (isMe ? ' (You)' : ''),
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$secondaryLabel • Updated ${_relativeTime(entry.lastUpdated)}',
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
                tooltip: 'Add to My Habits',
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

/// "Adopts" a Group Habit into the viewer's own habit list — opens the Add
/// Habit form pre-filled with the Group Habit's name/unit/icon, and
/// auto-links the newly created habit back to it on save. Shared by the
/// Habits tab's "Community Habits" section and the Leaderboard tab's
/// per-row "Add to My Habits" action.
Future<void> adoptGroupHabit(BuildContext context, WidgetRef ref, GroupHabit groupHabit) async {
  final uid = ref.read(currentUidProvider);
  if (uid == null) return;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AddHabitFlowScreen(
        prefillName: groupHabit.name,
        prefillIcon: groupHabit.icon,
        prefillUnit: groupHabit.unit,
        onHabitSaved: (habitId) => ref.read(habitGroupLinkRepositoryProvider).link(
              habitId: habitId,
              groupId: groupHabit.groupId,
              groupHabitId: groupHabit.id,
              uid: uid,
            ),
      ),
    ),
  );
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(groupMessagesProvider(widget.groupId));
    final myUid = ref.watch(currentUidProvider);

    return Column(
      children: [
        Expanded(
          child: messagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Failed to load chat: $e')),
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
                        children: const [
                          SizedBox(
                            height: 300,
                            child: Center(child: Text('No messages yet. Start the conversation!')),
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
                    decoration: const InputDecoration(hintText: 'Write a message...', border: OutlineInputBorder()),
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
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invite code "$code" copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  Text('Invite Code', style: theme.textTheme.labelSmall),
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
              tooltip: 'Copy invite code',
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
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
        title: Text(member.displayName),
        subtitle: Text(member.role.label, style: theme.textTheme.bodySmall),
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
                    const PopupMenuItem(value: 'promote', child: Text('Make Admin')),
                  if (member.role == GroupRole.admin)
                    const PopupMenuItem(value: 'demote', child: Text('Remove Admin')),
                  const PopupMenuItem(value: 'kick', child: Text('Remove')),
                ],
              )
            : null,
      ),
    );
  }
}

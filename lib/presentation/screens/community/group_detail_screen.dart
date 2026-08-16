import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/community/app_group.dart';
import '../../../domain/models/community/chat_message.dart';
import '../../../domain/models/community/group_habit.dart';
import '../../../domain/models/community/group_member.dart';
import '../../../domain/models/community/leaderboard_entry.dart';
import '../../../domain/models/community_enums.dart';
import '../../../providers/community_providers.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/animations/staggered_entrance.dart';
import '../../widgets/animations/tap_scale.dart';
import '../../widgets/habit_icon.dart';
import 'create_group_habit_screen.dart';
import 'link_habit_screen.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));

    return groupAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Failed to load group: $e'))),
      data: (group) {
        if (group == null) {
          return const Scaffold(body: Center(child: Text('Group not found')));
        }
        return _GroupDetailContent(group: group);
      },
    );
  }
}

class _GroupDetailContent extends ConsumerStatefulWidget {
  const _GroupDetailContent({required this.group});

  final AppGroup group;

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

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          IconButton(
            tooltip: 'Copy invite code',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: _copyInviteCode,
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
          _HabitsTab(groupId: group.id),
          _LeaderboardTab(groupId: group.id),
          _ChatTab(groupId: group.id),
          _MembersTab(group: group),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Habits tab
// ---------------------------------------------------------------------

class _HabitsTab extends ConsumerWidget {
  const _HabitsTab({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(groupHabitsProvider(groupId));

    return Scaffold(
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load: $e')),
        data: (habits) {
          return RefreshIndicator(
            onRefresh: () async {
              try {
                final refreshed = ref.refresh(groupHabitsProvider(groupId).future);
                await refreshed;
              } catch (_) {
                // Errors surface via the AsyncValue `error` branch above.
              }
            },
            child: habits.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.5,
                        child: const Center(
                          child: Text('No Group Habits yet. Create the first challenge!'),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: habits.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => FadeSlideIn(
                      delay: staggeredDelay(i),
                      child: _GroupHabitTile(habit: habits[i]),
                    ),
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CreateGroupHabitScreen(groupId: groupId)),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Group Habit'),
      ),
    );
  }
}

class _GroupHabitTile extends StatelessWidget {
  const _GroupHabitTile({required this.habit});

  final GroupHabit habit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TapScale(
      child: Card(
        child: ListTile(
          leading: HabitIcon(icon: habit.icon, size: 20),
          title: Text(habit.name),
          subtitle: Text('${habit.unit} • ${habit.leaderboardMode.label}', style: theme.textTheme.bodySmall),
          trailing: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => LinkHabitScreen(groupHabit: habit)),
            ),
            child: const Text('Link'),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Leaderboard tab
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
          return const Center(child: Text('Create a Group Habit first to see the leaderboard.'));
        }
        final selected = habits.firstWhere(
          (h) => h.id == _selectedHabitId,
          orElse: () => habits.first,
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                initialValue: selected.id,
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                items: [
                  for (final h in habits) DropdownMenuItem(value: h.id, child: Text(h.name)),
                ],
                onChanged: (v) => setState(() => _selectedHabitId = v),
              ),
            ),
            if (selected.leaderboardMode == LeaderboardMode.both)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Streak')),
                    ButtonSegment(value: true, label: Text('Progress')),
                  ],
                  selected: {_showProgress},
                  onSelectionChanged: (s) => setState(() => _showProgress = s.first),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _LeaderboardList(
                groupId: widget.groupId,
                groupHabitId: selected.id,
                unit: selected.unit,
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

class _LeaderboardList extends ConsumerWidget {
  const _LeaderboardList({
    required this.groupId,
    required this.groupHabitId,
    required this.unit,
    required this.byProgress,
  });

  final String groupId;
  final String groupHabitId;
  final String unit;
  final bool byProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          rank: i + 1, entry: entry, unit: unit, byProgress: byProgress, isMe: isMe),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.entry,
    required this.unit,
    required this.byProgress,
    required this.isMe,
  });

  final int rank;
  final LeaderboardEntry entry;
  final String unit;
  final bool byProgress;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = byProgress ? '${entry.progressValue} $unit' : '${entry.streak} days';
    return Card(
      color: isMe ? theme.colorScheme.primary.withValues(alpha: 0.08) : null,
      child: ListTile(
        leading: CircleAvatar(radius: 16, child: Text('$rank')),
        title: Text(entry.displayName + (isMe ? ' (You)' : '')),
        trailing: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
      ),
    );
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
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: group.members.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final member = group.members[i];
          return FadeSlideIn(
            delay: staggeredDelay(i),
            child: _MemberTile(
              groupId: group.id,
              member: member,
              canManage: iAmAdmin && member.uid != myUid,
            ),
          );
        },
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

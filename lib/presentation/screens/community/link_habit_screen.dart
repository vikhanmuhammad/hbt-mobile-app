import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/community/group_habit.dart';
import '../../../domain/models/habit.dart';
import '../../../providers/community_providers.dart';
import '../../../providers/habit_providers.dart';
import '../../widgets/habit_icon.dart';
import '../../widgets/pill_button.dart';
import '../add_habit/add_habit_flow_screen.dart';

/// Link a local habit (existing or new) to a Group Habit — the habit
/// remains a regular local-system habit, only its progress gets
/// "contributed" via the `HabitGroupLinks` relation (update_v2.md §4).
class LinkHabitScreen extends ConsumerWidget {
  const LinkHabitScreen({super.key, required this.groupHabit});

  final GroupHabit groupHabit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habitsAsync = ref.watch(allActiveHabitsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Link ke "${groupHabit.name}"')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pick one of your existing habits, or create a new habit specifically '
              'for this challenge.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            PrimaryPillButton(
              label: '+ Create New Habit',
              onPressed: () async {
                await openAddHabitFlow(context);
                ref.invalidate(allActiveHabitsProvider);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: habitsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Failed to load habits: $e')),
                data: (habits) {
                  if (habits.isEmpty) {
                    return const Center(child: Text('No habits yet. Create one with the button above.'));
                  }
                  return ListView.separated(
                    itemCount: habits.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _HabitLinkTile(habit: habits[i], groupHabit: groupHabit),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitLinkTile extends ConsumerStatefulWidget {
  const _HabitLinkTile({required this.habit, required this.groupHabit});

  final Habit habit;
  final GroupHabit groupHabit;

  @override
  ConsumerState<_HabitLinkTile> createState() => _HabitLinkTileState();
}

class _HabitLinkTileState extends ConsumerState<_HabitLinkTile> {
  bool _linking = false;

  Future<void> _link() async {
    setState(() => _linking = true);
    try {
      await ref.read(habitGroupLinkRepositoryProvider).link(
            habitId: widget.habit.id,
            groupId: widget.groupHabit.groupId,
            groupHabitId: widget.groupHabit.id,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to link: $e')));
      }
    } finally {
      if (mounted) setState(() => _linking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: HabitIcon(icon: widget.habit.icon, size: 20),
        title: Text(widget.habit.name),
        subtitle: Text(widget.habit.goalLabel, style: theme.textTheme.bodySmall),
        trailing: _linking
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : TextButton(onPressed: _link, child: const Text('Link')),
      ),
    );
  }
}

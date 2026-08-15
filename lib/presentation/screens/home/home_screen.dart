import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/habit_with_progress.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/community_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/finance_providers.dart';
import '../../../providers/progress_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../../providers/ui_state_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/habit_progress_card.dart';
import '../../widgets/date_strip.dart';
import '../../widgets/quick_progress_sheet.dart';
import '../add_habit/add_habit_flow_screen.dart';

/// Home: flat list of all habits active that day (no goal-phrase
/// grouping), date strip + month selector on top. CLAUDE.md v3 §6.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final selectedDate = ref.watch(selectedHomeDateProvider);
    final month = DateTime(selectedDate.year, selectedDate.month);
    final isEditMode = ref.watch(homeEditModeProvider);

    final items = [...ref.watch(habitsWithProgressForDateProvider(selectedDate))]
      ..sort((a, b) => a.habit.sortOrder.compareTo(b.habit.sortOrder));
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.value ?? [];
    final categoryById = {for (final c in categories) c.id: c};

    final monthSummariesAsync = ref.watch(monthSummariesProvider(month));

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isTablet ? 32 : 16, isTablet ? 24 : 16, isTablet ? 32 : 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _shiftMonth(ref, month, -1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    '${monthFullNames[month.month - 1]} ${month.year}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => _shiftMonth(ref, month, 1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
                if (isEditMode)
                  TextButton(
                    onPressed: () => ref.read(homeEditModeProvider.notifier).state = false,
                    child: const Text('Done'),
                  )
                else
                  TextButton(
                    onPressed: () => ref.read(selectedHomeDateProvider.notifier).state = today(),
                    child: const Text('Today'),
                  ),
              ],
            ),
          ),
          monthSummariesAsync.when(
            loading: () => const SizedBox(height: 74),
            error: (e, st) => const SizedBox(height: 74),
            data: (summaries) => DateStrip(
              month: month,
              selectedDate: selectedDate,
              summaries: summaries,
              onSelectDate: (d) => ref.read(selectedHomeDateProvider.notifier).state = d,
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? const _EmptyState()
                : _HabitList(
                    items: items,
                    categoryById: categoryById,
                    categories: categories,
                    isEditMode: isEditMode,
                    isWide: isWide,
                    isTablet: isTablet,
                    selectedDate: selectedDate,
                  ),
          ),
        ],
      ),
    );
  }

  void _shiftMonth(WidgetRef ref, DateTime month, int delta) {
    final next = DateTime(month.year, month.month + delta, 1);
    ref.read(selectedHomeDateProvider.notifier).state = next;
  }
}

class _HabitList extends ConsumerWidget {
  const _HabitList({
    required this.items,
    required this.categoryById,
    required this.categories,
    required this.isEditMode,
    required this.isWide,
    required this.isTablet,
    required this.selectedDate,
  });

  final List<HabitWithProgress> items;
  final Map<int, Category> categoryById;
  final List<Category> categories;
  final bool isEditMode;
  final bool isWide;
  final bool isTablet;
  final DateTime selectedDate;

  Color _accentFor(int categoryId) {
    final category = categoryById[categoryId];
    if (category == null) return AppColors.gold;
    final index = categories.indexOf(category);
    return AppColors.categoryColorFromHex(category.colorHex, index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = EdgeInsets.fromLTRB(isTablet ? 32 : 16, 0, isTablet ? 32 : 16, 110);
    final crossAxisCount = isWide ? 2 : 1;

    if (!isEditMode) {
      if (crossAxisCount == 1) {
        return ListView.separated(
          padding: padding,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _buildCard(context, ref, items[index]),
        );
      }
      return GridView.builder(
        padding: padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 10,
          crossAxisSpacing: 14,
          childAspectRatio: 3.6,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildCard(context, ref, items[index]),
      );
    }

    return ReorderableListView.builder(
      padding: padding,
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) => _onReorder(ref, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          key: ValueKey(item.habit.id),
          padding: const EdgeInsets.only(bottom: 10),
          child: HabitProgressCard(
            item: item,
            accentColor: _accentFor(item.habit.categoryId),
            isEditMode: true,
            onTap: null,
            onEdit: () => openEditHabitFlow(context, item.habit),
            onDelete: () => _confirmDeactivate(context, ref, item),
            dragHandle: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_indicator_rounded),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, HabitWithProgress item) {
    return HabitProgressCard(
      key: ValueKey(item.habit.id),
      item: item,
      accentColor: _accentFor(item.habit.categoryId),
      isEditMode: false,
      onTap: () => _onTapCard(context, ref, item),
    );
  }

  Future<void> _onTapCard(BuildContext context, WidgetRef ref, HabitWithProgress item) async {
    final habit = item.habit;
    final isSimple = habit.goalValue <= 1 &&
        habit.goalUnit == 'x' &&
        habit.goalDirection == GoalDirection.atLeast;
    final repo = ref.read(habitLogRepositoryProvider);
    try {
      if (isSimple) {
        await repo.toggleDone(habit: habit, date: selectedDate, currentlyDone: item.isDone);
      } else {
        final value = await showQuickProgressSheet(context, item);
        if (value == null) return;
        await repo.setProgress(habit: habit, date: selectedDate, progressValue: value);
      }
      _invalidateSummaries(ref);
      unawaited(syncCommunityHabit(ref, habit.id));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save progress: $e')));
      }
    }
  }

  Future<void> _confirmDeactivate(BuildContext context, WidgetRef ref, HabitWithProgress item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate this habit?'),
        content: Text(
          '"${item.habit.name}" will be hidden from Home. Progress history stays saved — '
          'you can reactivate it anytime via the edit form.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Deactivate')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(habitRepositoryProvider).setActive(item.habit.id, false);
    // dashboardSummaryProvider/monthSummariesProvider/daySummaryProvider are
    // Future-backed (not reactive DB streams like allActiveHabitsProvider),
    // so without this the Dashboard keeps showing the deactivated habit's
    // stats from stale cached data even though Home already updated.
    _invalidateSummaries(ref);
  }

  void _onReorder(WidgetRef ref, int oldIndex, int newIndex) {
    final reordered = [...items];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    final repo = ref.read(habitRepositoryProvider);
    for (var i = 0; i < reordered.length; i++) {
      if (reordered[i].habit.sortOrder != i) {
        repo.setSortOrder(reordered[i].habit.id, i);
      }
    }
  }

  void _invalidateSummaries(WidgetRef ref) {
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(monthSummariesProvider);
    ref.invalidate(daySummaryProvider);
    ref.invalidate(financeSummaryProvider);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _EmptyHabitsIllustration(),
            const SizedBox(height: 16),
            Text('No habits scheduled yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Tap the Add Habit button at the bottom left to add your first habit for today.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Looping animated illustration (a floating clipboard with a checkmark
/// popping in) shown above the "No habits scheduled yet" message — replaces
/// the old flat static icon.
class _EmptyHabitsIllustration extends StatefulWidget {
  const _EmptyHabitsIllustration();

  @override
  State<_EmptyHabitsIllustration> createState() => _EmptyHabitsIllustrationState();
}

class _EmptyHabitsIllustrationState extends State<_EmptyHabitsIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 140,
      width: 140,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final float = Curves.easeInOut.transform(_controller.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -6 + float * 6),
                child: Container(
                  width: 76,
                  height: 92,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.dividerColor, width: 1.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Column(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: theme.dividerColor, width: 1.5),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Container(height: 6, color: theme.dividerColor),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 14 - float * 8,
                right: 18,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/habit_with_progress.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/community_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/finance_providers.dart';
import '../../../providers/progress_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../../providers/ui_state_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/animations/staggered_entrance.dart';
import '../../widgets/animations/tap_scale.dart';
import '../../widgets/empty_state_illustration.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final selectedDate = ref.watch(selectedHomeDateProvider);
    final month = DateTime(selectedDate.year, selectedDate.month);
    final isEditMode = ref.watch(homeEditModeProvider);

    final pendingDeleteIds = ref.watch(pendingDeleteHabitIdsProvider);
    final items = [...ref.watch(habitsWithProgressForDateProvider(selectedDate))]
      ..removeWhere((item) => pendingDeleteIds.contains(item.habit.id))
      ..sort((a, b) => a.habit.sortOrder.compareTo(b.habit.sortOrder));
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.value ?? [];
    final categoryById = {for (final c in categories) c.id: c};

    final monthSummariesAsync = ref.watch(monthSummariesProvider(month));

    return SafeArea(
      child: FadeSlideIn(
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
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${monthFullName(month.month, lang)} ${month.year}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _shiftMonth(ref, month, 1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
                if (isEditMode)
                  TextButton(
                    onPressed: () => ref.read(homeEditModeProvider.notifier).state = false,
                    child: Text(l10n.homeDone),
                  )
                else
                  Material(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => ref.read(selectedHomeDateProvider.notifier).state = today(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Text(
                          l10n.homeToday,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
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
            child: GestureDetector(
              // Swipe left/right to move a day, mirroring the DateStrip tap
              // interaction (#21) — disabled in Edit Mode since that's
              // reorder-by-drag territory (ReorderableListView already owns
              // horizontal-ish gestures there).
              onHorizontalDragEnd: isEditMode
                  ? null
                  : (details) {
                      final velocity = details.primaryVelocity ?? 0;
                      if (velocity.abs() < 200) return;
                      final delta = velocity < 0 ? 1 : -1;
                      ref.read(selectedHomeDateProvider.notifier).state =
                          selectedDate.add(Duration(days: delta));
                    },
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
                      linkedHabitIds: ref.watch(linkedHabitIdsProvider).value ?? const <int>{},
                    ),
            ),
          ),
        ],
        ),
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
    required this.linkedHabitIds,
  });

  final List<HabitWithProgress> items;
  final Map<int, Category> categoryById;
  final List<Category> categories;
  final bool isEditMode;
  final bool isWide;
  final bool isTablet;
  final DateTime selectedDate;

  /// Habits published/linked to a community group — drives the "My Habits"
  /// vs "Community" split below. Ignored in Edit Mode, where reordering
  /// needs one flat, unambiguous index order across every habit.
  final Set<int> linkedHabitIds;

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
      // Separate "My Habits" (local-only) from "Community" (published/
      // linked to a group) — only worth the extra headers when there's
      // actually a mix; a user with zero community habits (the common
      // case) still just sees one plain list.
      final communityItems = items.where((i) => linkedHabitIds.contains(i.habit.id)).toList();
      final localItems = items.where((i) => !linkedHabitIds.contains(i.habit.id)).toList();
      final showSections = communityItems.isNotEmpty && localItems.isNotEmpty;

      if (!showSections) {
        if (crossAxisCount == 1) {
          return ListView.separated(
            padding: padding,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _buildCard(context, ref, items[index], index),
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
          itemBuilder: (context, index) => _buildCard(context, ref, items[index], index),
        );
      }

      if (crossAxisCount == 1) {
        return ListView(
          padding: padding,
          children: [
            _HomeSectionLabel(AppLocalizations.of(context)!.homeMyHabits),
            const SizedBox(height: 8),
            for (var i = 0; i < localItems.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildCard(context, ref, localItems[i], i),
              ),
            const SizedBox(height: 20),
            _HomeSectionLabel(AppLocalizations.of(context)!.homeCommunity),
            const SizedBox(height: 8),
            for (var i = 0; i < communityItems.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildCard(context, ref, communityItems[i], localItems.length + i),
              ),
          ],
        );
      }

      Widget sectionGrid(List<HabitWithProgress> sectionItems, int startIndex) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 14,
            childAspectRatio: 3.6,
          ),
          itemCount: sectionItems.length,
          itemBuilder: (context, index) =>
              _buildCard(context, ref, sectionItems[index], startIndex + index),
        );
      }

      return ListView(
        padding: padding,
        children: [
          _HomeSectionLabel(AppLocalizations.of(context)!.homeMyHabits),
          const SizedBox(height: 8),
          sectionGrid(localItems, 0),
          const SizedBox(height: 20),
          _HomeSectionLabel(AppLocalizations.of(context)!.homeCommunity),
          const SizedBox(height: 8),
          sectionGrid(communityItems, localItems.length),
        ],
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
            onEdit: () async {
              final saved = await openEditHabitFlow(
                context,
                item.habit,
                lockGoalFields: linkedHabitIds.contains(item.habit.id),
              );
              // Only leave edit mode on an actual save — backing out of the
              // edit form without saving should keep editing the list (#9).
              if (saved) {
                ref.read(homeEditModeProvider.notifier).state = false;
              }
            },
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

  Widget _buildCard(BuildContext context, WidgetRef ref, HabitWithProgress item, int index) {
    return FadeSlideIn(
      delay: staggeredDelay(index),
      child: TapScale(
        child: HabitProgressCard(
          key: ValueKey(item.habit.id),
          item: item,
          accentColor: _accentFor(item.habit.categoryId),
          isEditMode: false,
          onTap: () => _onTapCard(context, ref, item),
        ),
      ),
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
        await repo.applyPeriodAwareEdit(
          habit: habit,
          date: selectedDate,
          previousPeriodTotal: item.progressValue,
          newPeriodTotal: value,
        );
      }
      _invalidateSummaries(ref);
      unawaited(syncCommunityHabit(ref, habit.id, selectedDate));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.homeFailedToSaveProgress('$e'))),
        );
      }
    }
  }

  Future<void> _confirmDeactivate(BuildContext context, WidgetRef ref, HabitWithProgress item) async {
    final lang = ref.read(appLanguageProvider);
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.homeDeleteHabitTitle),
        content: Text(l10n.homeDeleteHabitBody(item.habit.displayName(lang))),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    final habit = item.habit;
    final habitId = habit.id;

    // Deferred delete (#12): hide immediately via `pendingDeleteHabitIdsProvider`
    // (filtered out of `items` in build()), but only actually touch the
    // database 5s later. Undo just un-hides it — no row is ever deleted if
    // the user undoes in time, so unlike a real delete+recreate, the habit
    // keeps its original id and any Community link stays intact.
    ref.read(pendingDeleteHabitIdsProvider.notifier).update((s) => {...s, habitId});

    var undone = false;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.homeHabitDeleted(habit.displayName(lang))),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.commonUndo,
            onPressed: () {
              undone = true;
              ref.read(pendingDeleteHabitIdsProvider.notifier).update((s) => {...s}..remove(habitId));
            },
          ),
        ),
      );
    }

    await Future.delayed(const Duration(seconds: 5));
    if (undone) return;

    try {
      await ref.read(notificationServiceProvider).cancelForHabit(habitId);
    } catch (_) {
      // Notification cancellation failed (e.g. platform not supported) —
      // don't fail the habit deletion because of this.
    }
    // deleteHabit also removes the habit's logs (see HabitRepository), so its
    // progress is fully gone rather than just hidden — matches
    // dashboardSummaryProvider/monthSummariesProvider/daySummaryProvider
    // being Future-backed (not reactive DB streams), which is why they also
    // need an explicit invalidate below.
    await ref.read(habitRepositoryProvider).deleteHabit(habitId);
    ref.read(pendingDeleteHabitIdsProvider.notifier).update((s) => {...s}..remove(habitId));
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
    // financeSummaryForPeriodProvider (daily/weekly/monthly toggle) is a
    // separate family from the month-only financeSummaryProvider above —
    // without this, logging a finance habit from Home didn't show up on the
    // Finance screen until some unrelated action (e.g. changing day)
    // happened to trigger a rebuild.
    ref.invalidate(financeSummaryForPeriodProvider);
  }
}

/// Section header for Home's "My Habits" vs "Community" split (point:
/// separate local habits from ones already online in a community).
class _HomeSectionLabel extends StatelessWidget {
  const _HomeSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
    );
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
            const EmptyStateIllustration(),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.homeNoHabitsScheduledYet,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.homeEmptyStateHint,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/habit_with_progress.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/progress_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../../providers/ui_state_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/habit_progress_card.dart';
import '../../widgets/date_strip.dart';
import '../../widgets/quick_progress_sheet.dart';
import '../add_habit/add_habit_flow_screen.dart';

/// Beranda: flat list semua habit aktif hari itu (tanpa grouping goal
/// phrase), date strip + month selector di atas. CLAUDE.md v3 §6.
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
                    child: const Text('Selesai'),
                  )
                else
                  TextButton(
                    onPressed: () => ref.read(selectedHomeDateProvider.notifier).state = today(),
                    child: const Text('Hari ini'),
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
          Padding(
            padding: EdgeInsets.fromLTRB(isTablet ? 32 : 16, 16, isTablet ? 32 : 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(formatFullDate(selectedDate), style: theme.textTheme.headlineSmall),
            ),
          ),
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan progress: $e')));
      }
    }
  }

  Future<void> _confirmDeactivate(BuildContext context, WidgetRef ref, HabitWithProgress item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nonaktifkan habit ini?'),
        content: Text(
          '"${item.habit.name}" akan disembunyikan dari Beranda. Riwayat progress tetap tersimpan — '
          'kamu bisa aktifkan lagi lewat form edit.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Nonaktifkan')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(habitRepositoryProvider).setActive(item.habit.id, false);
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
            Icon(Icons.checklist_rounded, size: 48, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text('Belum ada habit terjadwal', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Tap tombol Tambah Habit di kiri bawah untuk menambah habit pertamamu di hari ini.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

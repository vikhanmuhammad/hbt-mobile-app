import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/habit.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/progress_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/daily_progress_ring.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/habit_form_sheet.dart';
import 'category_settings_sheet.dart';

/// Level 2 Beranda: daftar habit dalam 1 kategori, checkbox besar per habit,
/// progress ring kategori di header. Dipakai baik sebagai push route
/// (mobile) maupun panel kanan master-detail (tablet). Lihat DESIGN.md §4.2.
class CategoryDetailView extends ConsumerWidget {
  const CategoryDetailView({
    super.key,
    required this.categoryId,
    this.accentColorOverride,
  });

  final int categoryId;
  final Color? accentColorOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final date = today();
    final items = ref.watch(habitsWithProgressForCategoryProvider(categoryId, date));

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Gagal memuat: $e')),
      data: (categories) {
        Category? category;
        for (final c in categories) {
          if (c.id == categoryId) category = c;
        }
        if (category == null) {
          return const Center(child: Text('Kategori tidak ditemukan'));
        }

        final index = categories.indexOf(category);
        final accentColor = accentColorOverride ??
            AppColors.categoryColorFromHex(category.colorHex, index);
        final done = items.where((i) => i.isDone).length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Card(
              color: accentColor.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    DailyProgressRing(
                      done: done,
                      total: items.length,
                      color: accentColor,
                      size: 72,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.name, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            items.isEmpty
                                ? 'Belum ada habit di kategori ini'
                                : '$done dari ${items.length} habit selesai hari ini',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded),
                      onPressed: () => showCategorySettingsSheet(context, category!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.spa_rounded, size: 40, color: Theme.of(context).disabledColor),
                    const SizedBox(height: 12),
                    const Text('Belum ada habit aktif hari ini di kategori ini.'),
                  ],
                ),
              )
            else
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: HabitCard(
                    item: item,
                    accentColor: accentColor,
                    onIncrement: () => _increment(ref, item.habit, item.progressValue, date),
                    onDecrement: item.progressValue > 0
                        ? () => _decrement(ref, item.habit, item.progressValue, date)
                        : null,
                    onTap: () => _editHabit(context, item.habit),
                  ),
                ),
          ],
        );
      },
    );
  }

  Future<void> _increment(WidgetRef ref, Habit habit, int current, DateTime date) async {
    final repo = ref.read(habitLogRepositoryProvider);
    if (habit.goalValue == 1) {
      await repo.toggleDone(habit: habit, date: date, currentlyDone: current >= habit.goalValue);
    } else {
      await repo.incrementProgress(habit: habit, date: date, currentValue: current);
    }
    _invalidateStats(ref);
  }

  Future<void> _decrement(WidgetRef ref, Habit habit, int current, DateTime date) async {
    final repo = ref.read(habitLogRepositoryProvider);
    await repo.incrementProgress(habit: habit, date: date, currentValue: current, step: -1);
    _invalidateStats(ref);
  }

  void _invalidateStats(WidgetRef ref) {
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(monthSummariesProvider);
    ref.invalidate(daySummaryProvider);
  }

  Future<void> _editHabit(BuildContext context, Habit habit) async {
    await showHabitFormSheet(
      context,
      initialCategoryId: habit.categoryId,
      editingHabit: habit,
    );
  }
}

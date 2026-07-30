import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/habit_schedule.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/habit_with_progress.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/progress_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/pill_button.dart';
import '../add_habit/add_habit_flow_screen.dart';

/// Level 2 Beranda: daftar habit dalam 1 kategori. Baris flat (bukan kartu
/// terpisah) dengan checkbox + tombol toggle di bawahnya, persis prototipe
/// baris ~444-472. Dipakai sebagai push route (mobile) & panel kanan
/// master-detail (tablet).
class CategoryDetailView extends ConsumerWidget {
  const CategoryDetailView({
    super.key,
    required this.categoryId,
    this.showBackButton = false,
    this.onBack,
  });

  final int categoryId;
  final bool showBackButton;
  final VoidCallback? onBack;

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
        final accentColor = AppColors.categoryColorFromHex(category.colorHex, index);
        final done = items.where((i) => i.isDone).length;
        final theme = Theme.of(context);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (showBackButton) ...[
                      Material(
                        color: theme.brightness == Brightness.light
                            ? AppColors.lightSurfaceAlt
                            : AppColors.darkSurfaceAlt,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onBack,
                          child: const SizedBox(
                            width: 32,
                            height: 32,
                            child: Icon(Icons.chevron_left_rounded, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(category.name, style: theme.textTheme.titleLarge),
                    ),
                    if (items.isNotEmpty) ...[
                      Text(
                        '$done/${items.length}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    PrimaryPillButton(
                      label: '+ Habit',
                      onPressed: () => openAddHabitFlowInCategory(context, categoryId),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Belum ada habit di kategori ini. Tekan "+ Habit" untuk menambahkan.',
                      style: theme.textTheme.bodySmall,
                    ),
                  )
                else
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HabitRow(
                        item: item,
                        accentColor: accentColor,
                        date: date,
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.item, required this.accentColor, required this.date});

  final HabitWithProgress item;
  final Color accentColor;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habit = item.habit;
    final checked = item.isDone;
    final notDueToday = !isHabitActiveOn(habit, date);
    final bg = checked
        ? Color.lerp(theme.scaffoldBackgroundColor, theme.colorScheme.primary, 0.12)!
        : theme.scaffoldBackgroundColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HabitCheckbox(
                checked: checked,
                onTap: () => _toggle(ref),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: checked ? theme.textTheme.bodySmall?.color : null,
                        decoration: checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${habit.goalLabel} · ${habit.timeRange.label}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (habit.reminderEnabled) ...[
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4, right: 8),
                  decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                ),
              ],
              if (notDueToday)
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 8),
                  child: Text(
                    'Tidak dijadwalkan',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              Material(
                color: theme.cardColor,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => openEditHabitFlow(context, habit),
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(Icons.edit_outlined, size: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _toggle(ref),
              style: OutlinedButton.styleFrom(
                backgroundColor: checked ? theme.colorScheme.primary : Colors.transparent,
                foregroundColor: checked ? Colors.white : theme.textTheme.bodyMedium?.color,
                side: BorderSide(
                  color: checked ? theme.colorScheme.primary : theme.dividerColor,
                  width: 2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                checked ? '✓ Selesai' : 'Tandai Selesai',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(WidgetRef ref) async {
    final repo = ref.read(habitLogRepositoryProvider);
    final habit = item.habit;
    if (habit.goalValue == 1) {
      await repo.toggleDone(habit: habit, date: date, currentlyDone: item.isDone);
    } else {
      await repo.incrementProgress(habit: habit, date: date, currentValue: item.progressValue);
    }
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(monthSummariesProvider);
    ref.invalidate(daySummaryProvider);
  }
}

class _HabitCheckbox extends StatelessWidget {
  const _HabitCheckbox({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: checked ? theme.colorScheme.primary : theme.scaffoldBackgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: checked
                ? theme.colorScheme.primary
                : theme.textTheme.bodySmall?.color ?? theme.dividerColor,
            width: checked ? 2 : 2.5,
          ),
        ),
        child: checked
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

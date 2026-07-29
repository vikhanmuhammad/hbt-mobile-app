import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/models/habit_with_progress.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/progress_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../../providers/ui_state_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/habit_form_sheet.dart';
import '../../widgets/monthly_calendar_grid.dart';

/// Riwayat/Kalender: kalender bulanan dengan gradasi warna + detail hari
/// (semua habit lintas kategori, bisa diedit/backfill). Lihat DESIGN.md §4.3.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final month = ref.watch(selectedHistoryMonthProvider);
    final selectedDate = ref.watch(selectedHistoryDateProvider);
    final summariesAsync = ref.watch(monthSummariesProvider(month));

    final calendar = Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: summariesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Text('Gagal memuat kalender: $e'),
            data: (summaries) => MonthlyCalendarGrid(
              month: month,
              summaries: summaries,
              selectedDate: selectedDate,
              onSelectDate: (d) =>
                  ref.read(selectedHistoryDateProvider.notifier).state = d,
              onChangeMonth: (m) =>
                  ref.read(selectedHistoryMonthProvider.notifier).state = m,
            ),
          ),
        ),
      ),
    );

    final detail = _DayDetail(date: selectedDate);

    if (isWide) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat')),
        body: Row(
          children: [
            SizedBox(width: 380, child: SingleChildScrollView(child: calendar)),
            const VerticalDivider(width: 1),
            Expanded(child: detail),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          calendar,
          detail,
        ],
      ),
    );
  }
}

class _DayDetail extends ConsumerWidget {
  const _DayDetail({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(habitsWithProgressForDateProvider(date));
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.value ?? [];
    final colorByCategory = {
      for (var i = 0; i < categories.length; i++)
        categories[i].id: AppColors.categoryColorFromHex(categories[i].colorHex, i),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formatDate(date), style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Tidak ada habit yang aktif ditagih pada tanggal ini.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: HabitCard(
                  item: item,
                  accentColor: colorByCategory[item.habit.categoryId] ?? AppColors.gold,
                  onIncrement: () => _increment(ref, item, date),
                  onDecrement: item.progressValue > 0
                      ? () => _decrement(ref, item, date)
                      : null,
                  onTap: () => showHabitFormSheet(
                    context,
                    initialCategoryId: item.habit.categoryId,
                    editingHabit: item.habit,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _increment(WidgetRef ref, HabitWithProgress item, DateTime date) async {
    final repo = ref.read(habitLogRepositoryProvider);
    final habit = item.habit;
    if (habit.goalValue == 1) {
      await repo.toggleDone(
          habit: habit, date: date, currentlyDone: item.progressValue >= habit.goalValue);
    } else {
      await repo.incrementProgress(habit: habit, date: date, currentValue: item.progressValue);
    }
    _invalidate(ref);
  }

  Future<void> _decrement(WidgetRef ref, HabitWithProgress item, DateTime date) async {
    final repo = ref.read(habitLogRepositoryProvider);
    await repo.incrementProgress(
        habit: item.habit, date: date, currentValue: item.progressValue, step: -1);
    _invalidate(ref);
  }

  void _invalidate(WidgetRef ref) {
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(monthSummariesProvider);
    ref.invalidate(daySummaryProvider);
  }

  String _formatDate(DateTime date) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', "Jumat", 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    final isToday = isSameDay(date, today());
    final label =
        '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
    return isToday ? '$label (Hari ini)' : label;
  }
}

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
import '../../widgets/monthly_calendar_grid.dart';

/// Riwayat/Kalender: kalender bulanan dengan gradasi warna + detail hari
/// (semua habit lintas kategori, bisa diedit/backfill). Tanpa AppBar/judul
/// halaman, persis prototipe (nav bawah sudah menandai halaman aktif).
/// Lihat DESIGN.md §4.3.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final month = ref.watch(selectedHistoryMonthProvider);
    final selectedDate = ref.watch(selectedHistoryDateProvider);
    final summariesAsync = ref.watch(monthSummariesProvider(month));

    final calendarCard = Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
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
            onSelectDate: (d) => ref.read(selectedHistoryDateProvider.notifier).state = d,
            onChangeMonth: (m) => ref.read(selectedHistoryMonthProvider.notifier).state = m,
          ),
        ),
      ),
    );

    final detailCard = Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _DayDetail(date: selectedDate),
      ),
    );

    if (isWide) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: calendarCard),
              const SizedBox(width: 24),
              Expanded(child: detailCard),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(isTablet ? 32 : 16, isTablet ? 32 : 20, isTablet ? 32 : 16, 24),
        children: [calendarCard, const SizedBox(height: 24), detailCard],
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
    final done = items.where((i) => i.isDone).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(_formatDate(date), style: theme.textTheme.titleLarge)),
            if (items.isNotEmpty)
              Text(
                '${((done / items.length) * 100).round()}%',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          Text('Tidak ada habit terjadwal hari ini.', style: theme.textTheme.bodySmall)
        else
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _toggle(ref, item),
                child: Row(
                  children: [
                    _MiniCheckbox(checked: item.isDone),
                    const SizedBox(width: 12),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorByCategory[item.habit.categoryId] ?? AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.habit.name, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  // Toggle penuh (selesai <-> semula), sama seperti Category Detail — tap
  // lagi setelah selesai membatalkannya kembali.
  Future<void> _toggle(WidgetRef ref, HabitWithProgress item) async {
    final repo = ref.read(habitLogRepositoryProvider);
    await repo.toggleDone(habit: item.habit, date: date, currentlyDone: item.isDone);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(monthSummariesProvider);
    ref.invalidate(daySummaryProvider);
  }

  String _formatDate(DateTime date) {
    final isToday = isSameDay(date, today());
    final label = formatFullDate(date);
    return isToday ? '$label (Hari ini)' : label;
  }
}

class _MiniCheckbox extends StatelessWidget {
  const _MiniCheckbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: checked ? theme.colorScheme.primary : theme.scaffoldBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: checked ? theme.colorScheme.primary : theme.dividerColor,
          width: 2,
        ),
      ),
      child: checked ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
    );
  }
}

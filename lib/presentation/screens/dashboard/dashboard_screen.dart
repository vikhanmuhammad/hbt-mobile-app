import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/models/dashboard_summary.dart';
import '../../../domain/models/habit_with_progress.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/habit_providers.dart';
import '../../../providers/progress_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../../providers/ui_state_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/daily_progress_ring.dart';
import '../../widgets/habit_icon.dart';
import '../../widgets/monthly_calendar_grid.dart';

/// Dashboard gabungan: kalender bulanan (dulu tab Riwayat terpisah) + filter
/// icon habit + ringkasan keberhasilan (ring, breakdown per kategori/habit,
/// tren bulanan). Tap tanggal di kalender membuka bottom sheet detail hari
/// itu (backfill progress). Filter habit di atas kalender mempersempit data
/// ring kalender & ringkasan cuma ke habit yang dipilih. Tanpa AppBar/judul
/// halaman, persis prototipe. Lihat DESIGN.md §4.3/§4.4.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedDashboardMonthProvider);
    final selectedDate = ref.watch(selectedDashboardDateProvider);
    final summariesAsync = ref.watch(monthSummariesProvider(month));
    final dashboardAsync = ref.watch(dashboardSummaryProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    const filterRow = _HabitFilterRow();

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
            onSelectDate: (d) {
              ref.read(selectedDashboardDateProvider.notifier).state = d;
              _showDayDetailSheet(context, d);
            },
            onChangeMonth: (m) =>
                ref.read(selectedDashboardMonthProvider.notifier).state = m,
          ),
        ),
      ),
    );

    final statsSection = dashboardAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Gagal memuat dashboard: $e'),
      ),
      data: (summary) {
        if (summary.totalLogs == 0) return const _EmptyDashboard();
        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryHeader(summary: summary),
                        const SizedBox(height: 20),
                        _CategoryBreakdown(summary: summary),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HabitBreakdown(summary: summary),
                        const SizedBox(height: 20),
                        _MonthlyTrend(summary: summary),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryHeader(summary: summary),
                  const SizedBox(height: 20),
                  _CategoryBreakdown(summary: summary),
                  const SizedBox(height: 20),
                  _HabitBreakdown(summary: summary),
                  const SizedBox(height: 20),
                  _MonthlyTrend(summary: summary),
                ],
              );
      },
    );

    if (isWide) {
      return Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    filterRow,
                    const SizedBox(height: 16),
                    calendarCard,
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(child: statsSection),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          isTablet ? 32 : 16,
          isTablet ? 32 : 20,
          isTablet ? 32 : 16,
          24,
        ),
        children: [
          filterRow,
          const SizedBox(height: 16),
          calendarCard,
          const SizedBox(height: 24),
          statsSection,
        ],
      ),
    );
  }

  Future<void> _showDayDetailSheet(BuildContext context, DateTime date) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DayDetailSheet(date: date),
    );
  }
}

/// Baris icon habit yang bisa discroll horizontal untuk memfilter kalender +
/// ringkasan dashboard. "All" (default) = tanpa filter. Multi-select: tiap
/// icon habit toggle independen.
class _HabitFilterRow extends ConsumerStatefulWidget {
  const _HabitFilterRow();

  @override
  ConsumerState<_HabitFilterRow> createState() => _HabitFilterRowState();
}

class _HabitFilterRowState extends ConsumerState<_HabitFilterRow> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftHint = false;
  bool _showRightHint = false;

  Color _scrollHintColor(ThemeData theme) {
    return theme.brightness == Brightness.light
        ? theme.colorScheme.onSurface.withValues(alpha: 0.65)
        : theme.colorScheme.onSurface.withValues(alpha: 0.78);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleScroll());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final canScroll = position.maxScrollExtent > 0;
    final showLeft = canScroll && position.pixels > 8;
    final showRight =
        canScroll && position.pixels < position.maxScrollExtent - 8;

    if (showLeft != _showLeftHint || showRight != _showRightHint) {
      if (!mounted) return;
      setState(() {
        _showLeftHint = showLeft;
        _showRightHint = showRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hintColor = _scrollHintColor(theme);
    final habits = ref.watch(allActiveHabitsProvider).value ?? const [];
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final selected = ref.watch(selectedDashboardHabitIdsProvider);

    if (habits.isEmpty) return const SizedBox.shrink();

    final colorByCategory = {
      for (var i = 0; i < categories.length; i++)
        categories[i].id: AppColors.categoryColorFromHex(
          categories[i].colorHex,
          i,
        ),
    };

    void toggleHabit(int habitId) {
      final next = Set<int>.from(selected);
      if (!next.remove(habitId)) next.add(habitId);
      ref.read(selectedDashboardHabitIdsProvider.notifier).state = next;
    }

    final isScrollable = _showLeftHint || _showRightHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Filter Habit', style: theme.textTheme.titleSmall),
            const SizedBox(width: 10),
            if (isScrollable)
              Row(
                children: [
                  Icon(Icons.swipe_rounded, size: 16, color: hintColor),
                  const SizedBox(width: 4),
                  Text(
                    'Geser untuk lihat lainnya',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: hintColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 78,
          child: Stack(
            children: [
              RawScrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: false,
                thickness: 4,
                radius: const Radius.circular(999),
                thumbColor: theme.colorScheme.primary.withValues(
                  alpha: theme.brightness == Brightness.light ? 0.65 : 0.8,
                ),
                child: ListView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: selected.isEmpty,
                      color: theme.colorScheme.primary,
                      child: const Icon(
                        Icons.apps_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      onTap: () =>
                          ref
                                  .read(
                                    selectedDashboardHabitIdsProvider.notifier,
                                  )
                                  .state =
                              <int>{},
                    ),
                    for (final habit in habits)
                      _FilterChip(
                        label: habit.name,
                        selected: selected.contains(habit.id),
                        color:
                            colorByCategory[habit.categoryId] ?? AppColors.gold,
                        child: HabitIcon(
                          icon: habit.icon,
                          size: 15,
                          color: Colors.white,
                        ),
                        onTap: () => toggleHabit(habit.id),
                      ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _showLeftHint ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      width: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            theme.colorScheme.surface,
                            theme.scaffoldBackgroundColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: hintColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _showRightHint ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      width: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            theme.colorScheme.surface,
                            theme.scaffoldBackgroundColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: hintColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.child,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 64,
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? color
                      : (theme.brightness == Brightness.light
                            ? AppColors.lightSurfaceAlt
                            : AppColors.darkSurfaceAlt),
                  shape: BoxShape.circle,
                  border: selected
                      ? null
                      : Border.all(color: theme.dividerColor),
                ),
                child: Center(
                  child: selected
                      ? child
                      : Opacity(opacity: 0.55, child: child),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? color : theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet detail 1 hari (checklist habit + toggle progress) — dibuka
/// dengan tap tanggal di kalender. Selalu menampilkan semua habit terjadwal
/// hari itu, tidak ikut filter icon habit (dipakai sebagai alat backfill,
/// bukan bagian dari ringkasan yang difilter).
class _DayDetailSheet extends ConsumerWidget {
  const _DayDetailSheet({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(habitsWithProgressForDateProvider(date));
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final colorByCategory = {
      for (var i = 0; i < categories.length; i++)
        categories[i].id: AppColors.categoryColorFromHex(
          categories[i].colorHex,
          i,
        ),
    };
    final done = items.where((i) => i.isDone).length;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                if (items.isNotEmpty)
                  Text(
                    '${((done / items.length) * 100).round()}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'Tidak ada habit terjadwal hari ini.',
                  style: theme.textTheme.bodySmall,
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return InkWell(
                      onTap: () => _toggle(context, ref, item),
                      child: Row(
                        children: [
                          _MiniCheckbox(checked: item.isDone),
                          const SizedBox(width: 12),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  colorByCategory[item.habit.categoryId] ??
                                  AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.habit.name,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    HabitWithProgress item,
  ) async {
    try {
      final repo = ref.read(habitLogRepositoryProvider);
      await repo.toggleDone(
        habit: item.habit,
        date: date,
        currentlyDone: item.isDone,
      );
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(monthSummariesProvider);
      ref.invalidate(daySummaryProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui progress: $e')),
        );
      }
    }
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
        color: checked
            ? theme.colorScheme.primary
            : theme.scaffoldBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: checked ? theme.colorScheme.primary : theme.dividerColor,
          width: 2,
        ),
      ),
      child: checked
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            const Text('Belum ada data untuk ditampilkan'),
            const SizedBox(height: 8),
            const Text(
              'Mulai centang habit hari ini supaya dashboard mulai terisi.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            DailyProgressRing(
              done: (summary.overallSuccessRate * 100).round(),
              total: 100,
              size: 84,
              strokeWidth: 9,
              centerLabel: '${(summary.overallSuccessRate * 100).round()}%',
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${summary.totalDaysTracked} hari tercatat',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rata-rata keberhasilan keseluruhan',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends ConsumerWidget {
  const _CategoryBreakdown({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider).value ?? [];
    final indexById = {
      for (var i = 0; i < categories.length; i++) categories[i].id: i,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Per Kategori', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            for (final stat in summary.categoryStats)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProgressRow(
                  label: stat.category.name,
                  ratio: stat.successRate,
                  color: AppColors.categoryColorFromHex(
                    stat.category.colorHex,
                    indexById[stat.category.id] ?? 0,
                  ),
                  showDot: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HabitBreakdown extends StatelessWidget {
  const _HabitBreakdown({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Per Habit', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            for (final stat in summary.habitStats)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProgressRow(
                  label: stat.habit.name,
                  ratio: stat.successRate,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyTrend extends StatelessWidget {
  const _MonthlyTrend({required this.summary});

  final DashboardSummary summary;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = summary.monthlyStats.length > 6
        ? summary.monthlyStats.sublist(summary.monthlyStats.length - 6)
        : summary.monthlyStats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tren Bulanan', style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in points)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            // Expanded gives this slot a bounded/tight height
                            // so FractionallySizedBox has something to size
                            // its heightFactor against — a bare Column doesn't
                            // bound non-flex children, which crashes it.
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: point.successRate.clamp(
                                    0.03,
                                    1,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 44,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(4),
                                          bottomRight: Radius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _months[point.month.month - 1],
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.ratio,
    required this.color,
    this.showDot = false,
  });

  final String label;
  final double ratio;
  final Color color;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (showDot) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text('${(ratio * 100).round()}%', style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            minHeight: 10,
            backgroundColor: theme.brightness == Brightness.light
                ? AppColors.lightSurfaceAlt
                : AppColors.darkSurfaceAlt,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

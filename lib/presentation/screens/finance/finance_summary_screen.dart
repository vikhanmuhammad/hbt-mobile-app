import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';

import '../../../domain/date_utils.dart';
import '../../../domain/format_utils.dart';
import '../../../domain/language.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/finance_summary.dart';
import '../../../domain/models/habit.dart';
import '../../../domain/models/habit_with_progress.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/community_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/finance_providers.dart';
import '../../../providers/habit_providers.dart';
import '../../../providers/progress_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../../providers/ui_state_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/category_breakdown_list.dart';
import '../../widgets/empty_state_illustration.dart';
import '../../widgets/finance_preview_mock.dart';
import '../../widgets/dashed_line.dart';
import '../../widgets/habit_progress_card.dart';
import '../../widgets/pro_feature_teaser.dart';
import '../../widgets/quick_progress_sheet.dart';
import '../../widgets/segmented_pill_toggle.dart';
import '../../widgets/spending_distribution_pie_chart.dart';
import '../add_habit/add_habit_flow_screen.dart';

/// Finance Summary: total expenses, amount saved, and savings deposits
/// from all rupiah-unit habits (across categories), per calendar month —
/// plus daily spending trend and a per-habit breakdown.
class FinanceSummaryScreen extends ConsumerWidget {
  const FinanceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isPro = ref.watch(isProProvider);
    if (!isPro) {
      return ProFeatureTeaser(
        icon: Icons.account_balance_wallet_rounded,
        title: l10n.financeProFeatureTitle,
        description: l10n.financeProFeatureDescription,
        benefits: [
          l10n.financeProBenefit1,
          l10n.financeProBenefit2,
          l10n.financeProBenefit3,
        ],
        previewBuilder: (context) => const FinancePreviewMock(),
      );
    }

    final period = ref.watch(selectedFinancePeriodProvider);
    final anchor = period == FinancePeriod.monthly
        ? ref.watch(selectedFinanceMonthProvider)
        : ref.watch(selectedFinanceAnchorDateProvider);
    final summaryAsync = ref.watch(
      financeSummaryForPeriodProvider(period, anchor),
    );
    // "Total Saved" must always read as the running saved-so-far since the
    // budget was set — from whichever day the budget habit started through
    // today (clamped, never projected past today) — regardless of which
    // Daily/Weekly/Monthly tab is active. Switching tabs re-slices
    // totalExpense/totalBudget to a narrower window, which made "Total
    // Saved" swing wildly instead of staying pinned to today's cumulative.
    // Only navigating to a different month resets it.
    final monthlySavedAsync = ref.watch(
      financeMonthToDateSummaryProvider(DateTime(anchor.year, anchor.month)),
    );
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    // Kategori Save Money cuma boleh 1 habit aktif — dicek di sini supaya
    // FAB bisa jadi jalan pintas edit begitu sudah ada (lihat di bawah).
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    int? financeCategoryId;
    for (final c in categories) {
      if (isFinanceCategory(c)) {
        financeCategoryId = c.id;
        break;
      }
    }
    final activeHabits =
        ref.watch(allActiveHabitsProvider).value ?? const <Habit>[];
    final pendingDeleteIds = ref.watch(pendingDeleteHabitIdsProvider);
    Habit? existingFinanceHabit;
    for (final h in activeHabits) {
      if (pendingDeleteIds.contains(h.id)) continue;
      if (h.categoryId == financeCategoryId) {
        existingFinanceHabit = h;
        break;
      }
    }

    return Scaffold(
      // Kategori Save Money cuma boleh 1 habit aktif — begitu sudah ada,
      // FAB ini jadi jalan pintas edit yang sudah ada alih-alih membuka
      // form tambah baru (yang toh akan diblokir oleh singleton guard).
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => existingFinanceHabit == null
            ? _openAddSpendingLimitHabit(context, ref)
            : openEditHabitFlow(context, existingFinanceHabit),
        icon: Icon(
          existingFinanceHabit == null ? Icons.add_rounded : Icons.edit_rounded,
        ),
        label: Text(
          existingFinanceHabit == null
              ? l10n.financeAddSpendingLimit
              : l10n.financeEditSpendingLimit,
        ),
      ),
      body: FadeSlideIn(
        child: ListView(
          // Extra bottom padding clears the "Add Spending Limit" FAB (#27) so
          // it doesn't sit on top of the last card in the list.
          padding: EdgeInsets.fromLTRB(
            isTablet ? 32 : 16,
            isTablet ? 32 : 20,
            isTablet ? 32 : 16,
            96,
          ),
          children: [
            SegmentedPillToggle<FinancePeriod>(
              segments: [
                PillSegment(
                  value: FinancePeriod.daily,
                  label: l10n.financePeriodDaily,
                ),
                PillSegment(
                  value: FinancePeriod.weekly,
                  label: l10n.financePeriodWeekly,
                ),
                PillSegment(
                  value: FinancePeriod.monthly,
                  label: l10n.financePeriodMonthly,
                ),
              ],
              selected: period,
              onChanged: (p) =>
                  ref.read(selectedFinancePeriodProvider.notifier).state = p,
            ),
            const SizedBox(height: 14),
            _PeriodNav(
              period: period,
              anchor: anchor,
              onChangeAnchor: (d) {
                if (period == FinancePeriod.monthly) {
                  ref.read(selectedFinanceMonthProvider.notifier).state = d;
                } else {
                  ref.read(selectedFinanceAnchorDateProvider.notifier).state =
                      d;
                }
              },
            ),
            if (existingFinanceHabit != null) ...[
              const SizedBox(height: 16),
              _TodayProgressCard(habit: existingFinanceHabit),
            ],
            const SizedBox(height: 20),
            summaryAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.financeFailedToLoad('$e')),
              ),
              data: (summary) {
                if (!summary.hasData) return const _EmptyFinance();
                // Falls back to the period summary's own totalSaved while
                // the month summary is (re)loading, so the chip doesn't
                // blank out momentarily on tab/anchor changes.
                final totalSaved =
                    monthlySavedAsync.value?.totalSaved ?? summary.totalSaved;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TotalsSection(summary: summary, totalSaved: totalSaved),
                    if (summary.categoryBreakdown.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      SpendingDistributionPieChart(
                        items: [
                          for (final stat in summary.categoryBreakdown)
                            CategoryBreakdownItem(
                              category: stat.category,
                              label: stat.label,
                              amount: stat.totalAmount,
                            ),
                        ],
                        currencyPrefix: summary.currencyPrefix,
                      ),
                    ],
                    if (summary.dailyTrend.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SpendingTrendCard(summary: summary, period: period),
                    ],
                    const SizedBox(height: 20),
                    _HabitBreakdownCard(summary: summary, period: period, anchor: anchor),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Jumps straight to the Spending Money singleton form — daily/weekly/
  /// monthly + goalValue, no template picker (kategori Save Money cuma
  /// pernah punya 1 jenis habit sekarang). Logging today's progress against
  /// it is now also available inline via [_TodayProgressCard] above.
  Future<void> _openAddSpendingLimitHabit(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await openBudgetTrackerFlow(context);
  }
}

/// Lets the Budget Tracker habit's progress for *today* be logged right from
/// the Finance page — previously the only way to add today's spending/saving
/// was to go back to Home and tap the card there. Mirrors Home's own
/// tap-to-log flow (`_onTapCard` in home_screen.dart) exactly, just scoped to
/// this one habit.
class _TodayProgressCard extends ConsumerWidget {
  const _TodayProgressCard({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(habitsWithProgressForDateProvider(today()));
    HabitWithProgress? item;
    for (final i in items) {
      if (i.habit.id == habit.id) {
        item = i;
        break;
      }
    }
    // Not active today (e.g. outside its schedule/date range) — nothing to
    // log for "today" specifically.
    if (item == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final indonesian = ref.watch(appLanguageProvider) == AppLang.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          indonesian ? 'Progres Hari Ini' : "Today's Progress",
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        HabitProgressCard(
          item: item,
          accentColor: theme.colorScheme.primary,
          isEditMode: false,
          onTap: () => _logTodayProgress(context, ref, item!),
        ),
      ],
    );
  }

  Future<void> _logTodayProgress(
    BuildContext context,
    WidgetRef ref,
    HabitWithProgress item,
  ) async {
    final repo = ref.read(habitLogRepositoryProvider);
    try {
      final result = await showQuickProgressSheet(context, item);
      if (result == null) return;
      await repo.applyPeriodAwareEdit(
        habit: item.habit,
        date: item.date,
        previousPeriodTotal: item.progressValue,
        newPeriodTotal: result.value,
      );
      if (result.breakdownItems.isNotEmpty) {
        await ref.read(spendingBreakdownRepositoryProvider).addEntries(
              habitId: item.habit.id,
              date: item.date,
              entries: result.breakdownItems,
            );
      }
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(monthSummariesProvider);
      ref.invalidate(daySummaryProvider);
      ref.invalidate(financeSummaryProvider);
      ref.invalidate(financeSummaryForPeriodProvider);
      ref.invalidate(financeMonthToDateSummaryProvider);
      ref.invalidate(habitsWithProgressForDateProvider(item.date));
      unawaited(syncCommunityHabit(ref, item.habit.id, item.date));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.homeFailedToSaveProgress('$e'))),
        );
      }
    }
  }
}

/// Prev/next navigator whose step size and label follow the selected
/// [FinancePeriod] — a day, a week, or a calendar month at a time.
class _PeriodNav extends ConsumerWidget {
  const _PeriodNav({
    required this.period,
    required this.anchor,
    required this.onChangeAnchor,
  });

  final FinancePeriod period;
  final DateTime anchor;
  final ValueChanged<DateTime> onChangeAnchor;

  String _label(AppLang lang) {
    switch (period) {
      case FinancePeriod.daily:
        return '${anchor.day} ${monthFullName(anchor.month, lang)} ${anchor.year}';
      case FinancePeriod.weekly:
        final (start, end) = financePeriodRange(FinancePeriod.weekly, anchor);
        final sameMonth = start.month == end.month;
        final startLabel = sameMonth
            ? '${start.day}'
            : '${start.day} ${monthFullName(start.month, lang)}';
        return '$startLabel–${end.day} ${monthFullName(end.month, lang)} ${end.year}';
      case FinancePeriod.monthly:
        return '${monthFullName(anchor.month, lang)} ${anchor.year}';
    }
  }

  DateTime _step(int direction) {
    switch (period) {
      case FinancePeriod.daily:
        return anchor.add(Duration(days: direction));
      case FinancePeriod.weekly:
        return anchor.add(Duration(days: 7 * direction));
      case FinancePeriod.monthly:
        return DateTime(anchor.year, anchor.month + direction);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lang = ref.watch(appLanguageProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavCircleButton(
          icon: Icons.chevron_left_rounded,
          onTap: () => onChangeAnchor(_step(-1)),
        ),
        Expanded(
          // The weekly label ("31 Agustus–6 September 2026") can run long
          // enough at titleLarge to get clipped by maxLines:1 ellipsis —
          // FittedBox scales the whole label down to fit instead of cutting
          // it off, so the full date range always stays readable.
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _label(lang),
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                  if (period == FinancePeriod.daily) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: anchor,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) onChangeAnchor(picked);
                      },
                      child: Icon(Icons.calendar_today_rounded, size: 18, color: theme.colorScheme.primary),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        _NavCircleButton(
          icon: Icons.chevron_right_rounded,
          onTap: () => onChangeAnchor(_step(1)),
        ),
      ],
    );
  }
}

class _NavCircleButton extends StatelessWidget {
  const _NavCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 36, height: 36, child: Icon(icon)),
      ),
    );
  }
}

class _EmptyFinance extends StatelessWidget {
  const _EmptyFinance();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EmptyStateIllustration(variant: EmptyStateVariant.wallet),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.financeNoFinanceHabitsYet),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.financeEmptyHint,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalsSection extends StatelessWidget {
  const _TotalsSection({required this.summary, required this.totalSaved});

  final FinanceSummary summary;

  /// Calendar month-to-date saved (budget minus expense from the 1st
  /// through today) — always month-scoped regardless of the active
  /// Daily/Weekly/Monthly tab. See the call site for why this isn't just
  /// `summary.totalSaved`.
  final int totalSaved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final saved = totalSaved;
    final isOverBudget = saved < 0;
    final hasBudget = summary.totalBudget > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.financeTotalSpending,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasBudget) ...[
                      const SizedBox(width: 8),
                      _BudgetPaceChip(pace: summary.paceAt(DateTime.now())),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  formatCurrency(summary.totalExpense, summary.currencyPrefix),
                  style: theme.textTheme.headlineMedium,
                ),
                if (hasBudget) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (summary.totalExpense / summary.totalBudget)
                          .clamp(0, 1)
                          .toDouble(),
                      minHeight: 8,
                      backgroundColor: theme.brightness == Brightness.light
                          ? AppColors.lightSurfaceAlt
                          : AppColors.darkSurfaceAlt,
                      valueColor: AlwaysStoppedAnimation(
                        isOverBudget
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.financeOfBudget(formatCurrency(summary.totalBudget, summary.currencyPrefix)),
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _StatChip(
            label: isOverBudget
                ? l10n.financeOverBudget
                : l10n.financeTotalSaved,
            value: formatCurrency(saved.abs(), summary.currencyPrefix),
            color: isOverBudget
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            icon: isOverBudget
                ? Icons.trending_up_rounded
                : Icons.savings_rounded,
          ),
        ),
        // Saving/deposit info kept much smaller than spending above — this
        // page is primarily for tracking spending, not savings (see #24).
        if (summary.totalSavingsTarget > 0) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.savings_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${l10n.financeSaveMoneyGoal}: '
                    '${formatCurrency(summary.totalSavingsDeposit, summary.currencyPrefix)} / '
                    '${formatCurrency(summary.totalSavingsTarget, summary.currencyPrefix)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Green "On Track" / red "Overspending" pill — compares how far through the
/// budget period we are against how much of the budget is already spent
/// (see [FinanceSummary.paceAt]). Hidden when pacing isn't meaningful (e.g.
/// viewing a past/future period).
class _BudgetPaceChip extends StatelessWidget {
  const _BudgetPaceChip({required this.pace});

  final BudgetPace? pace;

  @override
  Widget build(BuildContext context) {
    final pace = this.pace;
    if (pace == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final (color, icon, label) = switch (pace.status) {
      BudgetPaceStatus.onTrack => (
        const Color(0xFF3E9B5C),
        // A downward trend arrow read as "getting worse" next to the "On
        // Track" label even though it meant spending pace is healthy — a
        // check mark reads as unambiguously positive instead.
        Icons.check_circle_rounded,
        l10n.financeOnTrack,
      ),
      BudgetPaceStatus.warning => (
        const Color(0xFFD9A441),
        Icons.trending_flat_rounded,
        l10n.financeApproachingLimit,
      ),
      BudgetPaceStatus.overBudget => (
        const Color(0xFFD1544A),
        Icons.trending_up_rounded,
        l10n.financeOverspending,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingTrendCard extends StatefulWidget {
  const _SpendingTrendCard({required this.summary, required this.period});

  final FinanceSummary summary;
  final FinancePeriod period;

  @override
  State<_SpendingTrendCard> createState() => _SpendingTrendCardState();
}

class _SpendingTrendCardState extends State<_SpendingTrendCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _grow;

  @override
  void initState() {
    super.initState();
    // Same treatment as HabitCurveChart: start after the page transition has
    // settled, and slow enough (1600ms) to actually read as motion instead
    // of finishing before the bars are even visible.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _grow = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _trendTitle(AppLocalizations l10n) => switch (widget.period) {
    FinancePeriod.daily => l10n.financeDailySpendingTrend,
    FinancePeriod.weekly => l10n.financeWeeklySpendingTrend,
    FinancePeriod.monthly => l10n.financeMonthlySpendingTrend,
  };

  /// Abbreviated Y-axis tick label so the axis column stays narrow even for
  /// large rupiah amounts — e.g. 1.500.000 -> "1,5jt", 250.000 -> "250rb".
  String _axisLabel(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}jt';
    if (value >= 1000) return '${(value / 1000).round()}rb';
    return '$value';
  }

  /// X-axis label for one trend point — a single day number for day-bucketed
  /// points, or a short date range for week-bucketed ones (Monthly tab).
  String _pointLabel(FinanceDayPoint point) {
    if (!point.isMultiDayBucket) return '${point.date.day}';
    return '${point.date.day}-${point.bucketEndInclusive.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final points = widget.summary.dailyTrend;
    final maxValue = points.fold<int>(
      0,
      (m, p) => p.totalExpense > m ? p.totalExpense : m,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _trendTitle(l10n),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: maxValue == 0
                  ? Center(
                      child: Text(
                        l10n.financeNoDataYet,
                        style: theme.textTheme.bodySmall,
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Y-axis: max/mid/0 ticks aligned to the 150px-tall
                        // bar area below (+ its bottom date-label row).
                        SizedBox(
                          width: 40,
                          height: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(_axisLabel(maxValue), style: theme.textTheme.labelSmall),
                              Text(_axisLabel(maxValue ~/ 2), style: theme.textTheme.labelSmall),
                              Text('0', style: theme.textTheme.labelSmall),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _grow,
                            builder: (context, _) => LayoutBuilder(
                              builder: (context, constraints) => SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  // This lives inside a horizontally-scrolling
                                  // child, so the incoming width constraint
                                  // is unbounded (maxWidth: infinity) — the
                                  // gridlines' `DashedLine` wants to stretch
                                  // to fill that width, but resolving
                                  // `width: double.infinity` against a truly
                                  // infinite constraint crashes layout
                                  // ("BoxConstraints forces an infinite
                                  // width"), which silently blanked out this
                                  // whole chart. `IntrinsicWidth` resolves a
                                  // concrete width first (from the bars
                                  // Row's own intrinsic content width) and
                                  // hands that bounded width down instead.
                                  child: IntrinsicWidth(
                                    child: Stack(
                                    children: [
                                      // Gridlines at the 0/50/100% ticks so bar
                                      // heights can be read against the Y-axis.
                                      SizedBox(
                                        height: 150,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            DashedLine(),
                                            DashedLine(),
                                            DashedLine(),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          for (final point in points)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    height: 150,
                                                    child: Align(
                                                      alignment: Alignment.bottomCenter,
                                                      child: FractionallySizedBox(
                                                        heightFactor:
                                                            ((point.totalExpense / maxValue)
                                                                        .clamp(0.04, 1) *
                                                                    _grow.value)
                                                                .clamp(0.001, 1)
                                                                .toDouble(),
                                                        child: Container(
                                                          width: 24,
                                                          decoration: BoxDecoration(
                                                            color: theme.colorScheme.primary,
                                                            borderRadius:
                                                                const BorderRadius.only(
                                                                  topLeft: Radius.circular(4),
                                                                  topRight: Radius.circular(
                                                                    4,
                                                                  ),
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    _pointLabel(point),
                                                    style: theme.textTheme.labelSmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                    ),
                                  ),
                                ),
                              ),
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

/// Spending consolidated by category (§CategoryBreakdownList) across ALL
/// Budget Tracker habits in this window — supersedes the old per-habit "By
/// Habit" list, since with a single Budget Tracker habit "by habit" carried
/// no information the totals card didn't already show.
/// "Spending by Category" — consolidated across ALL Budget Tracker habits in
/// the active Daily/Weekly/Monthly window. When the Monthly tab is showing
/// the current, still-in-progress calendar month, this data IS the "Month to
/// Date" figure (same category-consolidated totals, just scoped by the
/// active period instead of a separate calendar-month query) — a small
/// badge marks that explicitly instead of duplicating the same numbers in a
/// second section, which is what the standalone "Month to Date" card used to
/// do before it was merged in here. A finished past month gets a "Monthly
/// Total" badge instead, since that data is final. Daily/Weekly tabs show no
/// badge — MTD/Monthly-Total framing only applies to calendar-month scope.
class _HabitBreakdownCard extends StatelessWidget {
  const _HabitBreakdownCard({required this.summary, required this.period, required this.anchor});

  final FinanceSummary summary;
  final FinancePeriod period;
  final DateTime anchor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    if (summary.categoryBreakdown.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final isCurrentMonth = anchor.year == now.year && anchor.month == now.month;
    final monthBadgeLabel =
        period != FinancePeriod.monthly ? null : (isCurrentMonth ? l10n.financeMonthToDate : l10n.financeMonthlyTotal);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  l10n.financeSpendingByCategory,
                  style: theme.textTheme.titleMedium,
                ),
                if (monthBadgeLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      monthBadgeLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            CategoryBreakdownList(
              items: [
                for (final stat in summary.categoryBreakdown)
                  CategoryBreakdownItem(category: stat.category, label: stat.label, amount: stat.totalAmount),
              ],
              currencyPrefix: summary.currencyPrefix,
            ),
          ],
        ),
      ),
    );
  }
}


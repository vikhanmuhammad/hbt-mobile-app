import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/format_utils.dart';
import '../../../domain/language.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/finance_summary.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/community_providers.dart';
import '../../../providers/finance_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../../providers/ui_state_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/empty_state_illustration.dart';
import '../../widgets/finance_preview_mock.dart';
import '../../widgets/habit_icon.dart';
import '../../widgets/pro_feature_teaser.dart';
import '../../widgets/segmented_pill_toggle.dart';

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
    final summaryAsync = ref.watch(financeSummaryForPeriodProvider(period, anchor));
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      body: FadeSlideIn(
        child: ListView(
        padding: EdgeInsets.fromLTRB(isTablet ? 32 : 16, isTablet ? 32 : 20, isTablet ? 32 : 16, 24),
        children: [
          SegmentedPillToggle<FinancePeriod>(
            segments: [
              PillSegment(value: FinancePeriod.daily, label: l10n.financePeriodDaily),
              PillSegment(value: FinancePeriod.weekly, label: l10n.financePeriodWeekly),
              PillSegment(value: FinancePeriod.monthly, label: l10n.financePeriodMonthly),
            ],
            selected: period,
            onChanged: (p) => ref.read(selectedFinancePeriodProvider.notifier).state = p,
          ),
          const SizedBox(height: 14),
          _PeriodNav(
            period: period,
            anchor: anchor,
            onChangeAnchor: (d) {
              if (period == FinancePeriod.monthly) {
                ref.read(selectedFinanceMonthProvider.notifier).state = d;
              } else {
                ref.read(selectedFinanceAnchorDateProvider.notifier).state = d;
              }
            },
          ),
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TotalsSection(summary: summary),
                  if (summary.dailyTrend.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SpendingTrendCard(summary: summary),
                  ],
                  const SizedBox(height: 20),
                  _HabitBreakdownCard(summary: summary),
                ],
              );
            },
          ),
        ],
        ),
      ),
    );
  }
}

/// Prev/next navigator whose step size and label follow the selected
/// [FinancePeriod] — a day, a week, or a calendar month at a time.
class _PeriodNav extends ConsumerWidget {
  const _PeriodNav({required this.period, required this.anchor, required this.onChangeAnchor});

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
        final startLabel = sameMonth ? '${start.day}' : '${start.day} ${monthFullName(start.month, lang)}';
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
        _NavCircleButton(icon: Icons.chevron_left_rounded, onTap: () => onChangeAnchor(_step(-1))),
        Text(_label(lang), style: theme.textTheme.titleLarge),
        _NavCircleButton(icon: Icons.chevron_right_rounded, onTap: () => onChangeAnchor(_step(1))),
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
  const _TotalsSection({required this.summary});

  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final saved = summary.totalSaved;
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.financeTotalSpending, style: theme.textTheme.bodyMedium),
                    if (hasBudget) _BudgetPaceChip(pace: summary.paceAt(DateTime.now())),
                  ],
                ),
                const SizedBox(height: 6),
                Text(formatRupiah(summary.totalExpense), style: theme.textTheme.headlineMedium),
                if (hasBudget) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (summary.totalExpense / summary.totalBudget).clamp(0, 1).toDouble(),
                      minHeight: 8,
                      backgroundColor: theme.brightness == Brightness.light
                          ? AppColors.lightSurfaceAlt
                          : AppColors.darkSurfaceAlt,
                      valueColor: AlwaysStoppedAnimation(
                        isOverBudget ? theme.colorScheme.error : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.financeOfBudget(formatRupiah(summary.totalBudget)),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (summary.totalSavingsTarget > 0) ...[
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.financeSaveMoneyGoal, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(
                    '${formatRupiah(summary.totalSavingsDeposit)} / ${formatRupiah(summary.totalSavingsTarget)}',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (summary.totalSavingsDeposit / summary.totalSavingsTarget).clamp(0, 1).toDouble(),
                      minHeight: 8,
                      backgroundColor: theme.brightness == Brightness.light
                          ? AppColors.lightSurfaceAlt
                          : AppColors.darkSurfaceAlt,
                      valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatChip(
                label: isOverBudget ? l10n.financeOverBudget : l10n.financeTotalSaved,
                value: formatRupiah(saved.abs()),
                color: isOverBudget ? theme.colorScheme.error : theme.colorScheme.primary,
                icon: isOverBudget ? Icons.trending_up_rounded : Icons.savings_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatChip(
                label: l10n.financeTotalDeposited,
                value: formatRupiah(summary.totalSavingsDeposit),
                color: theme.colorScheme.primary,
                icon: Icons.account_balance_wallet_rounded,
              ),
            ),
          ],
        ),
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
    final color = pace.onTrack ? const Color(0xFF3E9B5C) : const Color(0xFFD1544A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(pace.onTrack ? Icons.trending_down_rounded : Icons.trending_up_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            pace.onTrack
                ? AppLocalizations.of(context)!.financeOnTrack
                : AppLocalizations.of(context)!.financeOverspending,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 10),
            Text(label, style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingTrendCard extends StatefulWidget {
  const _SpendingTrendCard({required this.summary});

  final FinanceSummary summary;

  @override
  State<_SpendingTrendCard> createState() => _SpendingTrendCardState();
}

class _SpendingTrendCardState extends State<_SpendingTrendCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _grow;

  @override
  void initState() {
    super.initState();
    // Same treatment as HabitCurveChart: start after the page transition has
    // settled, and slow enough (1600ms) to actually read as motion instead
    // of finishing before the bars are even visible.
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = widget.summary.dailyTrend;
    final maxValue = points.fold<int>(0, (m, p) => p.totalExpense > m ? p.totalExpense : m);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.financeDailySpendingTrend, style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: maxValue == 0
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.financeNoDataYet,
                        style: theme.textTheme.bodySmall,
                      ),
                    )
                  : AnimatedBuilder(
                      animation: _grow,
                      builder: (context, _) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final point in points)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: FractionallySizedBox(
                                          heightFactor: ((point.totalExpense / maxValue).clamp(0.04, 1) * _grow.value)
                                              .clamp(0.001, 1)
                                              .toDouble(),
                                          child: Container(
                                            width: 20,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(4),
                                                topRight: Radius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text('${point.date.day}', style: theme.textTheme.labelSmall),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitBreakdownCard extends StatelessWidget {
  const _HabitBreakdownCard({required this.summary});

  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.commonByHabit, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            for (final stat in summary.habitStats)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _HabitFinanceRow(stat: stat),
              ),
          ],
        ),
      ),
    );
  }
}

class _HabitFinanceRow extends ConsumerWidget {
  const _HabitFinanceRow({required this.stat});

  final FinanceHabitStat stat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lang = ref.watch(appLanguageProvider);
    final habit = stat.habit;
    final isAtMost = habit.goalDirection == GoalDirection.atMost;
    final overBudget = isAtMost && stat.totalValue > stat.totalTarget;
    final ratio = isAtMost
        ? (stat.totalTarget == 0 ? 0.0 : (stat.totalValue / stat.totalTarget).clamp(0, 1).toDouble())
        : (stat.loggedPeriods == 0 ? 0.0 : stat.achievedPeriods / stat.loggedPeriods);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
              child: Center(child: HabitIcon(icon: habit.icon, size: 13, color: Colors.white)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                habit.displayName(lang),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              isAtMost
                  ? '${formatRupiah(stat.totalValue)} / ${formatRupiah(stat.totalTarget)}'
                  : formatRupiah(stat.totalValue),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor:
                theme.brightness == Brightness.light ? AppColors.lightSurfaceAlt : AppColors.darkSurfaceAlt,
            valueColor: AlwaysStoppedAnimation(overBudget ? theme.colorScheme.error : theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

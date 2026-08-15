import 'package:flutter/material.dart';

import '../../domain/date_utils.dart';
import '../../domain/models/day_summary.dart';
import '../theme/app_colors.dart';
import 'daily_progress_ring.dart';

const _monthNames = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

const _weekdayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

/// Kalender bulanan — tiap sel tanggal menampilkan ring progress kecil
/// (mini donut chart) mewakili persentase capaian hari itu. CLAUDE.md v3 §7.
class MonthlyCalendarGrid extends StatelessWidget {
  const MonthlyCalendarGrid({
    super.key,
    required this.month,
    required this.summaries,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onChangeMonth,
  });

  final DateTime month;
  final List<DaySummary> summaries;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<DateTime> onChangeMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstDay = DateTime(month.year, month.month, 1);
    final leadingBlanks = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final summaryByDay = {for (final s in summaries) s.date.day: s};
    final now = today();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavCircleButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => onChangeMonth(DateTime(month.year, month.month - 1)),
            ),
            Text(
              '${_monthNames[month.month - 1]} ${month.year}',
              style: theme.textTheme.titleLarge,
            ),
            _NavCircleButton(
              icon: Icons.chevron_right_rounded,
              onTap: () => onChangeMonth(DateTime(month.year, month.month + 1)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final h in _weekdayHeaders)
              Expanded(
                child: Center(
                  child: Text(
                    h,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: leadingBlanks + daysInMonth,
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox.shrink();
            final day = index - leadingBlanks + 1;
            final date = DateTime(month.year, month.month, day);
            final summary = summaryByDay[day];
            final isToday = isSameDay(date, now);
            final isSelected = isSameDay(date, selectedDate);

            return _DayCell(
              day: day,
              summary: summary,
              isToday: isToday,
              isSelected: isSelected,
              onTap: () => onSelectDate(date),
            );
          },
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
    return Material(
      color: Theme.of(context).cardColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 36, height: 36, child: Icon(icon, size: 20)),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.summary,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final int day;
  final DaySummary? summary;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = summary?.hasData ?? false;
    final ratio = summary?.ratio ?? 0;

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.12) : null,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : isToday
                    ? AppColors.gold
                    : Colors.transparent,
            width: isSelected || isToday ? 1.5 : 0,
          ),
        ),
        alignment: Alignment.center,
        child: hasData
            ? DailyProgressRing(
                done: (ratio * 100).round(),
                total: 100,
                size: 34,
                strokeWidth: 3,
                centerLabel: '$day',
                centerLabelStyle:
                    theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 12),
              )
            : Text(
                '$day',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

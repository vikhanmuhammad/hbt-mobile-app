import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/date_utils.dart';
import '../../domain/models/day_summary.dart';
import '../../domain/models/enums.dart';
import '../../providers/settings_providers.dart';
import 'animations/tap_scale.dart';
import 'daily_progress_ring.dart';

/// Strip tanggal horizontal untuk 1 bulan — hari terpilih diberi ring
/// progress. CLAUDE.md v3 §6.1.
class DateStrip extends StatefulWidget {
  const DateStrip({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.summaries,
    required this.onSelectDate,
  });

  final DateTime month;
  final DateTime selectedDate;
  final List<DaySummary> summaries;
  final ValueChanged<DateTime> onSelectDate;

  @override
  State<DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<DateStrip> {
  final _controller = ScrollController();
  static const _itemWidth = 60.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected(false));
  }

  @override
  void didUpdateWidget(DateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(oldWidget.selectedDate, widget.selectedDate) ||
        oldWidget.month != widget.month) {
      _scrollToSelected(true);
    }
  }

  void _scrollToSelected(bool animate) {
    if (!_controller.hasClients) return;
    final daysInMonth = DateTime(widget.month.year, widget.month.month + 1, 0).day;
    final index = (widget.selectedDate.day - 1).clamp(0, daysInMonth - 1);
    final viewportWidth = _controller.position.viewportDimension;
    final target = (index * _itemWidth) - (viewportWidth / 2) + (_itemWidth / 2);
    final clamped = target.clamp(0.0, _controller.position.maxScrollExtent);
    if (animate) {
      _controller.animateTo(clamped, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _controller.jumpTo(clamped);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(widget.month.year, widget.month.month + 1, 0).day;
    final byDay = {for (final s in widget.summaries) s.date.day: s};

    // 74 is tuned for a 1x text scale; on a device with a larger font/display
    // size setting (common for elder users), the weekday label + ring column
    // grows taller than that fixed height and overflows. Growing the strip
    // proportionally with the text scale keeps it from clipping.
    final textScale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.3);
    return SizedBox(
      height: 74 * textScale,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
          final day = DateTime(widget.month.year, widget.month.month, index + 1);
          final isSelected = isSameDay(day, widget.selectedDate);
          final summary = byDay[day.day];
          return _DateStripItem(
            day: day,
            selected: isSelected,
            ratio: summary?.ratio ?? 0,
            hasData: summary?.hasData ?? false,
            onTap: () => widget.onSelectDate(day),
          );
        },
      ),
    );
  }
}

class _DateStripItem extends ConsumerWidget {
  const _DateStripItem({
    required this.day,
    required this.selected,
    required this.ratio,
    required this.hasData,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final double ratio;
  final bool hasData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lang = ref.watch(appLanguageProvider);
    final weekdayText = weekdayLabel(weekdayKeys[day.weekday - 1], lang);
    final isToday = isSameDay(day, today());

    return TapScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weekdayText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected ? theme.colorScheme.primary : null,
                    fontWeight: selected ? FontWeight.w700 : null,
                  ),
                ),
                const SizedBox(height: 6),
                // Every day with logged progress gets its own ring (#3) —
                // not just the selected one — so scrolling back through the
                // month still shows how each day went, matching the
                // Dashboard's monthly calendar grid. The selected day's ring
                // is just drawn a bit bigger/bolder to stay the obvious focal
                // point.
                if (hasData)
                  DailyProgressRing(
                    done: (ratio * 100).round(),
                    total: 100,
                    size: selected ? 40 : 36,
                    strokeWidth: selected ? 3 : 2.5,
                    centerLabel: '${day.day}',
                    centerLabelStyle: selected
                        ? null
                        : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 12),
                  )
                else
                  Container(
                    width: selected ? 40 : 36,
                    height: selected ? 40 : 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? theme.colorScheme.primary.withValues(alpha: 0.12) : null,
                      border: selected
                          ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                          : isToday
                              ? Border.all(color: theme.dividerColor, width: 1.5)
                              : null,
                    ),
                    child: Text(
                      '${day.day}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: selected ? theme.colorScheme.primary : null,
                        fontWeight: selected ? FontWeight.w800 : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

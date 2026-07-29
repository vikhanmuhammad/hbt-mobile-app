import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Ring progress dipakai di 3 level: Beranda (semua kategori), Category
/// Detail (1 kategori), dan Dashboard (keseluruhan). Lihat DESIGN.md §5.
class DailyProgressRing extends StatelessWidget {
  const DailyProgressRing({
    super.key,
    required this.done,
    required this.total,
    this.size = 96,
    this.strokeWidth = 10,
    this.color,
    this.centerLabel,
    this.centerSubLabel,
  });

  final int done;
  final int total;
  final double size;
  final double strokeWidth;
  final Color? color;
  final String? centerLabel;
  final String? centerSubLabel;

  double get _ratio => total == 0 ? 0 : (done / total).clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringColor = color ?? theme.colorScheme.primary;
    final trackColor = theme.brightness == Brightness.light
        ? AppColors.lightNotDone
        : AppColors.darkNotDone;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              color: trackColor,
            ),
          ),
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _ratio),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: strokeWidth,
                color: ringColor,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerLabel ?? '$done/$total',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (centerSubLabel != null)
                Text(
                  centerSubLabel!,
                  style: theme.textTheme.labelSmall,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

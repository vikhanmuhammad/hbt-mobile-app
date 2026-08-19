import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A single row of equal-width pill segments inside one rounded capsule —
/// matches the app's soft/rounded visual language (see `_SelectablePill` in
/// `add_habit_flow_screen.dart`) instead of Flutter's default Material
/// `SegmentedButton`, whose boxier outlined-segments look clashed with the
/// rest of the app (point: Finance Daily/Weekly/Monthly toggle).
class SegmentedPillToggle<T> extends StatelessWidget {
  const SegmentedPillToggle({super.key, required this.segments, required this.selected, required this.onChanged});

  final List<PillSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? AppColors.lightSurfaceAlt : AppColors.darkSurfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final segment in segments)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(segment.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: segment.value == selected ? theme.colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: segment.value == selected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    segment.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: segment.value == selected ? Colors.white : theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PillSegment<T> {
  const PillSegment({required this.value, required this.label});

  final T value;
  final String label;
}

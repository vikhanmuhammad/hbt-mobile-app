import 'package:flutter/material.dart';

/// Horizontal dashed gridline — used behind bar charts (Dashboard's Monthly
/// Trend, Finance's Spending Trend) to connect each Y-axis tick across to
/// the bars, since a plain `Divider` at the theme's default border color
/// read as too faint/easy to miss against the bars.
class DashedLine extends StatelessWidget {
  const DashedLine({
    super.key,
    this.color,
    this.strokeWidth = 1,
    this.dashWidth = 4,
    this.gapWidth = 3,
  });

  final Color? color;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ??
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.22);
    return SizedBox(
      height: strokeWidth,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: lineColor,
          strokeWidth: strokeWidth,
          dashWidth: dashWidth,
          gapWidth: gapWidth,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.gapWidth,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      final next = (x + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(next, y), paint);
      x = next + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.gapWidth != gapWidth;
}

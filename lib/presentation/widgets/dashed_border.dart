import 'package:flutter/material.dart';

/// Border putus-putus, dipakai untuk tile/tombol "+ Tambah Kategori" dan
/// "Buat Kategori Baru" di prototipe (`border:1.5px dashed`).
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.color,
    this.strokeWidth = 1.5,
    this.onTap,
  });

  final Widget child;
  final double borderRadius;
  final Color? color;
  final double strokeWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = color ?? Theme.of(context).dividerColor;
    return CustomPaint(
      painter: _DashedRRectPainter(
        color: borderColor,
        radius: borderRadius,
        strokeWidth: strokeWidth,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    this.dashWidth = 6,
    this.gapWidth = 4,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
          size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth;
}

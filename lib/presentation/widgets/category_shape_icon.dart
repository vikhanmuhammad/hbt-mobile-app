import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 5 token bentuk ikon kategori, persis prototipe (`ICON_TOKENS` di
/// `docs/Habit Tracker.html`): circle, square, diamond, leaf, bolt — bentuk
/// geometris polos, bukan icon set semantik.
const List<String> categoryIconTokens = ['circle', 'square', 'diamond', 'leaf', 'bolt'];

/// Glyph putih kecil di dalam bulatan warna kategori, meniru
/// `iconStyleFor()` di prototipe persis (border-radius/transform/clip-path).
class CategoryShapeIcon extends StatelessWidget {
  const CategoryShapeIcon({
    super.key,
    required this.token,
    this.size = 18,
    this.color = Colors.white,
  });

  final String? token;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    switch (token) {
      case 'square':
        return _shape(borderRadius: BorderRadius.circular(size / 3));
      case 'diamond':
        return Transform.rotate(
          angle: math.pi / 4,
          child: _shape(borderRadius: BorderRadius.circular(size / 3)),
        );
      case 'leaf':
        return _shape(
          borderRadius: BorderRadius.only(
            topLeft: Radius.zero,
            topRight: Radius.circular(size),
            bottomLeft: Radius.circular(size),
            bottomRight: Radius.circular(size),
          ),
        );
      case 'bolt':
        return CustomPaint(
          size: Size(size, size),
          painter: _BoltPainter(color: color),
        );
      case 'circle':
      default:
        return _shape(borderRadius: BorderRadius.circular(size / 2));
    }
  }

  Widget _shape({required BorderRadius borderRadius}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
    );
  }
}

class _BoltPainter extends CustomPainter {
  const _BoltPainter({required this.color});

  final Color color;

  // polygon(45% 0%, 100% 0%, 40% 60%, 65% 60%, 20% 100%, 30% 45%, 0% 45%)
  static const List<Offset> _points = [
    Offset(0.45, 0),
    Offset(1, 0),
    Offset(0.40, 0.60),
    Offset(0.65, 0.60),
    Offset(0.20, 1),
    Offset(0.30, 0.45),
    Offset(0, 0.45),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(_points.first.dx * size.width, _points.first.dy * size.height);
    for (final p in _points.skip(1)) {
      path.lineTo(p.dx * size.width, p.dy * size.height);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BoltPainter oldDelegate) =>
      oldDelegate.color != color;
}

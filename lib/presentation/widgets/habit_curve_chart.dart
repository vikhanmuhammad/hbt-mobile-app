import 'package:flutter/material.dart';

/// Grafik kurva ilustratif pembentukan kebiasaan (hari 7/21/66/67+), dipakai
/// di halaman Edukasi onboarding (CLAUDE.md v3 §4.1 langkah 4). Bukan plot
/// data presisi — cuma ilustrasi tren naik "tingkat otomatis" seiring waktu.
class HabitCurveChart extends StatelessWidget {
  const HabitCurveChart({super.key});

  static const _markers = ['7 hari', '21 hari', '66 hari', '67+ hari'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TINGKAT OTOMATIS',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          width: double.infinity,
          child: CustomPaint(
            painter: _CurvePainter(
              lineColor: theme.colorScheme.primary,
              dotColor: theme.colorScheme.primary,
              fillColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final label in _markers)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CurvePainter extends CustomPainter {
  _CurvePainter({
    required this.lineColor,
    required this.dotColor,
    required this.fillColor,
  });

  final Color lineColor;
  final Color dotColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 4 titik penanda (7/21/66/67+ hari) diposisikan merata secara
    // horizontal (bukan skala hari sesungguhnya) supaya label tetap terbaca;
    // tingginya naik landai lalu melandai di akhir (mendekati "otomatis").
    final points = [
      Offset(size.width * 0.06, size.height * 0.88),
      Offset(size.width * 0.36, size.height * 0.55),
      Offset(size.width * 0.70, size.height * 0.20),
      Offset(size.width * 0.96, size.height * 0.08),
    ];

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    for (final p in points) {
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(
        p,
        5,
        Paint()
          ..color = dotColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}

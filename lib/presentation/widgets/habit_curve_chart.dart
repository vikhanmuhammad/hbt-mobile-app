import 'package:flutter/material.dart';

/// Grafik kurva ilustratif pembentukan kebiasaan (hari 7/21/66/67+), dipakai
/// di halaman Edukasi onboarding (CLAUDE.md v3 §4.1 langkah 4). Bukan plot
/// data presisi — cuma ilustrasi tren naik "tingkat otomatis" seiring waktu,
/// digambar sebagai kurva meliuk-liuk (bukan garis lurus) supaya lebih
/// menarik dilihat. Animasi reveal dari bawah ke atas saat widget pertama
/// kali muncul di layar.
const _curveMarkers = ['7 hari', '21 hari', '66 hari', '67+ hari'];

class HabitCurveChart extends StatefulWidget {
  const HabitCurveChart({super.key});

  @override
  State<HabitCurveChart> createState() => _HabitCurveChartState();
}

class _HabitCurveChartState extends State<HabitCurveChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _reveal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _reveal = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          height: 150,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _reveal,
            builder: (context, _) => ClipRect(
              clipper: _BottomUpRevealClipper(_reveal.value),
              child: CustomPaint(
                size: Size.infinite,
                painter: _CurvePainter(
                  lineColor: theme.colorScheme.primary,
                  dotColor: theme.colorScheme.primary,
                  fillColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final label in _curveMarkers)
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

/// Reveal dari bawah ke atas: tinggi area yang tampak tumbuh dari 0 ke penuh
/// seiring [progress] 0..1, sisi bawah tetap (grafik "muncul" dari lantai).
class _BottomUpRevealClipper extends CustomClipper<Rect> {
  _BottomUpRevealClipper(this.progress);

  final double progress;

  @override
  Rect getClip(Size size) {
    final visibleHeight = size.height * progress;
    return Rect.fromLTWH(0, size.height - visibleHeight, size.width, visibleHeight);
  }

  @override
  bool shouldReclip(covariant _BottomUpRevealClipper oldClipper) =>
      oldClipper.progress != progress;
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
    // Titik-titik penanda (7/21/66/67+ hari) + titik selingan tambahan
    // supaya kurva melengkung meliuk-liuk (bukan naik landai lurus), sambil
    // tetap mempertahankan tren naik keseluruhan menuju "otomatis".
    final points = [
      Offset(size.width * 0.04, size.height * 0.90),
      Offset(size.width * 0.18, size.height * 0.68),
      Offset(size.width * 0.32, size.height * 0.78),
      Offset(size.width * 0.46, size.height * 0.48),
      Offset(size.width * 0.60, size.height * 0.58),
      Offset(size.width * 0.74, size.height * 0.24),
      Offset(size.width * 0.86, size.height * 0.32),
      Offset(size.width * 0.97, size.height * 0.08),
    ];
    final markerIndices = [0, 2, 5, 7];

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final control = Offset(p0.dx + (p1.dx - p0.dx) * 0.5, p0.dy);
      path.quadraticBezierTo(control.dx, control.dy, p1.dx, p1.dy);
    }

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
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (final i in markerIndices) {
      final p = points[i];
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

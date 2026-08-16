import 'package:flutter/material.dart';

/// Grafik kurva pembentukan kebiasaan (hari 7/21/66/67+) bergaya diagram
/// edukasi: sumbu-Y "Happiness" (label persen di tiap garis bantu putus-
/// putus), sumbu-X "Habitual Stage" dengan 4 tahap (Trigger, Resistance,
/// Stabilization, Automaticity), titik penanda berlabel "N Days" di atas
/// tiap titik, dan lingkaran centang hijau di ujung kurva (>66 hari =
/// otomatis). Dipakai di halaman Edukasi onboarding (CLAUDE.md v3 §4.1
/// langkah 4). Bukan plot data presisi, cuma ilustrasi tren naik. Animasi
/// reveal dari bawah ke atas saat widget pertama kali muncul di layar.
const _stages = ['Trigger', 'Resistance', 'Stabilization', 'Automaticity'];

class _CurvePoint {
  const _CurvePoint({required this.xFrac, required this.percent, this.dayLabel});
  final double xFrac;
  final double percent;
  final String? dayLabel;
}

const _curvePoints = [
  _CurvePoint(xFrac: 0.04, percent: 5, dayLabel: '7 Days'),
  _CurvePoint(xFrac: 0.34, percent: 15, dayLabel: '21 Days'),
  _CurvePoint(xFrac: 0.66, percent: 34, dayLabel: '66 Days'),
  _CurvePoint(xFrac: 0.97, percent: 62),
];

const _gridPercents = [5.0, 15.0, 34.0, 58.0];

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
    // IntrinsicHeight so the Row's stretch-aligned side labels get a finite
    // height to stretch to — this widget sits inside a ListView, which hands
    // its children unbounded height, and Row+stretch cannot resolve against
    // an unbounded cross axis on its own.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RotatedAxisLabel(text: 'Happiness', theme: theme),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: AnimatedBuilder(
                    animation: _reveal,
                    builder: (context, _) => ClipRect(
                      clipper: _BottomUpRevealClipper(_reveal.value),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _CurvePainter(
                          lineColor: theme.colorScheme.primary,
                          fillColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                          gridColor: theme.dividerColor,
                          labelColor: theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurface,
                          pillColor: theme.cardColor,
                          textStyle: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final stage in _stages)
                      Expanded(
                        child: Text(
                          stage,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _RotatedAxisLabel(text: 'Habitual Stage', theme: theme),
        ],
      ),
    );
  }
}

class _RotatedAxisLabel extends StatelessWidget {
  const _RotatedAxisLabel({required this.text, required this.theme});

  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.textTheme.bodySmall?.color),
          ),
        ),
      ),
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
    required this.fillColor,
    required this.gridColor,
    required this.labelColor,
    required this.pillColor,
    required this.textStyle,
  });

  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final Color labelColor;
  final Color pillColor;
  final TextStyle? textStyle;

  static const _leftGutter = 26.0;
  static const _topPadding = 22.0;
  static const _bottomPadding = 4.0;

  // Percent scale: 0% at the plot floor, up to ~68% near the top so the
  // final (checkmark) point sits close to, but not pinned at, the ceiling.
  double _yForPercent(double percent, Rect plot) {
    final frac = (percent / 68).clamp(0.0, 1.0);
    return plot.bottom - frac * plot.height;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTWH(
      _leftGutter,
      _topPadding,
      size.width - _leftGutter,
      size.height - _topPadding - _bottomPadding,
    );

    // Horizontal dashed grid lines + percentage labels on the left.
    for (final percent in _gridPercents) {
      final y = _yForPercent(percent, plot);
      _drawDashedLine(canvas, Offset(plot.left, y), Offset(plot.right, y), gridColor.withValues(alpha: 0.5));
      _drawText(
        canvas,
        '${percent.round()}%',
        Offset(0, y),
        anchorCenter: true,
        style: textStyle?.copyWith(color: labelColor, fontSize: 10),
      );
    }

    // Smooth curve through the data points.
    final points = [
      for (final p in _curvePoints)
        Offset(plot.left + p.xFrac * plot.width, _yForPercent(p.percent, plot)),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final c1 = Offset(p0.dx + (p1.dx - p0.dx) * 0.5, p0.dy);
      final c2 = Offset(p0.dx + (p1.dx - p0.dx) * 0.5, p1.dy);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, plot.bottom)
      ..lineTo(points.first.dx, plot.bottom)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fillColor, fillColor.withValues(alpha: 0)],
        ).createShader(plot),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Markers: first 3 points get an open dot + a "N Days" pill connected by
    // a short dashed line; the last point is the "automatic" checkmark.
    for (var i = 0; i < points.length - 1; i++) {
      final point = points[i];
      final labelY = point.dy - 26;
      _drawDashedLine(
        canvas,
        Offset(point.dx, labelY + 10),
        Offset(point.dx, point.dy - 6),
        gridColor.withValues(alpha: 0.7),
      );
      canvas.drawCircle(point, 5, Paint()..color = Colors.white);
      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      _drawPillLabel(
        canvas,
        _curvePoints[i].dayLabel!,
        Offset(point.dx, labelY),
        pillColor,
        lineColor,
        labelColor,
      );
    }

    final checkPoint = points.last;
    canvas.drawCircle(checkPoint, 9, Paint()..color = const Color(0xFF3E9B5C));
    _drawCheckIcon(canvas, checkPoint, 9);
    _drawText(
      canvas,
      '67+ Days',
      Offset(checkPoint.dx, checkPoint.dy - 22),
      anchorRight: true,
      style: textStyle?.copyWith(color: labelColor.withValues(alpha: 0.6), fontSize: 10),
    );

    // Solid x-axis baseline.
    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      Paint()
        ..color = gridColor
        ..strokeWidth = 1.5,
    );
  }

  void _drawCheckIcon(Canvas canvas, Offset center, double radius) {
    final path = Path()
      ..moveTo(center.dx - radius * 0.45, center.dy)
      ..lineTo(center.dx - radius * 0.1, center.dy + radius * 0.35)
      ..lineTo(center.dx + radius * 0.45, center.dy - radius * 0.35);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawPillLabel(
    Canvas canvas,
    String text,
    Offset center,
    Color bg,
    Color border,
    Color textColor,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle?.copyWith(color: textColor, fontSize: 10, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: tp.width + 14,
        height: tp.height + 8,
      ),
      const Radius.circular(999),
    );
    canvas.drawRRect(rect, Paint()..color = bg);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = border.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset anchor, {
    bool anchorCenter = false,
    bool anchorRight = false,
    TextStyle? style,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    Offset offset;
    if (anchorCenter) {
      offset = Offset(anchor.dx, anchor.dy - tp.height / 2);
    } else if (anchorRight) {
      offset = Offset(anchor.dx - tp.width, anchor.dy - tp.height / 2);
    } else {
      offset = anchor;
    }
    tp.paint(canvas, offset);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    const dashWidth = 4.0;
    const dashGap = 3.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final total = (end - start).distance;
    if (total == 0) return;
    final direction = (end - start) / total;
    var covered = 0.0;
    while (covered < total) {
      final segStart = start + direction * covered;
      final segEnd = start + direction * (covered + dashWidth).clamp(0, total);
      canvas.drawLine(segStart, segEnd, paint);
      covered += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) =>
      oldDelegate.lineColor != lineColor || oldDelegate.gridColor != gridColor;
}

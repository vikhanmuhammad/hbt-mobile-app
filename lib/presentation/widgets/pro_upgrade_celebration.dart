import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/community_providers.dart';
import '../theme/app_colors.dart';

/// Wraps the whole app (mounted in `MaterialApp.builder`, so it works no
/// matter which screen the purchase started from — Settings, the
/// Community/Finance paywall, or onboarding) and shows a brief full-screen
/// celebration (confetti + badge) the moment `isProProvider` flips from
/// false to true, i.e. right when a Free user's purchase goes through.
class ProUpgradeCelebration extends ConsumerStatefulWidget {
  const ProUpgradeCelebration({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ProUpgradeCelebration> createState() => _ProUpgradeCelebrationState();
}

class _ProUpgradeCelebrationState extends ConsumerState<ProUpgradeCelebration>
    with TickerProviderStateMixin {
  bool _visible = false;
  late final AnimationController _confettiController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );
  late final List<_ConfettiPiece> _pieces = List.generate(30, (i) => _ConfettiPiece.random(i));

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _show() {
    setState(() => _visible = true);
    _confettiController
      ..reset()
      ..forward();
  }

  void _dismiss() {
    if (mounted) setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    // Only reacts to an actual false->true edge — `previous == null` (first
    // build after this provider mounts, e.g. someone who was already Pro
    // before reaching a screen that watches it) must never trigger this.
    ref.listen(isProProvider, (previous, next) {
      if (previous == false && next == true) _show();
    });

    return Stack(
      children: [
        widget.child,
        if (_visible)
          Positioned.fill(
            child: _CelebrationOverlay(
              confettiController: _confettiController,
              pieces: _pieces,
              onDismiss: _dismiss,
            ),
          ),
      ],
    );
  }
}

class _CelebrationOverlay extends StatelessWidget {
  const _CelebrationOverlay({
    required this.confettiController,
    required this.pieces,
    required this.onDismiss,
  });

  final AnimationController confettiController;
  final List<_ConfettiPiece> pieces;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: confettiController,
              builder: (context, _) => CustomPaint(
                painter: _ConfettiPainter(pieces: pieces, progress: confettiController.value),
              ),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutBack,
                builder: (context, value, child) => Opacity(
                  opacity: value.clamp(0, 1),
                  child: Transform.scale(scale: 0.7 + 0.3 * value, child: child),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              l10n.proUpgradeCelebrationTitle,
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.proUpgradeCelebrationSubtitle,
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: onDismiss,
                                child: Text(l10n.proUpgradeCelebrationButton),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One falling/rotating confetti rectangle — position and motion are
/// deterministic per-piece (seeded `Random`) so the same burst shape
/// replays every time, just re-triggered by [progress] going 0->1.
class _ConfettiPiece {
  const _ConfettiPiece({
    required this.startX,
    required this.startDelay,
    required this.fallSpeed,
    required this.swayAmplitude,
    required this.swayPhase,
    required this.rotationSpeed,
    required this.size,
    required this.color,
  });

  final double startX;
  final double startDelay;
  final double fallSpeed;
  final double swayAmplitude;
  final double swayPhase;
  final double rotationSpeed;
  final double size;
  final Color color;

  static const _palette = [
    AppColors.gold,
    ...AppColors.categoryPalette,
  ];

  factory _ConfettiPiece.random(int seed) {
    final rnd = Random(seed * 7919 + 13);
    return _ConfettiPiece(
      startX: rnd.nextDouble(),
      startDelay: rnd.nextDouble() * 0.35,
      fallSpeed: 0.9 + rnd.nextDouble() * 0.6,
      swayAmplitude: 0.03 + rnd.nextDouble() * 0.05,
      swayPhase: rnd.nextDouble() * 2 * pi,
      rotationSpeed: (rnd.nextBool() ? 1 : -1) * (2 + rnd.nextDouble() * 4),
      size: 6 + rnd.nextDouble() * 6,
      color: _palette[rnd.nextInt(_palette.length)],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.pieces, required this.progress});

  final List<_ConfettiPiece> pieces;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final local = ((progress - piece.startDelay) / (1 - piece.startDelay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final y = -0.1 + local * piece.fallSpeed * 1.2;
      if (y > 1.05) continue;
      final x = piece.startX + sin(local * 6 + piece.swayPhase) * piece.swayAmplitude;
      final dx = x * size.width;
      final dy = y * size.height;
      final opacity = local > 0.8 ? (1 - local) / 0.2 : 1.0;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(local * piece.rotationSpeed * pi);
      final paint = Paint()..color = piece.color.withValues(alpha: opacity.clamp(0, 1));
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: piece.size, height: piece.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}

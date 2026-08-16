import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Fades and slides [child] up into place on first build. Used to give
/// screen content and list/grid items a consistent entrance animation.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.delay = Duration.zero, this.duration});

  final Widget child;
  final Duration delay;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration ?? 350.ms, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, duration: duration ?? 350.ms, curve: Curves.easeOutCubic);
  }
}

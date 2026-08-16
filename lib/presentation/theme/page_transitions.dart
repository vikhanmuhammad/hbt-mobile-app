import 'package:flutter/material.dart';

/// App-wide route transition: new page fades in while sliding up slightly;
/// applies automatically to every `MaterialPageRoute` push/pop since it's
/// wired into [ThemeData.pageTransitionsTheme].
class FadeSlideUpPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeSlideUpPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final incoming = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final outgoing = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInCubic);

    return FadeTransition(
      opacity: incoming,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(incoming),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0).animate(outgoing),
          child: child,
        ),
      ),
    );
  }
}

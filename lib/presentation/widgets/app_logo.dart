import 'package:flutter/material.dart';

/// Logo app — dipakai di splash screen dan step Welcome onboarding.
///
/// Renders `icon_glyph.png`, a version of the launcher icon
/// (`icon_new.png`, used as-is for `flutter_launcher_icons:` in
/// pubspec.yaml, which needs its own large transparent margin for the
/// Android adaptive-icon safe zone) pre-cropped tightly to the glyph's real
/// visual bounds. Cropping was done once offline from the exact
/// non-transparent pixel bounding box (not eyeballed) so [size] reflects the
/// glyph's actual footprint — no more built-in dead space making it look
/// far from whatever sits right below it (splash screen, "Welcome Back").
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icon/icon_glyph.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

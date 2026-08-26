import 'package:flutter/material.dart';

/// Logo app — dipakai di splash screen dan step Welcome onboarding, dan
/// jadi sumber gambar app icon (lihat `flutter_launcher_icons:` di
/// pubspec.yaml) supaya konsisten dari splash sampai launcher.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icon/icon_new.png',
      width: size,
      height: size,
    );
  }
}

import 'package:flutter/material.dart';

/// Logo app: kotak membulat bg warna primer + centang putih — dipakai di
/// splash screen dan step Welcome onboarding, dan jadi dasar app icon
/// (`assets/icon/icon.png`) supaya konsisten dari splash sampai launcher.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(Icons.check_rounded, color: Colors.white, size: size * 0.5),
    );
  }
}

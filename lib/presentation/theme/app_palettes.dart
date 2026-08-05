import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Satu pilihan tema warna untuk fitur Personalize (CLAUDE.md v3 §8). Cuma
/// warna aksen/primary yang berubah antar palet — warna netral (background,
/// surface, teks, border) tetap sama supaya prinsip visual "tenang, tidak
/// menghakimi" (update_v1.md §9) konsisten di semua tema.
class AppPalette {
  const AppPalette({required this.key, required this.label, required this.accent});

  final String key;
  final String label;
  final Color accent;
}

class AppPalettes {
  AppPalettes._();

  static const tealSage = AppPalette(
    key: 'teal_sage',
    label: 'Teal Sage',
    accent: AppColors.gold,
  );
  static const sunsetCoral = AppPalette(
    key: 'sunset_coral',
    label: 'Sunset Coral',
    accent: Color(0xFFE2896D),
  );
  static const oceanBlue = AppPalette(
    key: 'ocean_blue',
    label: 'Ocean Blue',
    accent: Color(0xFF6FA8D8),
  );
  static const lavenderCalm = AppPalette(
    key: 'lavender_calm',
    label: 'Lavender Calm',
    accent: Color(0xFFA98FD1),
  );
  static const warmAmber = AppPalette(
    key: 'warm_amber',
    label: 'Warm Amber',
    accent: Color(0xFFE3A94B),
  );

  static const List<AppPalette> all = [
    tealSage,
    sunsetCoral,
    oceanBlue,
    lavenderCalm,
    warmAmber,
  ];

  static AppPalette byKey(String? key) =>
      all.firstWhere((p) => p.key == key, orElse: () => tealSage);
}

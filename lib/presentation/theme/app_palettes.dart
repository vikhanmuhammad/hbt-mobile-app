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

  // Palet tambahan — `sunnyGold` (#F2BD00) jadi default baru (lihat `byKey`).
  static const skyBlue = AppPalette(
    key: 'sky_blue',
    label: 'Sky Blue',
    accent: Color(0xFF93D9F9),
  );
  static const sunnyGold = AppPalette(
    key: 'sunny_gold',
    label: 'Sunny Gold',
    accent: Color(0xFFF2BD00),
  );
  static const blushPink = AppPalette(
    key: 'blush_pink',
    label: 'Blush Pink',
    accent: Color(0xFFFFA0A0),
  );
  static const tangerine = AppPalette(
    key: 'tangerine',
    label: 'Tangerine',
    accent: Color(0xFFFFB34E),
  );
  static const freshLime = AppPalette(
    key: 'fresh_lime',
    label: 'Fresh Lime',
    accent: Color(0xFFC1EC9A),
  );
  static const orchidPurple = AppPalette(
    key: 'orchid_purple',
    label: 'Orchid Purple',
    accent: Color(0xFFF0A6FF),
  );

  static const List<AppPalette> all = [
    sunnyGold,
    tealSage,
    skyBlue,
    blushPink,
    tangerine,
    freshLime,
    orchidPurple,
    sunsetCoral,
    oceanBlue,
    lavenderCalm,
    warmAmber,
  ];

  static AppPalette byKey(String? key) =>
      all.firstWhere((p) => p.key == key, orElse: () => sunnyGold);
}

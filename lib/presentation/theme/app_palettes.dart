import 'package:flutter/material.dart';

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

  static const skyBlue = AppPalette(
    key: 'sky_blue',
    label: 'Sky Blue',
    accent: Color(0xFF93D9F9),
  );
  static const sunnyGold = AppPalette(
    key: 'sunny_gold',
    label: 'Sunny Gold',
    accent: Color(0xFFFFB951),
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
    skyBlue,
    blushPink,
    tangerine,
    freshLime,
    orchidPurple,
  ];

  static AppPalette byKey(String? key) =>
      all.firstWhere((p) => p.key == key, orElse: () => sunnyGold);
}

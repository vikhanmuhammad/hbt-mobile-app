import 'package:flutter/material.dart';

/// Warna inti aplikasi, diambil dari DESIGN.md §2 (palet netral-hangat,
/// teal/sage sebagai warna utama, kuning lembut untuk aksen streak).
class AppColors {
  AppColors._();

  // Warna dasar (dipakai di light & dark, dengan penyesuaian opacity/shade).
  static const Color teal = Color(0xFF3E7C6A);
  static const Color tealBright = Color(0xFF4FBF9F);
  static const Color gold = Color(0xFFE8C468);

  // Light theme.
  static const Color lightBackground = Color(0xFFF7F5EE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF3F1EA);
  static const Color lightBorder = Color(0xFFD9CDBF);
  static const Color lightText = Color(0xFF2A332E);
  static const Color lightTextMuted = Color(0xFF6B8F71);
  static const Color lightNotDone = Color(0xFFD9CDBF);

  // Dark theme.
  static const Color darkBackground = Color(0xFF0F1512);
  static const Color darkSurface = Color(0xFF181712);
  static const Color darkSurfaceAlt = Color(0xFF2A332E);
  static const Color darkBorder = Color(0xFF3A423C);
  static const Color darkText = Color(0xFFF3F1EA);
  static const Color darkTextMuted = Color(0xFFA9B8AC);
  static const Color darkNotDone = Color(0xFF3A423C);

  /// Palet aksen per kategori bawaan, urut sesuai `habit_templates.json`.
  /// Dipakai juga sebagai fallback siklus warna untuk kategori custom.
  static const List<Color> categoryPalette = [
    Color(0xFF6B9B5E), // hijau — Kesehatan
    Color(0xFFE08A3C), // oranye — Olahraga
    Color(0xFF4A8C82), // teal kebiruan — Produktivitas
    Color(0xFF8B6FB3), // ungu — Mental & Mindfulness
    Color(0xFF4A82B0), // biru — Keuangan
    Color(0xFFC97B7B), // dusty rose — Sosial & Relasi
  ];

  static Color categoryColorFromHex(String? hex, int fallbackIndex) {
    if (hex != null && hex.isNotEmpty) {
      final parsed = _tryParseHex(hex);
      if (parsed != null) return parsed;
    }
    return categoryPalette[fallbackIndex % categoryPalette.length];
  }

  static Color? _tryParseHex(String hex) {
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    final parsed = int.tryParse(value, radix: 16);
    return parsed == null ? null : Color(parsed);
  }
}

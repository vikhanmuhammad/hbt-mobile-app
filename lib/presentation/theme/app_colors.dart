import 'package:flutter/material.dart';

/// Warna inti aplikasi, diselaraskan dengan render logic asli prototipe
/// (`docs/Habit Tracker.html`) — bukan cuma deskripsi tekstual di DESIGN.md.
///
/// Catatan penting: di prototipe, variabel warna "teal"/"mustard" untuk semua
/// elemen interaktif (tombol, FAB, checkbox terisi, toggle aktif) sama-sama
/// di-set ke `palette[2]` yaitu emas/gold (#E8C468) — bukan hijau sage
/// (#3E7C6A) seperti prosa di DESIGN.md §2. Warna hijau sage nyaris tidak
/// dipakai di preset default, jadi emas dipakai di sini sebagai warna
/// interaktif utama supaya sesuai tampilan prototipe yang sebenarnya.
class AppColors {
  AppColors._();

  // Warna dasar preset default prototipe: [bg, teal(unused), gold/primary].
  static const Color teal = Color(0xFF3E7C6A); // tersedia, jarang dipakai
  static const Color gold = Color(0xFFC1650F); // warna interaktif utama (oranye pekat agak gelap)

  // Light theme — persis nilai `colors` di prototipe saat isDark=false.
  // Shifted slightly cooler/grayer than the original warm off-white
  // (#F7F5EE) so the scaffold background reads as a neutral light gray
  // against white cards, instead of nearly-white-on-white.
  static const Color lightBackground = Color(0xFFF0F0EE);
  static const Color lightSurface = Color(0xFFFFFFFF); // colors.card
  static const Color lightSurfaceAlt = Color(0xFFEDEAE2); // colors.grayLight
  static const Color lightText = Color(0xFF2B2A26);
  static final Color lightTextMuted =
      const Color(0xFF2B2A26).withValues(alpha: 0.72); // colors.textSoft
  static final Color lightBorder =
      const Color(0xFF2B2A26).withValues(alpha: 0.08); // colors.border

  // Dark theme — persis nilai `colors` di prototipe saat isDark=true.
  static const Color darkBackground = Color(0xFF181712);
  static const Color darkSurface = Color(0xFF2A2A25); // mix(bg, white, 8%)
  static const Color darkSurfaceAlt = Color(0xFF383733); // mix(bg, white, 14%)
  static const Color darkText = Color(0xFFF3F1EA);
  static final Color darkTextMuted =
      const Color(0xFFF3F1EA).withValues(alpha: 0.72);
  static final Color darkBorder = Colors.white.withValues(alpha: 0.08);

  /// Palet aksen per kategori bawaan, persis `DEFAULT_CATEGORIES` di prototipe.
  /// Dipakai juga sebagai fallback siklus warna untuk kategori custom.
  static const List<Color> categoryPalette = [
    Color(0xFF6B9B5E), // hijau — Kesehatan
    Color(0xFFE08A3C), // oranye — Olahraga
    Color(0xFF4A8C82), // teal kebiruan — Produktivitas
    Color(0xFF8B6FB3), // ungu — Mental & Mindfulness
    Color(0xFF4A82B0), // biru — Keuangan
    Color(0xFFC97B7B), // dusty rose — Sosial & Relasi
  ];

  /// Pilihan warna untuk form "Buat Kategori Baru", persis `COLOR_PALETTE`
  /// di prototipe (6 warna kategori bawaan + 2 warna ekstra).
  static const List<Color> customCategoryColorPalette = [
    Color(0xFF6B9B5E),
    Color(0xFFE08A3C),
    Color(0xFF8B6FB3),
    Color(0xFF4A82B0),
    Color(0xFF4A8C82),
    Color(0xFFC97B7B),
    Color(0xFFD9A441),
    Color(0xFF5E7CE0),
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

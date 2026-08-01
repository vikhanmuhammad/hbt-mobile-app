import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String bodyFontFamily = 'Nunito';
  static const String headingFontFamily = 'Poppins';

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.light,
      primary: AppColors.gold,
      onPrimary: Colors.white,
      secondary: AppColors.gold,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
    );

    return _base(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      surfaceAltColor: AppColors.lightSurfaceAlt,
      textColor: AppColors.lightText,
      mutedColor: AppColors.lightTextMuted,
      borderColor: AppColors.lightBorder,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.dark,
      primary: AppColors.gold,
      onPrimary: Colors.white,
      secondary: AppColors.gold,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
    );

    return _base(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      surfaceAltColor: AppColors.darkSurfaceAlt,
      textColor: AppColors.darkText,
      mutedColor: AppColors.darkTextMuted,
      borderColor: AppColors.darkBorder,
    );
  }

  static ThemeData _base({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color cardColor,
    required Color surfaceAltColor,
    required Color textColor,
    required Color mutedColor,
    required Color borderColor,
  }) {
    const heading = TextStyle(fontFamily: headingFontFamily);

    final textTheme = TextTheme(
      displaySmall: heading.copyWith(fontWeight: FontWeight.w700, color: textColor),
      headlineMedium: heading.copyWith(fontWeight: FontWeight.w700, color: textColor),
      headlineSmall: heading.copyWith(fontWeight: FontWeight.w700, color: textColor),
      titleLarge: heading.copyWith(fontWeight: FontWeight.w600, color: textColor),
      titleMedium: heading.copyWith(fontWeight: FontWeight.w600, color: textColor),
      titleSmall: heading.copyWith(fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: textColor),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: textColor),
      bodySmall: TextStyle(fontWeight: FontWeight.w400, color: mutedColor),
      labelLarge: heading.copyWith(fontWeight: FontWeight.w600, color: textColor),
      labelMedium: TextStyle(fontWeight: FontWeight.w500, color: mutedColor),
      labelSmall: TextStyle(fontWeight: FontWeight.w500, color: mutedColor),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: bodyFontFamily,
      textTheme: textTheme,
      // Wajib di-set eksplisit — kalau tidak, Theme.of(context).dividerColor
      // (dipakai luas sebagai warna border netral di seluruh app) fallback ke
      // tone M3 auto-generate dari seed emas yang jadi coklat pudar, bukan
      // borderColor asli yang kita pakai di tempat lain.
      dividerColor: borderColor,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      // Kartu "soft": tanpa border, cuma shadow tipis — meniru cardStyle
      // default prototipe (bukan gaya "flat" berbingkai).
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAltColor,
        side: BorderSide.none,
        labelStyle: textTheme.labelMedium,
        shape: const StadiumBorder(),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const StadiumBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: heading.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: borderColor),
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: mutedColor),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dividerTheme: DividerThemeData(color: borderColor, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(textTheme.labelSmall),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cardColor,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        selectedLabelTextStyle:
            textTheme.labelMedium?.copyWith(color: colorScheme.primary),
        unselectedLabelTextStyle: textTheme.labelMedium,
      ),
    );
  }
}

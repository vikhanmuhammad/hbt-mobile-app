import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Inter';

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.light,
      primary: AppColors.teal,
      secondary: AppColors.gold,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
    );

    return _base(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      textColor: AppColors.lightText,
      mutedColor: AppColors.lightTextMuted,
      borderColor: AppColors.lightBorder,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.dark,
      primary: AppColors.tealBright,
      secondary: AppColors.gold,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
    );

    return _base(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      textColor: AppColors.darkText,
      mutedColor: AppColors.darkTextMuted,
      borderColor: AppColors.darkBorder,
    );
  }

  static ThemeData _base({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color cardColor,
    required Color textColor,
    required Color mutedColor,
    required Color borderColor,
  }) {
    final textTheme = TextTheme(
      displaySmall: TextStyle(fontWeight: FontWeight.w700, color: textColor),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: textColor),
      headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: textColor),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      titleSmall: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: textColor),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: textColor),
      bodySmall: TextStyle(fontWeight: FontWeight.w400, color: mutedColor),
      labelLarge: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      labelMedium: TextStyle(fontWeight: FontWeight.w500, color: mutedColor),
      labelSmall: TextStyle(fontWeight: FontWeight.w500, color: mutedColor),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        side: BorderSide(color: borderColor),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: borderColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
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
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFE63946);
  static const dark = Color(0xFF1D1D1F);
  static const background = Color(0xFFFAFAFA);
  static const accent = Color(0xFFF4A261);
  static const grey = Color(0xFF8E8E93);
  static const lightGrey = Color(0xFFF0F0F0);
  static const success = Color(0xFF2A9D8F);
  static const white = Color(0xFFFFFFFF);
}

class AppTheme {
  static const String fontFamily = 'IBMPlexSansArabic';

  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: AppColors.dark,
      displayColor: AppColors.dark,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      textTheme: baseTextTheme,
      appBarTheme:
          const AppBarTheme(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: AppColors.dark),
          ).copyWith(
            titleTextStyle: baseTextTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.grey,
        ),
      ),
    );
  }
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppRadius {
  static const small = 10.0;
  static const medium = 16.0;
  static const large = 24.0;
}

import 'package:flutter/material.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';

/// Clean Arabic-first typography scale with Cairo font family and system fallbacks.
abstract final class AppTypography {
  static const String primaryFontFamily = 'Cairo';

  static const List<String> fontFallbacks = [
    'Cairo',
    'Segoe UI',
    'SF Pro Text',
    'Roboto',
    'sans-serif',
  ];

  /// Builds a cohesive [TextTheme] for light or dark mode.
  static TextTheme createTextTheme({required bool isDark}) {
    final primaryColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: primaryColor,
      ),
      displayMedium: TextStyle(
        fontFamily: primaryFontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: primaryFontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleMedium: TextStyle(
        fontFamily: primaryFontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleSmall: TextStyle(
        fontFamily: primaryFontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primaryColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: primaryFontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: secondaryColor,
      ),
      bodySmall: TextStyle(
        fontFamily: primaryFontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondaryColor,
      ),
      labelLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primaryColor,
      ),
      labelSmall: TextStyle(
        fontFamily: primaryFontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: secondaryColor,
      ),
    );
  }
}

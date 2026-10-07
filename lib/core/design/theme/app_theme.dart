import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/core/design/typography/app_typography.dart';

/// Complete application theme definitions for Light and Dark modes.
abstract final class AppTheme {
  /// Dark Theme (Deep Navy aesthetic with vibrant cyan & electric blue accents)
  static ThemeData get darkTheme {
    final textTheme = AppTypography.createTextTheme(isDark: true);
    const colorScheme = ColorScheme.dark(
      primary: AppColors.electricBlue,
      onPrimary: Colors.white,
      secondary: AppColors.cyanAccent,
      onSecondary: AppColors.darkBackground,
      tertiary: AppColors.metallicGold,
      error: AppColors.alertRed,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      outline: AppColors.darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(color: AppColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.electricBlue.withValues(alpha: 0.2),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.cyanAccent,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.cyanAccent);
          }
          return const IconThemeData(color: AppColors.darkTextSecondary);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, AppSpacing.touchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cyanAccent,
          minimumSize: const Size(0, AppSpacing.touchTarget),
          side: const BorderSide(color: AppColors.cyanAccent),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        labelStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderSm,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Light Theme (Calm soft ice & clean navy aesthetic)
  static ThemeData get lightTheme {
    final textTheme = AppTypography.createTextTheme(isDark: false);
    const colorScheme = ColorScheme.light(
      primary: AppColors.electricBlue,
      secondary: AppColors.cyanAccent,
      onSecondary: AppColors.lightBackground,
      tertiary: AppColors.metallicGold,
      error: AppColors.alertRed,
      onSurface: AppColors.lightTextPrimary,
      outline: AppColors.lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(color: AppColors.lightBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.electricBlue.withValues(alpha: 0.12),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.electricBlue,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.lightTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.electricBlue);
          }
          return const IconThemeData(color: AppColors.lightTextSecondary);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, AppSpacing.touchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.electricBlue,
          minimumSize: const Size(0, AppSpacing.touchTarget),
          side: const BorderSide(color: AppColors.electricBlue),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.lightSurfaceElevated,
        labelStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderSm,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

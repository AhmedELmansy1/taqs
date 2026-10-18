import 'package:flutter/material.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';

/// Design system color palette tokens.
///
/// Designed with a calm, premium aesthetic:
/// - Deep navy backgrounds
/// - Electric blue and cyan accents
/// - Controlled metallic gold for highlights & key numbers
/// - Refined deep violet used sparingly for celestial atmospheric depth
/// - Alert red reserved strictly for warnings and hazardous conditions
/// - Absolutely NO generic green, neon or hacker aesthetics.
abstract final class AppColors {
  // --- Dark Mode Palette (Deep Navy Hero Experience) ---
  static const Color darkBackground = Color(0xFF070B14);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkSurfaceElevated = Color(0xFF17233D);
  static const Color darkSurfaceHover = Color(0xFF1E2D4E);
  static const Color darkBorder = Color(0xFF1E2D4A);
  static const Color darkBorderSubtle = Color(0xFF152238);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // --- Light Mode Palette (Refined Ice & Ceramic Navy) ---
  static const Color lightBackground = Color(0xFFF1F5F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFE2E8F0);
  static const Color lightSurfaceHover = Color(0xFFCBD5E1);
  static const Color lightBorder = Color(0xFFCBD5E1);
  static const Color lightBorderSubtle = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF64748B);

  // --- Shared Brand Accents ---
  /// Electric Blue — Primary Action & Brand Identity
  static const Color electricBlue = Color(0xFF1E6FFF);
  static const Color electricBlueLight = Color(0xFF3B82F6);

  /// Cyan — Atmospheric & Meteorological Secondary Accent
  static const Color cyanAccent = Color(0xFF00BFE6);
  static const Color cyanAccentSubtle = Color(0xFF38BDF8);

  /// Metallic Gold — Refined Highlight, Sunbeams, Key Stat Badges
  static const Color metallicGold = Color(0xFFD4AF37);
  static const Color metallicGoldLight = Color(0xFFF6D365);
  static const Color metallicGoldMuted = Color(0xFFB4942E);

  /// Deep Violet — Used sparingly for cosmic twilight and stormy depth
  static const Color deepViolet = Color(0xFF1E1035);
  static const Color subtleViolet = Color(0xFF2E1C4E);

  /// Warning / Alert Red — Reserved strictly for alerts & critical errors
  static const Color alertRed = Color(0xFFE53935);
  static const Color alertRedLight = Color(0xFFFFEBEE);
  static const Color alertRedDarkSurface = Color(0xFF2D1518);
}

/// Dynamic atmospheric multi-stop gradients adapting strictly to
/// weather condition and day/night cycle within the luxury brand palette.
abstract final class AtmosphericGradients {
  /// Clear Day: Brilliant Mediterranean azure tapering into deep royal navy.
  static const LinearGradient clearDay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D3268),
      Color(0xFF0B1F45),
      Color(0xFF070B14),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// Clear Night: Cosmic obsidian navy with subtle deep-violet depth.
  static const LinearGradient clearNight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF12122B),
      Color(0xFF0B0E20),
      Color(0xFF050711),
    ],
    stops: [0.0, 0.6, 1.0],
  );

  /// Cloudy Day: Calm atmospheric slate navy.
  static const LinearGradient cloudyDay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF16253B),
      Color(0xFF101B2B),
      Color(0xFF070C15),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Cloudy Night: Deep pewter graphite navy.
  static const LinearGradient cloudyNight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F1724),
      Color(0xFF0A0F1A),
      Color(0xFF05070D),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// Rainy: Deep oceanic navy with cool slate undertones.
  static const LinearGradient rainy = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D253A),
      Color(0xFF0A1C2C),
      Color(0xFF060F18),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// Stormy: Charged midnight indigo with deep violet undertones.
  static const LinearGradient stormy = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1B1638),
      Color(0xFF110E26),
      Color(0xFF070513),
    ],
    stops: [0.0, 0.6, 1.0],
  );

  /// Foggy: Soft diffused mist over deep steel navy.
  static const LinearGradient foggy = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF172433),
      Color(0xFF111A26),
      Color(0xFF080D14),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Dust / Haze (Khamsin wind in Egypt): Muted warm bronze smoke over deep navy.
  static const LinearGradient dustHaze = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2B1D12),
      Color(0xFF1B130E),
      Color(0xFF0A0706),
    ],
    stops: [0.0, 0.6, 1.0],
  );

  /// Returns the corresponding [LinearGradient] for the given [condition] and [isDay].
  static LinearGradient forCondition(
    WeatherCondition condition, {
    bool isDay = true,
  }) {
    switch (condition) {
      case WeatherCondition.sunny:
        return isDay ? clearDay : clearNight;
      case WeatherCondition.partlyCloudy:
      case WeatherCondition.cloudy:
        return isDay ? cloudyDay : cloudyNight;
      case WeatherCondition.rainy:
        return rainy;
      case WeatherCondition.fog:
        return foggy;
      case WeatherCondition.dustStorm:
        return dustHaze;
    }
  }
}

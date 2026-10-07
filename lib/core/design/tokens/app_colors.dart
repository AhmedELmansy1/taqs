import 'package:flutter/material.dart';

/// Design system color palette tokens.
///
/// Designed with a calm, premium aesthetic:
/// - Deep navy backgrounds
/// - Electric blue and cyan accents
/// - Controlled metallic gold for highlights
/// - Alert red for warnings and destructive states only
/// - Absolutely NO generic bright green or excessive neon
abstract final class AppColors {
  // --- Dark Mode Palette (Deep Navy) ---
  static const Color darkBackground = Color(0xFF090E1A);
  static const Color darkSurface = Color(0xFF111A2D);
  static const Color darkSurfaceElevated = Color(0xFF18243E);
  static const Color darkSurfaceHover = Color(0xFF223254);
  static const Color darkBorder = Color(0xFF223352);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // --- Light Mode Palette (Calm Air & Ice Navy) ---
  static const Color lightBackground = Color(0xFFF3F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFE8EEF7);
  static const Color lightSurfaceHover = Color(0xFFDEE7F3);
  static const Color lightBorder = Color(0xFFCBD7E6);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF64748B);

  // --- Shared Brand Accents ---
  /// Electric Blue — Primary Action & Main Accent
  static const Color electricBlue = Color(0xFF1E6FFF);

  /// Cyan — Atmospheric & Meteorological Secondary Accent
  static const Color cyanAccent = Color(0xFF00BFE6);

  /// Metallic Gold — Refined Highlight & Star Accents
  static const Color metallicGold = Color(0xFFD4AF37);

  /// Warning / Alert Red — Reserved strictly for alerts & critical errors
  static const Color alertRed = Color(0xFFE53935);
  static const Color alertRedLight = Color(0xFFFFEBEE);
  static const Color alertRedDarkSurface = Color(0xFF2D1518);
}

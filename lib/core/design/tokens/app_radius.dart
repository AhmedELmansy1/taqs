import 'package:flutter/material.dart';

/// Standard corner radius tokens for cards, buttons, and dialogs.
abstract final class AppRadius {
  /// 4dp subtle rounding
  static const double xs = 4;

  /// 8dp chip and tag rounding
  static const double sm = 8;

  /// 12dp standard button and small card rounding
  static const double md = 12;

  /// 16dp primary container & card rounding
  static const double lg = 16;

  /// 20dp hero and prominent card rounding
  static const double xl = 20;

  /// 28dp modal sheets and dialogs
  static const double xxl = 28;

  /// 999dp pill & capsule shape
  static const double pill = 999;

  // Pre-built BorderRadius instances for const widgets
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderPill = BorderRadius.all(Radius.circular(pill));
}

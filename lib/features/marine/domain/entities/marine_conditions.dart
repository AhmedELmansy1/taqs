import 'package:flutter/foundation.dart';

/// Indicative rating of sea/surf state based on significant wave height thresholds.
enum SeaStateRating {
  /// Wave height < 1.0m
  calm,

  /// 1.0m <= Wave height < 2.0m
  moderate,

  /// 2.0m <= Wave height < 3.0m
  rough,

  /// Wave height >= 3.0m
  dangerous;

  /// Evaluates rating deterministically from wave height in meters.
  static SeaStateRating fromWaveHeight(double height) {
    if (height < 1.0) {
      return SeaStateRating.calm;
    } else if (height < 2.0) {
      return SeaStateRating.moderate;
    } else if (height < 3.0) {
      return SeaStateRating.rough;
    } else {
      return SeaStateRating.dangerous;
    }
  }

  String labelAr() {
    switch (this) {
      case SeaStateRating.calm:
        return 'هادئ ومناسب للنزول';
      case SeaStateRating.moderate:
        return 'معتدل الأمواج';
      case SeaStateRating.rough:
        return 'مضطرب (احذر السباحة)';
      case SeaStateRating.dangerous:
        return 'شديد الاضطراب (خطر النزول)';
    }
  }

  String labelEn() {
    switch (this) {
      case SeaStateRating.calm:
        return 'Calm (Safe for Swimming)';
      case SeaStateRating.moderate:
        return 'Moderate Waves';
      case SeaStateRating.rough:
        return 'Rough (Caution Advised)';
      case SeaStateRating.dangerous:
        return 'Dangerous (No Swimming)';
    }
  }
}

/// Domain model representing marine and sea conditions for coastal locations.
@immutable
class MarineConditions {
  const MarineConditions({
    required this.waveHeightMeters,
    required this.wavePeriodSeconds,
    required this.waveDirectionDegrees,
    required this.windWaveHeightMeters,
    required this.rating,
    required this.fetchedAt,
    this.isFromCache = false,
  });

  final double waveHeightMeters;
  final double wavePeriodSeconds;
  final int waveDirectionDegrees;
  final double windWaveHeightMeters;
  final SeaStateRating rating;
  final DateTime fetchedAt;
  final bool isFromCache;

  /// Cardinal compass direction representation.
  String directionCompass({required bool isArabic}) {
    final d = waveDirectionDegrees % 360;
    if (d >= 337.5 || d < 22.5) return isArabic ? 'شمالي (N)' : 'North (N)';
    if (d < 67.5) return isArabic ? 'شمالي شرقي (NE)' : 'Northeast (NE)';
    if (d < 112.5) return isArabic ? 'شرقي (E)' : 'East (E)';
    if (d < 157.5) return isArabic ? 'جنوبي شرقي (SE)' : 'Southeast (SE)';
    if (d < 202.5) return isArabic ? 'جنوبي (S)' : 'South (S)';
    if (d < 247.5) return isArabic ? 'جنوبي غربي (SW)' : 'Southwest (SW)';
    if (d < 292.5) return isArabic ? 'غربي (W)' : 'West (W)';
    return isArabic ? 'شمالي غربي (NW)' : 'Northwest (NW)';
  }
}

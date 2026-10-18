import 'package:flutter/foundation.dart';

/// Standard European Air Quality Index (EAQI) categories.
enum AirQualityLevel {
  good,
  fair,
  moderate,
  poor,
  veryPoor;

  static AirQualityLevel fromAqi(num aqi) {
    if (aqi <= 20) return AirQualityLevel.good;
    if (aqi <= 40) return AirQualityLevel.fair;
    if (aqi <= 60) return AirQualityLevel.moderate;
    if (aqi <= 80) return AirQualityLevel.poor;
    return AirQualityLevel.veryPoor;
  }
}

/// Immutable domain model representing air quality metrics.
@immutable
class AirQuality {
  const AirQuality({
    required this.europeanAqi,
    required this.pm10,
    required this.pm2_5,
    required this.dust,
  });

  factory AirQuality.fromJson(Map<String, dynamic> json) => AirQuality(
        europeanAqi: (json['europeanAqi'] as num).toInt(),
        pm10: (json['pm10'] as num).toDouble(),
        pm2_5: (json['pm2_5'] as num).toDouble(),
        dust: (json['dust'] as num).toDouble(),
      );

  final int europeanAqi;
  final double pm10;
  final double pm2_5;
  final double dust;

  AirQualityLevel get level => AirQualityLevel.fromAqi(europeanAqi);

  String get localizedLevelAr {
    switch (level) {
      case AirQualityLevel.good:
        return 'ممتازة';
      case AirQualityLevel.fair:
        return 'مقبولة';
      case AirQualityLevel.moderate:
        return 'معتدلة';
      case AirQualityLevel.poor:
        return 'غير صحية للحساسين';
      case AirQualityLevel.veryPoor:
        return 'غير صحية / ملوثة';
    }
  }

  String get localizedLevelEn {
    switch (level) {
      case AirQualityLevel.good:
        return 'Good';
      case AirQualityLevel.fair:
        return 'Fair';
      case AirQualityLevel.moderate:
        return 'Moderate';
      case AirQualityLevel.poor:
        return 'Poor for sensitive';
      case AirQualityLevel.veryPoor:
        return 'Very Poor';
    }
  }

  String get healthAdviceAr {
    if (dust >= 25) {
      return 'نسبة غبار وأتربة مرتفعة؛ يُنصح بارتداء كمامة وإغلاق النوافذ.';
    }
    switch (level) {
      case AirQualityLevel.good:
      case AirQualityLevel.fair:
        return 'جودة هواء مثالية لممارسة الأنشطة والرياضة في الهواء الطلق.';
      case AirQualityLevel.moderate:
        return 'مناسبة لمعظم الأفراد؛ يُفضل توخي الحذر لمرضى الحساسية الصدرية.';
      case AirQualityLevel.poor:
      case AirQualityLevel.veryPoor:
        return 'يُنصح بتقليل الأنشطة الخارجية وارتداء كمامة لمرضى الجهاز التنفسي.';
    }
  }

  String get healthAdviceEn {
    if (dust >= 25) {
      return 'High dust concentration; wearing a face mask is advised.';
    }
    switch (level) {
      case AirQualityLevel.good:
      case AirQualityLevel.fair:
        return 'Ideal air quality for outdoor workouts and activities.';
      case AirQualityLevel.moderate:
        return 'Acceptable for most; sensitive groups should take caution.';
      case AirQualityLevel.poor:
      case AirQualityLevel.veryPoor:
        return 'Reduce prolonged outdoor exertion; masks recommended.';
    }
  }

  Map<String, dynamic> toJson() => {
        'europeanAqi': europeanAqi,
        'pm10': pm10,
        'pm2_5': pm2_5,
        'dust': dust,
      };
}

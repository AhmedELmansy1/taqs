import 'package:flutter/foundation.dart';

/// Severity level of severe weather alert.
enum AlertSeverity {
  info,
  warning,
  severe,
}

/// Category of Egyptian meteorological alert.
enum AlertType {
  khamsinDust,
  morningFog,
  heatWave,
  heavyRain,
  extremeWind,
}

/// Immutable model representing an active severe weather alert.
@immutable
class WeatherAlert {
  const WeatherAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.safetyTipsAr,
    required this.safetyTipsEn,
  });

  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final List<String> safetyTipsAr;
  final List<String> safetyTipsEn;
}

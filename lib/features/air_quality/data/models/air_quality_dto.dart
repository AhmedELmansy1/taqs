import 'package:taqs/features/air_quality/domain/entities/air_quality.dart';

/// Data Transfer Object for Open-Meteo Air Quality API.
class AirQualityDto {
  const AirQualityDto({
    required this.europeanAqi,
    required this.pm10,
    required this.pm2_5,
    required this.dust,
  });

  factory AirQualityDto.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    return AirQualityDto(
      europeanAqi: ((current['european_aqi'] ?? 30) as num).toInt(),
      pm10: ((current['pm10'] ?? 20) as num).toDouble(),
      pm2_5: ((current['pm2_5'] ?? 15) as num).toDouble(),
      dust: ((current['dust'] ?? 5) as num).toDouble(),
    );
  }

  final int europeanAqi;
  final double pm10;
  final double pm2_5;
  final double dust;

  AirQuality toDomain() {
    return AirQuality(
      europeanAqi: europeanAqi,
      pm10: pm10,
      pm2_5: pm2_5,
      dust: dust,
    );
  }
}

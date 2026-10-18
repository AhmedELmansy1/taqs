import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/air_quality/data/models/air_quality_dto.dart';
import 'package:taqs/features/air_quality/domain/entities/air_quality.dart';

void main() {
  group('AirQualityDto & AirQuality entity', () {
    test('parses Open-Meteo Air Quality JSON correctly and maps to domain', () {
      final json = {
        'latitude': 30.0444,
        'longitude': 31.2357,
        'current': {
          'european_aqi': 42,
          'pm10': 38.5,
          'pm2_5': 22.0,
          'dust': 14.2,
        },
      };

      final dto = AirQualityDto.fromJson(json);
      expect(dto.europeanAqi, equals(42));
      expect(dto.pm10, equals(38.5));
      expect(dto.pm2_5, equals(22.0));
      expect(dto.dust, equals(14.2));

      final domain = dto.toDomain();
      expect(domain.europeanAqi, equals(42));
      expect(domain.level, equals(AirQualityLevel.moderate));
      expect(domain.localizedLevelAr, isNotEmpty);
      expect(domain.localizedLevelEn, isNotEmpty);
      expect(domain.healthAdviceAr, isNotEmpty);
      expect(domain.healthAdviceEn, isNotEmpty);
    });

    test('maps European AQI brackets accurately to AirQualityLevel', () {
      const goodAqi = AirQuality(
        europeanAqi: 15,
        pm10: 10,
        pm2_5: 5,
        dust: 2,
      );
      expect(goodAqi.level, equals(AirQualityLevel.good));

      const fairAqi = AirQuality(
        europeanAqi: 35,
        pm10: 25,
        pm2_5: 15,
        dust: 5,
      );
      expect(fairAqi.level, equals(AirQualityLevel.fair));

      const moderateAqi = AirQuality(
        europeanAqi: 55,
        pm10: 50,
        pm2_5: 30,
        dust: 12,
      );
      expect(moderateAqi.level, equals(AirQualityLevel.moderate));

      const poorAqi = AirQuality(
        europeanAqi: 75,
        pm10: 80,
        pm2_5: 55,
        dust: 25,
      );
      expect(poorAqi.level, equals(AirQualityLevel.poor));

      const veryPoorAqi = AirQuality(
        europeanAqi: 95,
        pm10: 120,
        pm2_5: 85,
        dust: 45,
      );
      expect(veryPoorAqi.level, equals(AirQualityLevel.veryPoor));
    });
  });
}

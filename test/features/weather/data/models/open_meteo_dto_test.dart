import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/weather/data/models/open_meteo_dto.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';

void main() {
  group('OpenMeteoForecastDto', () {
    final now = DateTime.now();
    final sampleJson = {
      'latitude': 30.0444,
      'longitude': 31.2357,
      'current': {
        'time': now.toIso8601String().substring(0, 16),
        'temperature_2m': 28.6,
        'relative_humidity_2m': 45.0,
        'apparent_temperature': 30.1,
        'is_day': 1,
        'precipitation': 0.0,
        'weather_code': 0,
        'wind_speed_10m': 14.5,
      },
      'hourly': {
        'time': List.generate(
          48,
          (i) => now.add(Duration(hours: i)).toIso8601String().substring(0, 16),
        ),
        'temperature_2m': List.generate(48, (i) => 25.0 + (i % 5)),
        'weather_code': List.generate(48, (i) => (i % 3 == 0) ? 0 : 2),
      },
      'daily': {
        'time': List.generate(
          7,
          (i) => now.add(Duration(days: i)).toIso8601String().split('T').first,
        ),
        'weather_code': [0, 1, 2, 3, 45, 61, 95],
        'temperature_2m_max': [30.0, 31.0, 32.0, 29.0, 28.0, 27.0, 26.0],
        'temperature_2m_min': [20.0, 21.0, 21.0, 19.0, 18.0, 18.0, 17.0],
        'uv_index_max': [7.0, 7.5, 8.0, 6.0, 5.0, 4.0, 4.0],
      },
    };

    test('parses JSON fixture correctly', () {
      final dto = OpenMeteoForecastDto.fromJson(sampleJson);

      expect(dto.latitude, equals(30.0444));
      expect(dto.longitude, equals(31.2357));
      expect(dto.current.temperature2m, equals(28.6));
      expect(dto.current.weatherCode, equals(0));
      expect(dto.hourly.time.length, equals(48));
      expect(dto.daily.time.length, equals(7));
    });

    test('maps to WeatherBundle domain model with 24 hours and 7 days', () {
      final dto = OpenMeteoForecastDto.fromJson(sampleJson);
      final bundle = dto.toDomain(
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
      );

      expect(bundle.current.temperature, equals(29));
      expect(bundle.current.feelsLike, equals(30));
      expect(bundle.current.cityNameAr, equals('القاهرة'));
      expect(bundle.current.condition, equals(WeatherCondition.sunny));
      expect(bundle.current.humidityPercentage, equals(45));
      expect(bundle.current.windSpeedKmh, equals(15));
      expect(bundle.current.uvIndex, equals(7));

      expect(bundle.hourly.length, equals(24));
      expect(bundle.daily.length, equals(7));
      expect(bundle.daily.first.dayNameAr, equals('اليوم'));
      expect(bundle.daily[1].dayNameAr, equals('غداً'));
    });

    test('maps WMO codes accurately', () {
      expect(mapWmoCodeToCondition(0), equals(WeatherCondition.sunny));
      expect(mapWmoCodeToCondition(1), equals(WeatherCondition.partlyCloudy));
      expect(mapWmoCodeToCondition(3), equals(WeatherCondition.cloudy));
      expect(mapWmoCodeToCondition(45), equals(WeatherCondition.fog));
      expect(mapWmoCodeToCondition(61), equals(WeatherCondition.rainy));
      expect(mapWmoCodeToCondition(80), equals(WeatherCondition.rainy));
      expect(mapWmoCodeToCondition(95), equals(WeatherCondition.rainy));
      expect(mapWmoCodeToCondition(30), equals(WeatherCondition.dustStorm));
    });
  });
}

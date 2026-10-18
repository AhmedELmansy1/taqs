import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/advisor/domain/services/clothing_advisor.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

void main() {
  group('ClothingAdvisor', () {
    WeatherBundle makeBundle({
      required int temperature,
      WeatherCondition condition = WeatherCondition.sunny,
      int windSpeed = 15,
    }) {
      return WeatherBundle(
        current: CurrentWeather(
          temperature: temperature,
          feelsLike: temperature,
          cityNameAr: 'الإسكندرية',
          cityNameEn: 'Alexandria',
          condition: condition,
          humidityPercentage: 55,
          windSpeedKmh: windSpeed,
          uvIndex: 4,
        ),
        hourly: const [],
        daily: const [],
      );
    }

    test('recommends heavy winter clothing for cold weather (< 16°C)', () {
      final advice = ClothingAdvisor.recommend(makeBundle(temperature: 12));

      expect(advice.seasonTagAr, contains('شتوي'));
      expect(advice.seasonTagEn, contains('Winter'));
      expect(advice.itemsAr.any((item) => item.contains('شتوي') || item.contains('صوف')), isTrue);
    });

    test('recommends transitional autumn/spring layers for mild weather (16-22°C)', () {
      final advice = ClothingAdvisor.recommend(makeBundle(temperature: 19));

      expect(advice.seasonTagAr, contains('خريفي'));
      expect(advice.itemsAr.any((item) => item.contains('خفيف') || item.contains('أكمام')), isTrue);
    });

    test('recommends breathable summer clothes for warm weather (22-30°C)', () {
      final advice = ClothingAdvisor.recommend(makeBundle(temperature: 26));

      expect(advice.seasonTagAr, contains('صيفي'));
      expect(advice.itemsAr.any((item) => item.contains('خفيفة') || item.contains('مريح')), isTrue);
    });

    test('recommends lightweight sun protection for hot weather (>= 30°C)', () {
      final advice = ClothingAdvisor.recommend(makeBundle(temperature: 36));

      expect(advice.seasonTagAr, contains('صيفي حار'));
      expect(advice.itemsAr.any((item) => item.contains('شمس') || item.contains('قبعة')), isTrue);
    });

    test('adds umbrella and water-resistant items on rainy days', () {
      final advice = ClothingAdvisor.recommend(
        makeBundle(
          temperature: 18,
          condition: WeatherCondition.rainy,
        ),
      );

      expect(advice.itemsAr.any((item) => item.contains('مظلة')), isTrue);
      expect(advice.itemsEn.any((item) => item.toLowerCase().contains('umbrella')), isTrue);
    });

    test('adds face mask and sunglasses on dust storm days', () {
      final advice = ClothingAdvisor.recommend(
        makeBundle(
          temperature: 28,
          condition: WeatherCondition.dustStorm,
          windSpeed: 45,
        ),
      );

      expect(advice.itemsAr.any((item) => item.contains('كمامة')), isTrue);
      expect(advice.itemsEn.any((item) => item.toLowerCase().contains('mask')), isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/notifications/weather_notification_builder.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

void main() {
  group('WeatherNotificationBuilder', () {
    test('builds accurate Arabic 12-hour briefing with daily range and tip', () {
      const current = CurrentWeather(
        temperature: 28,
        feelsLike: 29,
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
        condition: WeatherCondition.sunny,
        humidityPercentage: 45,
        windSpeedKmh: 18,
        uvIndex: 6,
      );

      const daily = DailyForecast(
        dayNameAr: 'اليوم',
        dayNameEn: 'Today',
        minTemp: 19,
        maxTemp: 31,
        condition: WeatherCondition.sunny,
      );

      final result = WeatherNotificationBuilder.buildBriefing(
        current: current,
        todayDaily: daily,
      );

      expect(result.title, 'القاهرة: 28°، مشمس وصافٍ');
      expect(result.body, contains('العظمى 31° والصغرى 19°'));
      expect(result.body, contains('أجواء معتدلة ومناسبة للخروج'));
    });

    test('builds accurate English 12-hour briefing with rain tip', () {
      const current = CurrentWeather(
        temperature: 17,
        feelsLike: 15,
        cityNameAr: 'الإسكندرية',
        cityNameEn: 'Alexandria',
        condition: WeatherCondition.rainy,
        humidityPercentage: 85,
        windSpeedKmh: 32,
        uvIndex: 3,
      );

      const daily = DailyForecast(
        dayNameAr: 'اليوم',
        dayNameEn: 'Today',
        minTemp: 14,
        maxTemp: 19,
        condition: WeatherCondition.rainy,
      );

      final result = WeatherNotificationBuilder.buildBriefing(
        current: current,
        todayDaily: daily,
        isArabic: false,
      );

      expect(result.title, 'Alexandria: 17°, Showers / Rain');
      expect(result.body, contains('High 19° • Low 14°'));
      expect(result.body, contains('Grab an umbrella'));
    });

    test('builds fallback summary when daily forecast is absent', () {
      const current = CurrentWeather(
        temperature: 38,
        feelsLike: 41,
        cityNameAr: 'أسوان',
        cityNameEn: 'Aswan',
        condition: WeatherCondition.sunny,
        humidityPercentage: 20,
        windSpeedKmh: 14,
        uvIndex: 9,
      );

      final result = WeatherNotificationBuilder.buildBriefing(
        current: current,
      );

      expect(result.title, 'أسوان: 38°، مشمس وصافٍ');
      expect(result.body, contains('يبدو كـ 41°'));
      expect(result.body, contains('أجواء حارة، احرص على شرب الماء'));
    });
  });
}

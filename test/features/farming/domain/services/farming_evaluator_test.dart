import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/farming/domain/services/farming_evaluator.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

void main() {
  WeatherBundle createBundle({
    int currentTemp = 20,
    int minForecast = 12,
    int precipitationProbability = 0,
    WeatherCondition dailyCondition = WeatherCondition.sunny,
  }) {
    return WeatherBundle(
      current: CurrentWeather(
        temperature: currentTemp,
        feelsLike: currentTemp,
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
        condition: WeatherCondition.sunny,
        humidityPercentage: 45,
        windSpeedKmh: 15,
        uvIndex: 6,
        precipitationProbability: precipitationProbability,
      ),
      hourly: const [],
      daily: [
        DailyForecast(
          dayNameAr: 'اليوم',
          dayNameEn: 'Today',
          minTemp: minForecast,
          maxTemp: currentTemp,
          condition: dailyCondition,
        ),
      ],
    );
  }

  group('FarmingEvaluator', () {
    test('detects high frost risk when min temperature is <= 2°C', () {
      final report = FarmingEvaluator.evaluate(createBundle(minForecast: 1));
      expect(report.frostRisk, FrostRiskLevel.high);
      expect(report.cropProtectionTipAr, contains('خطر صقيع شديد'));
      expect(report.cropProtectionTipEn, contains('frost hazard'));
    });

    test('detects moderate frost risk when min temperature is between 3°C and 5°C', () {
      final report = FarmingEvaluator.evaluate(createBundle(minForecast: 4));
      expect(report.frostRisk, FrostRiskLevel.moderate);
      expect(report.cropProtectionTipAr, contains('برودة ليلية'));
    });

    test('reports no frost risk when min temperature is > 5°C', () {
      final report = FarmingEvaluator.evaluate(createBundle(minForecast: 14));
      expect(report.frostRisk, FrostRiskLevel.none);
      expect(report.cropProtectionTipAr, contains('آمنة'));
    });

    test('calculates valid ET0, soil temperature and moisture indicators', () {
      final report = FarmingEvaluator.evaluate(createBundle(currentTemp: 28));
      expect(report.referenceEt0Mm, greaterThanOrEqualTo(2.0));
      expect(report.referenceEt0Mm, lessThanOrEqualTo(9.5));
      expect(report.estimatedSoilTempC, greaterThan(0));
      expect(report.estimatedSoilMoisturePercent, inInclusiveRange(15, 60));
    });

    test('advises delaying spray when rain is expected soon', () {
      final report = FarmingEvaluator.evaluate(
        createBundle(dailyCondition: WeatherCondition.rainy),
      );
      expect(report.rainExpectedSoon, isTrue);
      expect(report.irrigationAdviceAr, contains('تأجيل'));
      expect(report.irrigationAdviceEn, contains('Delay'));
    });
  });
}

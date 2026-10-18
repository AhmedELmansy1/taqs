import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/driving/domain/services/driving_safety_evaluator.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

void main() {
  CurrentWeather makeWeather({
    WeatherCondition condition = WeatherCondition.sunny,
    int windSpeedKmh = 12,
    double visibilityKm = 10.0,
    int precipitationProbability = 0,
    bool isDay = true,
  }) {
    return CurrentWeather(
      temperature: 24,
      feelsLike: 24,
      cityNameAr: 'القاهرة',
      cityNameEn: 'Cairo',
      condition: condition,
      humidityPercentage: 50,
      windSpeedKmh: windSpeedKmh,
      uvIndex: 4,
      visibilityKm: visibilityKm,
      precipitationProbability: precipitationProbability,
      isDay: isDay,
    );
  }

  group('DrivingSafetyEvaluator', () {
    test('reports extremeRisk for severe dust storm with gale winds', () {
      final report = DrivingSafetyEvaluator.evaluate(
        makeWeather(
          condition: WeatherCondition.dustStorm,
          windSpeedKmh: 55,
        ),
      );
      expect(report.level, RoadSafetyLevel.extremeRisk);
      expect(report.headlineAr, contains('عاصفة ترابية'));
      expect(report.headlineEn, contains('Severe Dust Storm'));
    });

    test('reports extremeRisk for dense fog with critical low visibility <= 0.6km', () {
      final report = DrivingSafetyEvaluator.evaluate(
        makeWeather(visibilityKm: 0.4),
      );
      expect(report.level, RoadSafetyLevel.extremeRisk);
      expect(report.primaryHazardAr, contains('شبورة'));
    });

    test('reports hazardous for torrential rain with probability >= 70', () {
      final report = DrivingSafetyEvaluator.evaluate(
        makeWeather(
          condition: WeatherCondition.rainy,
          precipitationProbability: 85,
        ),
      );
      expect(report.level, RoadSafetyLevel.hazardous);
      expect(report.headlineAr, contains('أمطار غزيرة'));
    });

    test('reports hazardous for morning fog <= 2.0km', () {
      final report = DrivingSafetyEvaluator.evaluate(
        makeWeather(visibilityKm: 1.5),
      );
      expect(report.level, RoadSafetyLevel.hazardous);
    });

    test('reports caution for wet roads or moderate rain probability', () {
      final report = DrivingSafetyEvaluator.evaluate(
        makeWeather(precipitationProbability: 50),
      );
      expect(report.level, RoadSafetyLevel.caution);
      expect(report.headlineAr, contains('طرق مبللة'));
    });

    test('reports caution for breezy crosswinds >= 38km/h', () {
      final report = DrivingSafetyEvaluator.evaluate(
        makeWeather(windSpeedKmh: 42),
      );
      expect(report.level, RoadSafetyLevel.caution);
      expect(report.headlineAr, contains('رياح نشطة'));
    });

    test('reports good with night driving advice during night', () {
      final report = DrivingSafetyEvaluator.evaluate(
        makeWeather(isDay: false),
      );
      expect(report.level, RoadSafetyLevel.good);
      expect(report.headlineAr, contains('قيادة ليلية'));
    });

    test('reports good for clear sunny day', () {
      final report = DrivingSafetyEvaluator.evaluate(makeWeather());
      expect(report.level, RoadSafetyLevel.good);
      expect(report.headlineAr, contains('ممتازة وآمنة'));
    });
  });
}

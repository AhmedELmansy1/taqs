import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/alerts/domain/entities/weather_alert.dart';
import 'package:taqs/features/alerts/domain/services/egypt_alert_evaluator.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

void main() {
  group('EgyptAlertEvaluator', () {
    CurrentWeather createCurrent({
      int temperature = 25,
      int feelsLike = 25,
      WeatherCondition condition = WeatherCondition.sunny,
      int humidity = 50,
      int windSpeed = 15,
    }) {
      return CurrentWeather(
        temperature: temperature,
        feelsLike: feelsLike,
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
        condition: condition,
        humidityPercentage: humidity,
        windSpeedKmh: windSpeed,
        uvIndex: 5,
      );
    }

    WeatherBundle createBundle(CurrentWeather current) {
      return WeatherBundle(
        current: current,
        hourly: const [],
        daily: const [],
      );
    }

    test('detects Khamsin dust storm when wind is strong and condition is dust storm', () {
      final bundle = createBundle(
        createCurrent(
          windSpeed: 45,
          condition: WeatherCondition.dustStorm,
          humidity: 20,
        ),
      );

      final alerts = EgyptAlertEvaluator.evaluate(bundle);
      expect(alerts, isNotEmpty);
      expect(
        alerts.any((a) => a.type == AlertType.khamsinDust),
        isTrue,
      );
      final khamsin = alerts.firstWhere((a) => a.type == AlertType.khamsinDust);
      expect(khamsin.severity, equals(AlertSeverity.severe));
      expect(khamsin.safetyTipsAr, isNotEmpty);
    });

    test('detects extreme summer heatwave in Upper Egypt or Delta', () {
      final bundle = createBundle(
        createCurrent(
          temperature: 41,
          feelsLike: 44,
          humidity: 35,
        ),
      );

      final alerts = EgyptAlertEvaluator.evaluate(bundle);
      expect(
        alerts.any((a) => a.type == AlertType.heatWave),
        isTrue,
      );
      final heatwave = alerts.firstWhere((a) => a.type == AlertType.heatWave);
      expect(heatwave.severity, equals(AlertSeverity.severe));
      expect(heatwave.safetyTipsAr, isNotEmpty);
    });

    test('detects torrential rain warning', () {
      final bundle = createBundle(
        createCurrent(
          condition: WeatherCondition.rainy,
          humidity: 85,
          windSpeed: 25,
        ),
      );

      final alerts = EgyptAlertEvaluator.evaluate(bundle);
      expect(
        alerts.any((a) => a.type == AlertType.heavyRain),
        isTrue,
      );
    });

    test('returns empty alerts on calm temperate day', () {
      final bundle = createBundle(
        createCurrent(
          temperature: 24,
          feelsLike: 24,
          humidity: 45,
          windSpeed: 12,
        ),
      );

      final alerts = EgyptAlertEvaluator.evaluate(bundle);
      expect(alerts, isEmpty);
    });
  });
}

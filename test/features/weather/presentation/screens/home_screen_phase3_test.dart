import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/advisor/presentation/widgets/what_to_wear_card.dart';
import 'package:taqs/features/air_quality/domain/entities/air_quality.dart';
import 'package:taqs/features/air_quality/presentation/widgets/air_quality_card.dart';
import 'package:taqs/features/alerts/presentation/widgets/severe_weather_alert_card.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/domain/repositories/weather_repository.dart';
import 'package:taqs/features/weather/presentation/screens/home_screen.dart';
import '../../../../helpers/pump_app.dart';

class _FakePhase3WeatherRepo implements WeatherRepository {
  const _FakePhase3WeatherRepo({required this.bundle});
  final WeatherBundle bundle;

  @override
  Future<WeatherBundle> getWeatherForLocation({
    required double latitude,
    required double longitude,
    String? cityNameAr,
    String? cityNameEn,
    bool forceRefresh = false,
  }) async {
    return bundle;
  }
}

void main() {
  group('HomeScreen Phase 3 Features', () {
    testWidgets(
        'renders SevereWeatherAlertCard, WhatToWearCard, and AirQualityCard when data is present',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const testBundle = WeatherBundle(
        current: CurrentWeather(
          temperature: 42,
          feelsLike: 45,
          cityNameAr: 'أسوان',
          cityNameEn: 'Aswan',
          condition: WeatherCondition.sunny,
          humidityPercentage: 20,
          windSpeedKmh: 20,
          uvIndex: 10,
        ),
        hourly: [],
        daily: [],
        airQuality: AirQuality(
          europeanAqi: 75,
          pm10: 80,
          pm2_5: 55,
          dust: 30,
        ),
      );

      await tester.pumpApp(
        const HomeScreen(),
        weatherRepository: const _FakePhase3WeatherRepo(bundle: testBundle),
      );
      await tester.pumpAndSettle();

      // Verify SevereWeatherAlertCard
      expect(find.byType(SevereWeatherAlertCard), findsAtLeastNWidgets(1));
      expect(find.text('تحذير شديد: موجة شديدة الحرارة'), findsOneWidget);

      // Verify WhatToWearCard
      expect(find.byType(WhatToWearCard), findsOneWidget);
      expect(find.text('ماذا أرتدي اليوم؟'), findsOneWidget);

      // Verify AirQualityCard
      expect(find.byType(AirQualityCard), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
      expect(find.text('EAQI'), findsOneWidget);
    });
  });
}

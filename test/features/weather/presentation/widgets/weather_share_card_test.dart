import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/presentation/widgets/weather_share_card.dart';
import 'package:taqs/l10n/app_localizations.dart';

void main() {
  WeatherBundle createTestBundle() {
    return const WeatherBundle(
      current: CurrentWeather(
        temperature: 28,
        feelsLike: 29,
        cityNameAr: 'الإسكندرية',
        cityNameEn: 'Alexandria',
        condition: WeatherCondition.sunny,
        humidityPercentage: 60,
        windSpeedKmh: 18,
        uvIndex: 7,
        precipitationProbability: 10,
      ),
      hourly: [],
      daily: [
        DailyForecast(
          dayNameAr: 'اليوم',
          dayNameEn: 'Today',
          minTemp: 21,
          maxTemp: 29,
          condition: WeatherCondition.sunny,
        ),
      ],
    );
  }

  Widget createSubject({required bool isArabic}) {
    return MaterialApp(
      locale: Locale(isArabic ? 'ar' : 'en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RepaintBoundary(
          child: WeatherShareCard(
            weather: createTestBundle(),
            isArabic: isArabic,
          ),
        ),
      ),
    );
  }

  group('WeatherShareCard', () {
    testWidgets('renders brand title, tagline, location, and temperature in Arabic', (tester) async {
      await tester.pumpWidget(createSubject(isArabic: true));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.appNameAr), findsOneWidget);
      expect(find.text(AppConstants.appTaglineAr), findsOneWidget);
      expect(find.text('الإسكندرية'), findsOneWidget);
      expect(find.text('28°'), findsOneWidget);
      expect(find.text('10%'), findsOneWidget);
    });

    testWidgets('renders in English when isArabic is false', (tester) async {
      await tester.pumpWidget(createSubject(isArabic: false));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.appNameEn), findsOneWidget);
      expect(find.text(AppConstants.appTaglineEn), findsOneWidget);
      expect(find.text('Alexandria'), findsOneWidget);
      expect(find.text('28°'), findsOneWidget);
    });
  });
}

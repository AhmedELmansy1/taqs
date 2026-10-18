import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/design/theme/app_theme.dart';
import 'package:taqs/core/storage/storage_providers.dart';
import 'package:taqs/features/compare/presentation/providers/compare_provider.dart';
import 'package:taqs/features/compare/presentation/screens/compare_governorates_screen.dart';
import 'package:taqs/features/location/data/repositories/egyptian_governorates.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/l10n/app_localizations.dart';

import '../../../../helpers/fake_key_value_storage.dart';

void main() {
  WeatherBundle mockBundle({
    required String cityNameAr,
    required String cityNameEn,
    required int temp,
    int rain = 0,
  }) {
    return WeatherBundle(
      current: CurrentWeather(
        temperature: temp,
        feelsLike: temp + 1,
        cityNameAr: cityNameAr,
        cityNameEn: cityNameEn,
        condition: WeatherCondition.sunny,
        humidityPercentage: 50,
        windSpeedKmh: 15,
        uvIndex: 5,
        precipitationProbability: rain,
      ),
      hourly: const [],
      daily: const [
        DailyForecast(
          dayNameAr: 'اليوم',
          dayNameEn: 'Today',
          minTemp: 18,
          maxTemp: 28,
          condition: WeatherCondition.sunny,
        ),
      ],
    );
  }

  Widget createSubject({
    required WeatherBundle bundle1,
    WeatherBundle? bundle2,
    bool throwError2 = false,
  }) {
    final fakeStorage = FakeKeyValueStorage();
    return ProviderScope(
      overrides: [
        keyValueStorageProvider.overrideWithValue(fakeStorage),
        compareLocation1WeatherProvider.overrideWith((ref) => bundle1),
        if (throwError2)
          compareLocation2WeatherProvider.overrideWith(
            (ref) => Future<WeatherBundle>.error(Exception('Network timeout')),
          )
        else if (bundle2 != null)
          compareLocation2WeatherProvider.overrideWith((ref) => bundle2),
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.darkTheme,
        home: const CompareGovernoratesScreen(),
      ),
    );
  }

  group('CompareGovernoratesScreen', () {
    testWidgets('renders side-by-side weather metrics and difference banner', (tester) async {
      final b1 = mockBundle(cityNameAr: 'القاهرة', cityNameEn: 'Cairo', temp: 30);
      final b2 = mockBundle(cityNameAr: 'الإسكندرية', cityNameEn: 'Alexandria', temp: 26, rain: 20);

      await tester.pumpWidget(createSubject(bundle1: b1, bundle2: b2));
      await tester.pumpAndSettle();

      expect(find.text('مقارنة المحافظات'), findsOneWidget);
      expect(find.text('30°'), findsOneWidget);
      expect(find.text('26°'), findsOneWidget);
      expect(find.textContaining('القاهرة أدفأ بـ 4°م من الإسكندرية'), findsOneWidget);
      expect(find.text('احتمال الأمطار'), findsOneWidget);
    });

    testWidgets('swaps locations when swap action icon is tapped', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(compareSelectionProvider).location1, EgyptianGovernorates.cairo);
      expect(container.read(compareSelectionProvider).location2, EgyptianGovernorates.alexandria);

      container.read(compareSelectionProvider.notifier).swapLocations();

      expect(container.read(compareSelectionProvider).location1, EgyptianGovernorates.alexandria);
      expect(container.read(compareSelectionProvider).location2, EgyptianGovernorates.cairo);
    });

    testWidgets('isolates error if one location fails without breaking the other', (tester) async {
      final b1 = mockBundle(cityNameAr: 'القاهرة', cityNameEn: 'Cairo', temp: 30);

      await tester.pumpWidget(createSubject(bundle1: b1, throwError2: true));
      await tester.pumpAndSettle();

      // Location 1 renders successfully
      expect(find.text('30°'), findsOneWidget);

      // Location 2 shows error gracefully with retry option
      expect(find.text('تعذر تحميل البيانات'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });
  });
}

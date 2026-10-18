import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:taqs/core/widgets/home_widget_manager.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
    await initializeDateFormatting('en');
  });
  WeatherBundle createTestBundle({bool isFromCache = false}) {
    return WeatherBundle(
      isFromCache: isFromCache,
      current: const CurrentWeather(
        temperature: 27,
        feelsLike: 28,
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
        condition: WeatherCondition.sunny,
        humidityPercentage: 55,
        windSpeedKmh: 14,
        uvIndex: 6,
      ),
      hourly: const [],
      daily: const [],
    );
  }

  PrayerTimesBundle createTestPrayer() {
    final now = DateTime(2026, 10, 18, 11);
    final dhuhrTime = DateTime(2026, 10, 18, 11, 58);
    final dhuhrItem = PrayerItem(
      type: PrayerType.dhuhr,
      time: dhuhrTime,
      isNext: true,
      isPast: false,
    );

    return PrayerTimesBundle(
      date: now,
      cityNameAr: 'القاهرة',
      cityNameEn: 'Cairo',
      hijriFormattedAr: '18 ربيع الآخر 1448',
      hijriFormattedEn: '18 Rabi al-Thani 1448',
      gregorianFormattedAr: '18 أكتوبر 2026',
      gregorianFormattedEn: '18 October 2026',
      prayers: [dhuhrItem],
      nextPrayer: dhuhrItem,
      timeToNextPrayer: const Duration(minutes: 58),
      isFriday: false,
    );
  }

  group('HomeWidgetManager', () {
    test('maps domain entities to widget data accurately in Arabic', () {
      final data = HomeWidgetManager.mapToWidgetData(
        weather: createTestBundle(),
        prayerTimes: createTestPrayer(),
        isArabic: true,
      );

      expect(data.temperature, '27°');
      expect(data.cityName, 'القاهرة');
      expect(data.nextPrayer, contains('الظهر'));
      expect(data.updatedTime, contains('مُحدَّث'));
    });

    test('maps domain entities to widget data in English', () {
      final data = HomeWidgetManager.mapToWidgetData(
        weather: createTestBundle(),
        prayerTimes: createTestPrayer(),
        isArabic: false,
      );

      expect(data.temperature, '27°');
      expect(data.cityName, 'Cairo');
      expect(data.nextPrayer, contains('Dhuhr'));
      expect(data.updatedTime, contains('Updated'));
    });

    test('marks stale cached data with appropriate label when offline', () {
      final data = HomeWidgetManager.mapToWidgetData(
        weather: createTestBundle(isFromCache: true),
        prayerTimes: createTestPrayer(),
        isArabic: true,
      );

      expect(data.updatedTime, contains('قديم'));
    });
  });
}

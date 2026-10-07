import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/features/weather/data/cache/weather_cache.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import '../../../../helpers/fake_key_value_storage.dart';

void main() {
  group('KeyValueWeatherCache', () {
    late FakeKeyValueStorage fakeStorage;
    late KeyValueWeatherCache cache;

    const testBundle = WeatherBundle(
      current: CurrentWeather(
        temperature: 28,
        feelsLike: 30,
        cityNameAr: AppConstants.defaultCityNameAr,
        cityNameEn: AppConstants.defaultCityNameEn,
        condition: WeatherCondition.sunny,
        humidityPercentage: 45,
        windSpeedKmh: 15,
        uvIndex: 7,
      ),
      hourly: [],
      daily: [],
    );

    setUp(() {
      fakeStorage = FakeKeyValueStorage();
      cache = KeyValueWeatherCache(storage: fakeStorage);
    });

    test('getCachedWeather returns null when cache is empty', () async {
      final result = await cache.getCachedWeather(
        latitude: 30.0444,
        longitude: 31.2357,
      );

      expect(result, isNull);
    });

    test('saveWeather persists bundle and getCachedWeather restores it', () async {
      final now = DateTime.now();
      await cache.saveWeather(
        latitude: 30.0444,
        longitude: 31.2357,
        bundle: testBundle,
        fetchedAt: now,
      );

      final result = await cache.getCachedWeather(
        latitude: 30.0444,
        longitude: 31.2357,
      );

      expect(result, isNotNull);
      expect(result!.bundle.current.temperature, equals(28));
      expect(result.bundle.isFromCache, isTrue);
      expect(result.isStale(), isFalse);
    });

    test('isStale returns true when duration exceeds TTL', () {
      final oldTime = DateTime.now().subtract(const Duration(minutes: 25));
      final entry = WeatherCachedEntry(bundle: testBundle, fetchedAt: oldTime);

      expect(entry.isStale(), isTrue);
    });

    test('clear removes all entries', () async {
      await cache.saveWeather(
        latitude: 30.0444,
        longitude: 31.2357,
        bundle: testBundle,
        fetchedAt: DateTime.now(),
      );

      await cache.clear();

      final result = await cache.getCachedWeather(
        latitude: 30.0444,
        longitude: 31.2357,
      );

      expect(result, isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/errors/app_failure.dart';
import 'package:taqs/features/weather/data/cache/weather_cache.dart';
import 'package:taqs/features/weather/data/data_sources/open_meteo_remote_data_source.dart';
import 'package:taqs/features/weather/data/models/open_meteo_dto.dart';
import 'package:taqs/features/weather/data/repositories/open_meteo_weather_repository.dart';
import '../../../../helpers/fake_key_value_storage.dart';

class _FakeOpenMeteoRemoteDataSource implements OpenMeteoRemoteDataSource {
  int callCount = 0;
  bool shouldThrow = false;
  AppFailure failure = const NoConnectionFailure();

  @override
  Future<OpenMeteoForecastDto> getForecast({
    required double latitude,
    required double longitude,
  }) async {
    callCount++;
    if (shouldThrow) {
      throw failure;
    }

    return const OpenMeteoForecastDto(
      latitude: 30.0444,
      longitude: 31.2357,
      current: OpenMeteoCurrentDto(
        time: '2026-10-07T12:00',
        temperature2m: 31,
        relativeHumidity2m: 40,
        apparentTemperature: 33,
        isDay: 1,
        precipitation: 0,
        weatherCode: 0,
        windSpeed10m: 12,
      ),
      hourly: OpenMeteoHourlyDto(
        time: ['2026-10-07T12:00'],
        temperature2m: [31],
        weatherCode: [0],
      ),
      daily: OpenMeteoDailyDto(
        time: ['2026-10-07'],
        weatherCode: [0],
        temperature2mMax: [32],
        temperature2mMin: [20],
        uvIndexMax: [7],
      ),
    );
  }
}

void main() {
  group('OpenMeteoWeatherRepository', () {
    late _FakeOpenMeteoRemoteDataSource fakeRemote;
    late KeyValueWeatherCache cache;
    late OpenMeteoWeatherRepository repository;

    setUp(() {
      fakeRemote = _FakeOpenMeteoRemoteDataSource();
      cache = KeyValueWeatherCache(storage: FakeKeyValueStorage());
      repository = OpenMeteoWeatherRepository(
        remoteDataSource: fakeRemote,
        cache: cache,
      );
    });

    test('fetches from remote and caches result on cache miss', () async {
      final result = await repository.getWeatherForLocation(
        latitude: 30.0444,
        longitude: 31.2357,
      );

      expect(result.current.temperature, equals(31));
      expect(result.isFromCache, isFalse);
      expect(fakeRemote.callCount, equals(1));

      // Second call within TTL should return from cache
      final cachedResult = await repository.getWeatherForLocation(
        latitude: 30.0444,
        longitude: 31.2357,
      );

      expect(cachedResult.current.temperature, equals(31));
      expect(fakeRemote.callCount, equals(1)); // Remote wasn't called again!
    });

    test('returns cached bundle with isFromCache true when remote fails', () async {
      // First populate cache
      await repository.getWeatherForLocation(
        latitude: 30.0444,
        longitude: 31.2357,
      );

      // Now simulate network failure with force refresh
      fakeRemote.shouldThrow = true;
      final fallbackResult = await repository.getWeatherForLocation(
        latitude: 30.0444,
        longitude: 31.2357,
        forceRefresh: true,
      );

      expect(fallbackResult.current.temperature, equals(31));
      expect(fallbackResult.isFromCache, isTrue);
    });

    test('rethrows failure when remote fails and no cache is present', () async {
      fakeRemote.shouldThrow = true;

      expect(
        () => repository.getWeatherForLocation(
          latitude: 30.0444,
          longitude: 31.2357,
        ),
        throwsA(isA<NoConnectionFailure>()),
      );
    });
  });
}

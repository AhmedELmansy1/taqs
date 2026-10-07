import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/features/weather/data/cache/weather_cache.dart';
import 'package:taqs/features/weather/data/data_sources/open_meteo_remote_data_source.dart';
import 'package:taqs/features/weather/data/repositories/mock_weather_repository.dart';
import 'package:taqs/features/weather/data/repositories/open_meteo_weather_repository.dart';
import 'package:taqs/features/weather/domain/repositories/weather_repository.dart';

/// Provider exposing [MockWeatherRepository] for unit tests and deterministic mocks.
final mockWeatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return const MockWeatherRepository();
});

/// Primary provider exposing [WeatherRepository] contract.
/// Backed by production [OpenMeteoWeatherRepository] with offline caching.
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final remoteDataSource = ref.watch(openMeteoRemoteDataSourceProvider);
  final cache = ref.watch(weatherCacheProvider);
  return OpenMeteoWeatherRepository(
    remoteDataSource: remoteDataSource,
    cache: cache,
  );
});

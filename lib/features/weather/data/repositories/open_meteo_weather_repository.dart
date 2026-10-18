import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/features/air_quality/data/data_sources/open_meteo_air_quality_data_source.dart';
import 'package:taqs/features/air_quality/domain/entities/air_quality.dart';
import 'package:taqs/features/weather/data/cache/weather_cache.dart';
import 'package:taqs/features/weather/data/data_sources/open_meteo_remote_data_source.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/domain/repositories/weather_repository.dart';

/// Production implementation of [WeatherRepository] consuming Open-Meteo
/// with local offline caching, air quality enrichment and stale-while-revalidate fallbacks.
class OpenMeteoWeatherRepository implements WeatherRepository {
  const OpenMeteoWeatherRepository({
    required this.remoteDataSource,
    required this.cache,
    this.airQualityDataSource,
  });

  final OpenMeteoRemoteDataSource remoteDataSource;
  final WeatherCache cache;
  final OpenMeteoAirQualityDataSource? airQualityDataSource;

  @override
  Future<WeatherBundle> getWeatherForLocation({
    required double latitude,
    required double longitude,
    String? cityNameAr,
    String? cityNameEn,
    bool forceRefresh = false,
  }) async {
    final cached = await cache.getCachedWeather(
      latitude: latitude,
      longitude: longitude,
    );

    // If cache is fresh and forceRefresh is false, return immediately
    if (!forceRefresh && cached != null && !cached.isStale()) {
      return cached.bundle;
    }

    try {
      final dto = await remoteDataSource.getForecast(
        latitude: latitude,
        longitude: longitude,
      );

      AirQuality? airQuality;
      if (airQualityDataSource != null) {
        try {
          final aqiDto = await airQualityDataSource!.getAirQuality(
            latitude: latitude,
            longitude: longitude,
          );
          airQuality = aqiDto.toDomain();
        } on Object catch (_) {
          airQuality = cached?.bundle.airQuality;
        }
      }

      final freshBundle = dto
          .toDomain(
            cityNameAr: cityNameAr ??
                cached?.bundle.current.cityNameAr ??
                AppConstants.defaultCityNameAr,
            cityNameEn: cityNameEn ??
                cached?.bundle.current.cityNameEn ??
                AppConstants.defaultCityNameEn,
            fetchedAt: DateTime.now(),
          )
          .copyWith(airQuality: airQuality);

      // Persist to local cache
      await cache.saveWeather(
        latitude: latitude,
        longitude: longitude,
        bundle: freshBundle,
        fetchedAt: DateTime.now(),
      );

      return freshBundle;
    } on Object catch (_) {
      // Stale fallback: if remote call fails but we have cached data, return it
      if (cached != null) {
        return cached.bundle.copyWith(isFromCache: true);
      }
      rethrow;
    }
  }

  /// Direct cache probe to allow ViewModels to populate UI instantly
  Future<WeatherCachedEntry?> peekCache({
    required double latitude,
    required double longitude,
  }) {
    return cache.getCachedWeather(latitude: latitude, longitude: longitude);
  }
}

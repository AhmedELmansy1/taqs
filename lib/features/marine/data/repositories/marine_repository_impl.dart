import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/features/marine/data/data_sources/open_meteo_marine_remote_data_source.dart';
import 'package:taqs/features/marine/domain/entities/marine_conditions.dart';
import 'package:taqs/features/marine/domain/repositories/marine_repository.dart';

/// Concrete repository implementation fetching marine data with caching.
class MarineRepositoryImpl implements MarineRepository {
  MarineRepositoryImpl({
    OpenMeteoMarineRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
            remoteDataSource ?? OpenMeteoMarineRemoteDataSource();

  final OpenMeteoMarineRemoteDataSource _remoteDataSource;
  final Map<String, MarineConditions> _memoryCache = {};

  @override
  Future<MarineConditions?> getMarineConditions({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        '${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

    if (!forceRefresh && _memoryCache.containsKey(cacheKey)) {
      final cached = _memoryCache[cacheKey]!;
      // Cache valid for 3 hours
      if (DateTime.now().difference(cached.fetchedAt).inHours < 3) {
        return MarineConditions(
          waveHeightMeters: cached.waveHeightMeters,
          wavePeriodSeconds: cached.wavePeriodSeconds,
          waveDirectionDegrees: cached.waveDirectionDegrees,
          windWaveHeightMeters: cached.windWaveHeightMeters,
          rating: cached.rating,
          fetchedAt: cached.fetchedAt,
          isFromCache: true,
        );
      }
    }

    final fresh = await _remoteDataSource.fetchMarineConditions(
      latitude: latitude,
      longitude: longitude,
    );

    if (fresh != null) {
      _memoryCache[cacheKey] = fresh;
    }

    return fresh;
  }
}

/// Provider for [MarineRepository].
final marineRepositoryProvider = Provider<MarineRepository>((ref) {
  return MarineRepositoryImpl();
});

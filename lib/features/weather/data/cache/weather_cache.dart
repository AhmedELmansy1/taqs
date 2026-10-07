import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/storage/key_value_storage.dart';
import 'package:taqs/core/storage/storage_providers.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// Cached weather entry containing payload and timestamp.
class WeatherCachedEntry {
  const WeatherCachedEntry({
    required this.bundle,
    required this.fetchedAt,
  });

  final WeatherBundle bundle;
  final DateTime fetchedAt;

  /// Checks if cached entry has exceeded the [ttl] duration.
  bool isStale({Duration ttl = const Duration(minutes: 20)}) {
    return DateTime.now().difference(fetchedAt) > ttl;
  }
}

/// Abstract contract for local offline weather caching.
abstract interface class WeatherCache {
  /// Retrieves the cached weather entry for the given coordinates, or null.
  Future<WeatherCachedEntry?> getCachedWeather({
    required double latitude,
    required double longitude,
  });

  /// Saves the weather bundle with the fetch timestamp.
  Future<void> saveWeather({
    required double latitude,
    required double longitude,
    required WeatherBundle bundle,
    required DateTime fetchedAt,
  });

  /// Clears all cached weather entries.
  Future<void> clear();
}

/// Production implementation of [WeatherCache] backed by [KeyValueStorage].
class KeyValueWeatherCache implements WeatherCache {
  const KeyValueWeatherCache({
    required this.storage,
  });

  final KeyValueStorage storage;

  static const String _prefix = 'weather_cache_';

  String _buildKey(double latitude, double longitude) {
    return '$_prefix${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
  }

  @override
  Future<WeatherCachedEntry?> getCachedWeather({
    required double latitude,
    required double longitude,
  }) async {
    final key = _buildKey(latitude, longitude);
    final rawJson = await storage.getString(key);
    if (rawJson == null) return null;

    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      final fetchedAt = DateTime.parse(map['fetchedAt'] as String);
      final rawBundle = map['bundle'] as Map<String, dynamic>;
      final bundle = WeatherBundle.fromJson(rawBundle).copyWith(
        fetchedAt: fetchedAt,
        isFromCache: true,
      );

      return WeatherCachedEntry(bundle: bundle, fetchedAt: fetchedAt);
    } on Object catch (_) {
      // Corrupt or outdated format
      await storage.remove(key);
      return null;
    }
  }

  @override
  Future<void> saveWeather({
    required double latitude,
    required double longitude,
    required WeatherBundle bundle,
    required DateTime fetchedAt,
  }) async {
    final key = _buildKey(latitude, longitude);
    final payload = {
      'fetchedAt': fetchedAt.toIso8601String(),
      'bundle': bundle.copyWith(fetchedAt: fetchedAt).toJson(),
    };
    await storage.setString(key, jsonEncode(payload));
  }

  @override
  Future<void> clear() async {
    await storage.clear();
  }
}

/// Provider for [WeatherCache].
final weatherCacheProvider = Provider<WeatherCache>((ref) {
  final storage = ref.watch(keyValueStorageProvider);
  return KeyValueWeatherCache(storage: storage);
});

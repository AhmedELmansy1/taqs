import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// Contract for fetching weather data.
///
/// Phase 1 implements this with mock static data.
/// Phase 2 will introduce an Open-Meteo HTTP implementation without modifying the presentation layer.
abstract interface class WeatherRepository {
  /// Fetches weather bundle for coordinates.
  Future<WeatherBundle> getWeatherForLocation({
    required double latitude,
    required double longitude,
  });
}

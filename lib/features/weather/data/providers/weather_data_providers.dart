import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/features/weather/data/repositories/mock_weather_repository.dart';
import 'package:taqs/features/weather/domain/repositories/weather_repository.dart';

/// Provider exposing [WeatherRepository] contract.
/// In Phase 1, backed by [MockWeatherRepository].
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return const MockWeatherRepository();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/features/weather/data/providers/weather_data_providers.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// ViewModel managing the weather bundle state for the active location.
class WeatherViewModel extends AsyncNotifier<WeatherBundle> {
  @override
  Future<WeatherBundle> build() async {
    final repository = ref.watch(weatherRepositoryProvider);
    return await repository.getWeatherForLocation(
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
    );
  }

  /// Refreshes current weather data.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(weatherRepositoryProvider);
      return await repository.getWeatherForLocation(
        latitude: AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude,
      );
    });
  }
}

/// Provider for [WeatherViewModel].
final weatherViewModelProvider =
    AsyncNotifierProvider<WeatherViewModel, WeatherBundle>(
  WeatherViewModel.new,
);

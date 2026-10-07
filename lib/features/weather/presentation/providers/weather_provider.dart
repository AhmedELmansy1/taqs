import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/features/location/presentation/providers/location_controller.dart';
import 'package:taqs/features/weather/data/providers/weather_data_providers.dart';
import 'package:taqs/features/weather/data/repositories/open_meteo_weather_repository.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// ViewModel managing the weather bundle state for the active location.
class WeatherViewModel extends AsyncNotifier<WeatherBundle> {
  @override
  Future<WeatherBundle> build() async {
    final locationState = ref.watch(locationControllerProvider);
    final activeLocation = locationState.selectedLocation;
    final repository = ref.watch(weatherRepositoryProvider);

    // Check cache first for stale-while-revalidate immediate display
    if (repository is OpenMeteoWeatherRepository) {
      final cached = await repository.peekCache(
        latitude: activeLocation.latitude,
        longitude: activeLocation.longitude,
      );
      if (cached != null) {
        state = AsyncData(cached.bundle);
      }
    }

    return await repository.getWeatherForLocation(
      latitude: activeLocation.latitude,
      longitude: activeLocation.longitude,
      cityNameAr: activeLocation.nameAr,
      cityNameEn: activeLocation.nameEn,
    );
  }

  /// Refreshes weather data for active location, forcing remote fetch.
  Future<void> refresh() async {
    final activeLocation =
        ref.read(locationControllerProvider).selectedLocation;
    final repository = ref.read(weatherRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository.getWeatherForLocation(
        latitude: activeLocation.latitude,
        longitude: activeLocation.longitude,
        cityNameAr: activeLocation.nameAr,
        cityNameEn: activeLocation.nameEn,
        forceRefresh: true,
      );
    });
  }
}

/// Provider for [WeatherViewModel].
final weatherViewModelProvider =
    AsyncNotifierProvider<WeatherViewModel, WeatherBundle>(
  WeatherViewModel.new,
);

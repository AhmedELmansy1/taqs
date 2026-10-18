import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/features/location/data/repositories/egyptian_governorates.dart';
import 'package:taqs/features/location/domain/entities/location_item.dart';
import 'package:taqs/features/weather/data/providers/weather_data_providers.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// State holding two selected locations for side-by-side weather comparison.
class CompareSelectionState {
  const CompareSelectionState({
    required this.location1,
    required this.location2,
  });

  final LocationItem location1;
  final LocationItem location2;

  CompareSelectionState copyWith({
    LocationItem? location1,
    LocationItem? location2,
  }) {
    return CompareSelectionState(
      location1: location1 ?? this.location1,
      location2: location2 ?? this.location2,
    );
  }
}

/// Notifier managing compare selections.
class CompareSelectionNotifier extends Notifier<CompareSelectionState> {
  @override
  CompareSelectionState build() {
    return const CompareSelectionState(
      location1: EgyptianGovernorates.cairo,
      location2: EgyptianGovernorates.alexandria,
    );
  }

  void setLocation1(LocationItem loc) {
    state = state.copyWith(location1: loc);
  }

  void setLocation2(LocationItem loc) {
    state = state.copyWith(location2: loc);
  }

  void swapLocations() {
    state = CompareSelectionState(
      location1: state.location2,
      location2: state.location1,
    );
  }
}

final compareSelectionProvider =
    NotifierProvider<CompareSelectionNotifier, CompareSelectionState>(
  CompareSelectionNotifier.new,
);

/// Weather provider for the first compared location.
final compareLocation1WeatherProvider =
    FutureProvider<WeatherBundle>((ref) async {
  final loc = ref.watch(compareSelectionProvider).location1;
  final repo = ref.watch(weatherRepositoryProvider);
  return await repo.getWeatherForLocation(
    latitude: loc.latitude,
    longitude: loc.longitude,
    cityNameAr: loc.nameAr,
    cityNameEn: loc.nameEn,
  );
});

/// Weather provider for the second compared location.
final compareLocation2WeatherProvider =
    FutureProvider<WeatherBundle>((ref) async {
  final loc = ref.watch(compareSelectionProvider).location2;
  final repo = ref.watch(weatherRepositoryProvider);
  return await repo.getWeatherForLocation(
    latitude: loc.latitude,
    longitude: loc.longitude,
    cityNameAr: loc.nameAr,
    cityNameEn: loc.nameEn,
  );
});

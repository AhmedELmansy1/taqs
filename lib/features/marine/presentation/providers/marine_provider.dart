import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/features/location/presentation/providers/location_controller.dart';
import 'package:taqs/features/marine/data/repositories/marine_repository_impl.dart';
import 'package:taqs/features/marine/domain/entities/marine_conditions.dart';

/// Provider returning active [MarineConditions] for the selected location (or null for inland).
final marineConditionsProvider =
    FutureProvider<MarineConditions?>((ref) async {
  final locationState = ref.watch(locationControllerProvider);
  final loc = locationState.selectedLocation;
  final repo = ref.watch(marineRepositoryProvider);

  return await repo.getMarineConditions(
    latitude: loc.latitude,
    longitude: loc.longitude,
  );
});

import 'package:taqs/features/marine/domain/entities/marine_conditions.dart';

/// Contract for fetching marine conditions for coastal coordinates.
abstract interface class MarineRepository {
  /// Fetches marine conditions for coordinates. Returns `null` if the location
  /// is inland or outside oceanic forecast grid points.
  Future<MarineConditions?> getMarineConditions({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  });
}

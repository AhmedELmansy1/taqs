import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Enum representing the status of location permissions.
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

/// Abstract contract for device location queries and permission checks.
abstract interface class LocationService {
  /// Returns whether device location services (GPS) are activated.
  Future<bool> isLocationServiceEnabled();

  /// Checks the current permission state without requesting.
  Future<LocationPermissionStatus> checkPermission();

  /// Requests location permission from the operating system.
  Future<LocationPermissionStatus> requestPermission();

  /// Retrieves the current device coordinates (latitude, longitude),
  /// or null if unavailable or denied.
  Future<({double latitude, double longitude})?> getCurrentCoordinates();

  /// Opens the OS application settings page for manual permission granting.
  Future<void> openAppSettings();

  /// Opens the device system location settings dialog.
  Future<void> openLocationSettings();
}

/// Production implementation of [LocationService] using `geolocator`.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final isEnabled = await isLocationServiceEnabled();
    if (!isEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    return _mapPermission(permission);
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    final isEnabled = await isLocationServiceEnabled();
    if (!isEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    final permission = await Geolocator.requestPermission();
    return _mapPermission(permission);
  }

  @override
  Future<({double latitude, double longitude})?> getCurrentCoordinates() async {
    final isEnabled = await isLocationServiceEnabled();
    if (!isEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );

    return (latitude: position.latitude, longitude: position.longitude);
  }

  @override
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  @override
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  LocationPermissionStatus _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.deniedForever;
    }
  }
}

/// Provider for [LocationService].
final locationServiceProvider = Provider<LocationService>((ref) {
  return const GeolocatorLocationService();
});

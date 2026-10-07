import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/permissions/location_service.dart';
import 'package:taqs/core/storage/key_value_storage.dart';
import 'package:taqs/core/storage/storage_providers.dart';
import 'package:taqs/features/location/data/repositories/egyptian_governorates.dart';
import 'package:taqs/features/location/domain/entities/location_item.dart';

/// State representation for location management.
@immutable
class LocationState {
  const LocationState({
    required this.selectedLocation,
    required this.favoriteLocations,
    this.isLoadingGps = false,
    this.permissionStatus,
    this.errorMessage,
  });

  final LocationItem selectedLocation;
  final List<LocationItem> favoriteLocations;
  final bool isLoadingGps;
  final LocationPermissionStatus? permissionStatus;
  final String? errorMessage;

  LocationState copyWith({
    LocationItem? selectedLocation,
    List<LocationItem>? favoriteLocations,
    bool? isLoadingGps,
    LocationPermissionStatus? permissionStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LocationState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      favoriteLocations: favoriteLocations ?? this.favoriteLocations,
      isLoadingGps: isLoadingGps ?? this.isLoadingGps,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Controller managing active location, GPS permissions and favorite cities.
class LocationController extends Notifier<LocationState> {
  static const String _selectedKey = 'selected_location';
  static const String _favoritesKey = 'favorite_locations';

  bool _isInitialized = false;

  KeyValueStorage get _storage => ref.read(keyValueStorageProvider);
  LocationService get _locationService => ref.read(locationServiceProvider);

  @override
  LocationState build() {
    _isInitialized = false;
    unawaited(_loadPersisted());
    return const LocationState(
      selectedLocation: EgyptianGovernorates.cairo,
      favoriteLocations: [
        EgyptianGovernorates.cairo,
        EgyptianGovernorates.alexandria,
        EgyptianGovernorates.giza,
      ],
    );
  }

  Future<void> _loadPersisted() async {
    final rawSelected = await _storage.getString(_selectedKey);
    final rawFavorites = await _storage.getString(_favoritesKey);

    if (_isInitialized) return;
    _isInitialized = true;

    LocationItem? restoredSelected;
    if (rawSelected != null) {
      try {
        restoredSelected = LocationItem.fromJson(
          jsonDecode(rawSelected) as Map<String, dynamic>,
        );
      } on Object catch (_) {}
    }

    List<LocationItem>? restoredFavorites;
    if (rawFavorites != null) {
      try {
        final list = jsonDecode(rawFavorites) as List<dynamic>;
        restoredFavorites = list
            .map((e) => LocationItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } on Object catch (_) {}
    }

    if (restoredSelected == null && restoredFavorites == null) return;
    if (restoredSelected == state.selectedLocation &&
        restoredFavorites == null) {
      return;
    }

    if (ref.mounted) {
      state = state.copyWith(
        selectedLocation: restoredSelected ?? state.selectedLocation,
        favoriteLocations: restoredFavorites ?? state.favoriteLocations,
      );
    }
  }

  /// Sets the currently active location and persists choice.
  Future<void> selectLocation(LocationItem location) async {
    _isInitialized = true;
    state = state.copyWith(
      selectedLocation: location,
      clearError: true,
    );
    await _storage.setString(_selectedKey, jsonEncode(location.toJson()));
  }

  /// Requests device GPS coordinates and activates current location.
  Future<bool> requestCurrentGpsLocation() async {
    _isInitialized = true;
    state = state.copyWith(isLoadingGps: true, clearError: true);

    try {
      final isEnabled = await _locationService.isLocationServiceEnabled();
      if (!isEnabled) {
        state = state.copyWith(
          isLoadingGps: false,
          permissionStatus: LocationPermissionStatus.serviceDisabled,
          errorMessage: 'خدمة تحديد الموقع (GPS) غير مفعلة في جهازك.',
        );
        return false;
      }

      final status = await _locationService.requestPermission();
      if (status != LocationPermissionStatus.granted) {
        state = state.copyWith(
          isLoadingGps: false,
          permissionStatus: status,
          errorMessage: status == LocationPermissionStatus.deniedForever
              ? 'تم رفض إذن الموقع بشكل دائم. يُرجى تفعيله من إعدادات الهاتف.'
              : 'تم رفض إذن الوصول إلى الموقع.',
        );
        return false;
      }

      final coords = await _locationService.getCurrentCoordinates();
      if (coords == null) {
        state = state.copyWith(
          isLoadingGps: false,
          errorMessage: 'تعذر تحديد الإحداثيات الحالية بدقة.',
        );
        return false;
      }

      const currentLocationItem = LocationItem(
        id: 'current_device_location',
        nameAr: 'موقعي الحالي',
        nameEn: 'Current Location',
        latitude: 0,
        longitude: 0,
        isCurrentLocation: true,
      );

      final updatedLocation = currentLocationItem.copyWith(
        latitude: coords.latitude,
        longitude: coords.longitude,
      );

      await selectLocation(updatedLocation);

      state = state.copyWith(
        isLoadingGps: false,
        permissionStatus: LocationPermissionStatus.granted,
        clearError: true,
      );
      return true;
    } on Object catch (e) {
      state = state.copyWith(
        isLoadingGps: false,
        errorMessage: 'حدث خطأ أثناء تحديد الموقع: $e',
      );
      return false;
    }
  }

  /// Toggles favorite status for a location (up to 5 max).
  Future<void> toggleFavorite(LocationItem location) async {
    _isInitialized = true;
    final currentFavorites = List<LocationItem>.from(state.favoriteLocations);
    final exists = currentFavorites.any((e) => e.id == location.id);

    if (exists) {
      currentFavorites.removeWhere((e) => e.id == location.id);
    } else {
      if (currentFavorites.length >= 5) {
        currentFavorites.removeLast();
      }
      currentFavorites.insert(0, location);
    }

    state = state.copyWith(favoriteLocations: currentFavorites);
    final serialized =
        jsonEncode(currentFavorites.map((e) => e.toJson()).toList());
    await _storage.setString(_favoritesKey, serialized);
  }

  /// Opens the device settings.
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }
}

/// Provider for [LocationController].
final locationControllerProvider =
    NotifierProvider<LocationController, LocationState>(
  LocationController.new,
);

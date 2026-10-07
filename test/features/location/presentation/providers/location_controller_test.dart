import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/permissions/location_service.dart';
import 'package:taqs/core/storage/storage_providers.dart';
import 'package:taqs/features/location/data/repositories/egyptian_governorates.dart';
import 'package:taqs/features/location/presentation/providers/location_controller.dart';
import '../../../../helpers/fake_key_value_storage.dart';

class _FakeLocationService implements LocationService {
  bool serviceEnabled = true;
  LocationPermissionStatus permissionStatus = LocationPermissionStatus.granted;
  ({double latitude, double longitude})? coordinates =
      (latitude: 31.2001, longitude: 29.9187);
  int appSettingsOpened = 0;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermissionStatus> checkPermission() async => permissionStatus;

  @override
  Future<LocationPermissionStatus> requestPermission() async => permissionStatus;

  @override
  Future<({double latitude, double longitude})?> getCurrentCoordinates() async =>
      coordinates;

  @override
  Future<void> openAppSettings() async {
    appSettingsOpened++;
  }
}

void main() {
  group('LocationController', () {
    late FakeKeyValueStorage fakeStorage;
    late _FakeLocationService fakeLocationService;

    setUp(() {
      fakeStorage = FakeKeyValueStorage();
      fakeLocationService = _FakeLocationService();
    });

    test('initializes with Cairo as default active location', () {
      final container = ProviderContainer(
        overrides: [
          keyValueStorageProvider.overrideWithValue(fakeStorage),
          locationServiceProvider.overrideWithValue(fakeLocationService),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(locationControllerProvider);
      expect(state.selectedLocation.id, equals(EgyptianGovernorates.cairo.id));
      expect(state.selectedLocation.nameAr, equals('القاهرة'));
      expect(state.favoriteLocations.length, equals(3));
    });

    test('selectLocation updates state and persists selection', () async {
      final container = ProviderContainer(
        overrides: [
          keyValueStorageProvider.overrideWithValue(fakeStorage),
          locationServiceProvider.overrideWithValue(fakeLocationService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(locationControllerProvider.notifier);
      await controller.selectLocation(EgyptianGovernorates.alexandria);

      final state = container.read(locationControllerProvider);
      expect(state.selectedLocation.id, equals(EgyptianGovernorates.alexandria.id));
      expect(state.selectedLocation.nameAr, equals('الإسكندرية'));

      // Check persistence
      final persisted = await fakeStorage.getString('selected_location');
      expect(persisted, contains('الإسكندرية'));
    });

    test('toggleFavorite toggles presence in favorite list up to limit', () async {
      final container = ProviderContainer(
        overrides: [
          keyValueStorageProvider.overrideWithValue(fakeStorage),
          locationServiceProvider.overrideWithValue(fakeLocationService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(locationControllerProvider.notifier);

      // Add Luxor
      await controller.toggleFavorite(EgyptianGovernorates.luxor);
      var state = container.read(locationControllerProvider);
      expect(state.favoriteLocations.any((e) => e.id == 'gov_luxor'), isTrue);

      // Remove Luxor
      await controller.toggleFavorite(EgyptianGovernorates.luxor);
      state = container.read(locationControllerProvider);
      expect(state.favoriteLocations.any((e) => e.id == 'gov_luxor'), isFalse);
    });

    test('requestCurrentGpsLocation updates location on success', () async {
      final container = ProviderContainer(
        overrides: [
          keyValueStorageProvider.overrideWithValue(fakeStorage),
          locationServiceProvider.overrideWithValue(fakeLocationService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(locationControllerProvider.notifier);
      final result = await controller.requestCurrentGpsLocation();

      expect(result, isTrue);
      final state = container.read(locationControllerProvider);
      expect(state.selectedLocation.isCurrentLocation, isTrue);
      expect(state.selectedLocation.latitude, equals(31.2001));
    });

    test('requestCurrentGpsLocation sets error when permission denied', () async {
      fakeLocationService.permissionStatus = LocationPermissionStatus.denied;

      final container = ProviderContainer(
        overrides: [
          keyValueStorageProvider.overrideWithValue(fakeStorage),
          locationServiceProvider.overrideWithValue(fakeLocationService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(locationControllerProvider.notifier);
      final result = await controller.requestCurrentGpsLocation();

      expect(result, isFalse);
      final state = container.read(locationControllerProvider);
      expect(state.permissionStatus, equals(LocationPermissionStatus.denied));
      expect(state.errorMessage, isNotNull);
    });
  });
}

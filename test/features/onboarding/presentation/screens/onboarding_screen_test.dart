import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/design/components/permission_recovery_banner.dart';
import 'package:taqs/core/permissions/location_service.dart';
import 'package:taqs/core/storage/storage_providers.dart';
import 'package:taqs/features/location/presentation/providers/location_controller.dart';
import 'package:taqs/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:taqs/features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../../../helpers/fake_key_value_storage.dart';
import '../../../../helpers/pump_app.dart';

class _MockLocationService implements LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.granted;

  @override
  Future<({double latitude, double longitude})?> getCurrentCoordinates() async =>
      (latitude: 30.0444, longitude: 31.2357);

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> openLocationSettings() async {}

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.granted;
}

void main() {
  group('Onboarding & Permissions', () {
    late FakeKeyValueStorage fakeStorage;

    setUp(() {
      fakeStorage = FakeKeyValueStorage();
    });

    testWidgets('OnboardingScreen renders initial welcome step and steps through',
        (tester) async {
      await tester.pumpApp(
        ProviderScope(
          overrides: [
            keyValueStorageProvider.overrideWithValue(fakeStorage),
            locationServiceProvider.overrideWithValue(_MockLocationService()),
          ],
          child: const OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Welcome title
      expect(find.text('أهلاً بك في طقس'), findsOneWidget);

      // Tap Next to step 2 (Location)
      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();
      expect(find.text('تحديد الموقع الجغرافي'), findsOneWidget);

      // Tap Next to step 3 (Notifications)
      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();
      expect(find.text('إشعارات الطقس كل 12 ساعة'), findsOneWidget);
      expect(find.text('ابدأ الآن'), findsOneWidget);
    });

    testWidgets('PermissionRecoveryBanner shows when location is denied and dismisses',
        (tester) async {
      await tester.pumpApp(
        ProviderScope(
          overrides: [
            keyValueStorageProvider.overrideWithValue(fakeStorage),
            locationServiceProvider.overrideWithValue(_MockLocationService()),
            locationControllerProvider.overrideWith(_DeniedLocationController.new),
          ],
          child: const Scaffold(
            body: PermissionRecoveryBanner(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('فعل إذن الموقع للحصول على طقس حقيقي لمكانك'),
        findsOneWidget,
      );

      // Dismiss banner
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(
        find.text('فعل إذن الموقع للحصول على طقس حقيقي لمكانك'),
        findsNothing,
      );
    });

    test('OnboardingController tracks and persists completed status', () async {
      final container = ProviderContainer(
        overrides: [
          keyValueStorageProvider.overrideWithValue(fakeStorage),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(onboardingControllerProvider.notifier);
      expect(await controller.checkStatus(), isFalse);

      await controller.completeOnboarding();
      expect(await controller.checkStatus(), isTrue);
      expect(
        await fakeStorage.getString(OnboardingController.onboardingCompletedKey),
        'true',
      );
    });
  });
}

class _DeniedLocationController extends LocationController {
  @override
  LocationState build() {
    return super.build().copyWith(
          permissionStatus: LocationPermissionStatus.denied,
        );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/notifications/notification_service.dart';
import 'package:taqs/core/notifications/notification_settings_controller.dart';
import 'package:taqs/core/storage/storage_providers.dart';
import '../../helpers/fake_key_value_storage.dart';
import '../../helpers/fake_notification_service.dart';

void main() {
  group('NotificationSettingsController', () {
    late FakeKeyValueStorage fakeStorage;
    late FakeNotificationService fakeNotifications;
    late ProviderContainer container;

    setUp(() {
      fakeStorage = FakeKeyValueStorage();
      fakeNotifications = FakeNotificationService();
      container = ProviderContainer(
        overrides: [
          keyValueStorageProvider.overrideWithValue(fakeStorage),
          notificationServiceProvider.overrideWithValue(fakeNotifications),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('defaults to both notifications enabled', () {
      final state = container.read(notificationSettingsControllerProvider);
      expect(state.severeAlertsEnabled, isTrue);
      expect(state.dailyBriefingEnabled, isTrue);
    });

    test('toggles severeAlertsEnabled and updates storage', () async {
      final controller =
          container.read(notificationSettingsControllerProvider.notifier);

      await controller.setSevereAlertsEnabled(enabled: false);

      final state = container.read(notificationSettingsControllerProvider);
      expect(state.severeAlertsEnabled, isFalse);

      final saved =
          await fakeStorage.getString(AppConstants.severeAlertsNotificationKey);
      expect(saved, equals('false'));
    });

    test('toggles dailyBriefingEnabled and updates storage', () async {
      final controller =
          container.read(notificationSettingsControllerProvider.notifier);

      await controller.setDailyBriefingEnabled(enabled: false);

      final state = container.read(notificationSettingsControllerProvider);
      expect(state.dailyBriefingEnabled, isFalse);

      final saved =
          await fakeStorage.getString(AppConstants.dailyBriefingNotificationKey);
      expect(saved, equals('false'));
    });

    test('requests permission when toggling to true and respects denial', () async {
      fakeNotifications.permissionGranted = false;
      final controller =
          container.read(notificationSettingsControllerProvider.notifier);

      // Disable first
      await controller.setSevereAlertsEnabled(enabled: false);
      expect(
        container.read(notificationSettingsControllerProvider).severeAlertsEnabled,
        isFalse,
      );

      // Try enabling when permission is denied
      await controller.setSevereAlertsEnabled(enabled: true);
      expect(
        container.read(notificationSettingsControllerProvider).severeAlertsEnabled,
        isFalse,
      );
    });
  });
}

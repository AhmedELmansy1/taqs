import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/notifications/notification_service.dart';
import 'package:taqs/core/notifications/notification_settings_controller.dart';
import 'package:taqs/core/notifications/weather_background_worker.dart';
import 'package:taqs/core/storage/key_value_storage.dart';
import 'package:taqs/core/storage/storage_providers.dart';
import 'package:taqs/features/alerts/domain/entities/weather_alert.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

class _FakeKeyValueStorage implements KeyValueStorage {
  final Map<String, String> _data = {};

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }
}

class _FakeNotificationService implements NotificationService {
  bool permissionGranted = true;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> showSevereAlertNotification(
    WeatherAlert alert, {
    bool isArabic = true,
  }) async {}

  @override
  Future<void> showDailyBriefingNotification(
    CurrentWeather current, {
    bool isArabic = true,
  }) async {}

  @override
  Future<bool> canScheduleExactAlarms() async => true;

  @override
  Future<bool> requestExactAlarmsPermission() async => true;

  @override
  Future<void> scheduleZonedNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    required String channelName,
    String? channelDescription,
    String? payload,
    bool exact = true,
    String? bigPicturePath,
    bool useCustomSound = false,
    String? customSoundName,
  }) async {}

  @override
  Future<void> showTestPrayerNotification({required bool isArabic}) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}
}

class _FakeWeatherBackgroundWorker implements WeatherBackgroundWorker {
  bool isInitialized = false;
  int scheduleCallCount = 0;
  int cancelCallCount = 0;

  @override
  Future<void> initialize() async {
    isInitialized = true;
  }

  @override
  Future<void> schedule12HourBriefing() async {
    scheduleCallCount++;
  }

  @override
  Future<void> cancel12HourBriefing() async {
    cancelCallCount++;
  }
}

void main() {
  group('WeatherBackgroundWorker & NotificationSettingsController', () {
    late _FakeKeyValueStorage fakeStorage;
    late _FakeNotificationService fakeNotificationService;
    late _FakeWeatherBackgroundWorker fakeWorker;

    setUp(() {
      fakeStorage = _FakeKeyValueStorage();
      fakeNotificationService = _FakeNotificationService();
      fakeWorker = _FakeWeatherBackgroundWorker();
    });

    test('schedules 12-hour periodic task when daily briefing enabled', () async {
      final container = ProviderContainer(
        overrides: [
          keyValueStorageProvider.overrideWithValue(fakeStorage),
          notificationServiceProvider.overrideWithValue(fakeNotificationService),
          weatherBackgroundWorkerProvider.overrideWithValue(fakeWorker),
        ],
      );

      final controller =
          container.read(notificationSettingsControllerProvider.notifier);

      await controller.setDailyBriefingEnabled(enabled: true);

      expect(fakeWorker.scheduleCallCount, 1);
      expect(fakeWorker.cancelCallCount, 0);
      expect(
        await fakeStorage.getString(AppConstants.dailyBriefingNotificationKey),
        'true',
      );

      container.dispose();
    });

    test('cancels 12-hour periodic task when daily briefing disabled', () async {
      final container = ProviderContainer(
        overrides: [
          keyValueStorageProvider.overrideWithValue(fakeStorage),
          notificationServiceProvider.overrideWithValue(fakeNotificationService),
          weatherBackgroundWorkerProvider.overrideWithValue(fakeWorker),
        ],
      );

      final controller =
          container.read(notificationSettingsControllerProvider.notifier);

      await controller.setDailyBriefingEnabled(enabled: false);

      expect(fakeWorker.cancelCallCount, 1);
      expect(fakeWorker.scheduleCallCount, 0);
      expect(
        await fakeStorage.getString(AppConstants.dailyBriefingNotificationKey),
        'false',
      );

      container.dispose();
    });
  });
}

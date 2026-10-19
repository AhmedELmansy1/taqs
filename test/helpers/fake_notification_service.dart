import 'package:taqs/core/notifications/notification_service.dart';
import 'package:taqs/features/alerts/domain/entities/weather_alert.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

class ScheduledNotificationEntry {
  const ScheduledNotificationEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.channelId,
    required this.exact,
    this.payload,
    this.bigPicturePath,
    this.useCustomSound = false,
    this.customSoundName,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final String channelId;
  final bool exact;
  final String? payload;
  final String? bigPicturePath;
  final bool useCustomSound;
  final String? customSoundName;
}

/// In-memory test fake for [NotificationService].
class FakeNotificationService implements NotificationService {
  bool permissionGranted = true;
  bool exactAlarmsGranted = true;
  final List<WeatherAlert> severeAlertsShown = [];
  final List<CurrentWeather> briefingsShown = [];
  final List<ScheduledNotificationEntry> scheduledNotifications = [];
  final List<int> cancelledIds = [];
  int testPrayerNotificationsShown = 0;
  bool initialized = false;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    return permissionGranted;
  }

  @override
  Future<bool> canScheduleExactAlarms() async {
    return exactAlarmsGranted;
  }

  @override
  Future<bool> requestExactAlarmsPermission() async {
    return exactAlarmsGranted;
  }

  @override
  Future<void> showSevereAlertNotification(
    WeatherAlert alert, {
    bool isArabic = true,
  }) async {
    severeAlertsShown.add(alert);
  }

  @override
  Future<void> showDailyBriefingNotification(
    CurrentWeather current, {
    bool isArabic = true,
  }) async {
    briefingsShown.add(current);
  }

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
  }) async {
    scheduledNotifications.removeWhere((e) => e.id == id);
    scheduledNotifications.add(
      ScheduledNotificationEntry(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        channelId: channelId,
        exact: exact,
        payload: payload,
        bigPicturePath: bigPicturePath,
        useCustomSound: useCustomSound,
        customSoundName: customSoundName,
      ),
    );
  }

  @override
  Future<void> showTestPrayerNotification({required bool isArabic}) async {
    testPrayerNotificationsShown++;
  }

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
    scheduledNotifications.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> cancelAll() async {
    severeAlertsShown.clear();
    briefingsShown.clear();
    scheduledNotifications.clear();
  }
}

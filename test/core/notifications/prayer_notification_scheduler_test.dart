import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/notifications/prayer_notification_scheduler.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';
import 'package:taqs/features/prayer/presentation/providers/prayer_settings_controller.dart';

import '../../helpers/fake_notification_service.dart';

void main() {
  late FakeNotificationService fakeNotifications;
  late PrayerNotificationScheduler scheduler;

  setUp(() {
    fakeNotifications = FakeNotificationService();
    scheduler =
        PrayerNotificationScheduler(notificationService: fakeNotifications);
  });

  test(
      'Schedules rolling 7-day pre-prayer reminders with exact alarm when granted',
      () async {
    fakeNotifications.exactAlarmsGranted = true;

    // Fixed start date: Friday 2026-10-23 at 04:00 AM (Cairo)
    final fixedNow = DateTime(2026, 10, 23, 4);

    const settings = PrayerSettingsState();

    final count = await scheduler.scheduleRollingWeek(
      latitude: 30.0444,
      longitude: 31.2357,
      cityNameAr: 'القاهرة',
      cityNameEn: 'Cairo',
      settings: settings,
      isArabic: true,
      startDate: fixedNow,
    );

    expect(count, greaterThan(0));
    expect(fakeNotifications.scheduledNotifications, isNotEmpty);

    // Verify all scheduled notifications use exact schedule mode
    final first = fakeNotifications.scheduledNotifications.first;
    expect(first.exact, isTrue);
    expect(first.channelId, PrayerNotificationScheduler.prayerChannelId);
    expect(first.payload, '/prayer');

    // Verify Friday Jumu'ah labeling for Dhuhr
    final fridayDhuhr = fakeNotifications.scheduledNotifications.firstWhere(
      (n) => n.title.contains('الجمعة'),
    );
    expect(fridayDhuhr.title, contains('أذان الجمعة'));
  });

  test('Gracefully falls back to inexact scheduling when exact alarm is denied',
      () async {
    fakeNotifications.exactAlarmsGranted = false;

    final fixedNow = DateTime(2026, 10, 23, 4);
    const settings = PrayerSettingsState();

    final count = await scheduler.scheduleRollingWeek(
      latitude: 30.0444,
      longitude: 31.2357,
      cityNameAr: 'القاهرة',
      cityNameEn: 'Cairo',
      settings: settings,
      isArabic: false,
      startDate: fixedNow,
    );

    expect(count, greaterThan(0));
    expect(fakeNotifications.scheduledNotifications.first.exact, isFalse);
    expect(
      fakeNotifications.scheduledNotifications.first.title,
      contains('minutes'),
    );
  });

  test('Cancels all prayer notifications when master toggle is false', () async {
    const settings = PrayerSettingsState(
      masterNotificationsEnabled: false,
    );

    final count = await scheduler.scheduleRollingWeek(
      latitude: 30.0444,
      longitude: 31.2357,
      cityNameAr: 'القاهرة',
      cityNameEn: 'Cairo',
      settings: settings,
      isArabic: true,
    );

    expect(count, 0);
    expect(fakeNotifications.cancelledIds.length, greaterThan(30));
  });

  test('Omits individual prayers when disabled in per-prayer toggles', () async {
    final fixedNow = DateTime(2026, 10, 23, 4);

    // Disable Fajr, only keep Dhuhr and Asr
    const settings = PrayerSettingsState(
      enabledPrayers: {
        PrayerType.dhuhr,
        PrayerType.asr,
      },
    );

    await scheduler.scheduleRollingWeek(
      latitude: 30.0444,
      longitude: 31.2357,
      cityNameAr: 'القاهرة',
      cityNameEn: 'Cairo',
      settings: settings,
      isArabic: true,
      startDate: fixedNow,
    );

    for (final notif in fakeNotifications.scheduledNotifications) {
      expect(notif.title.contains('الفجر'), isFalse);
      expect(notif.title.contains('المغرب'), isFalse);
    }
  });
}

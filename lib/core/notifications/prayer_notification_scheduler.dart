import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/notifications/notification_service.dart';
import 'package:taqs/features/location/presentation/providers/location_controller.dart';
import 'package:taqs/features/prayer/domain/services/eid_detector.dart';
import 'package:taqs/features/prayer/domain/services/prayer_times_calculator.dart';
import 'package:taqs/features/prayer/domain/services/takbeerat_card_image_service.dart';
import 'package:taqs/features/prayer/presentation/providers/prayer_settings_controller.dart';

/// Service responsible for scheduling pre-prayer notifications over a 7-day rolling window,
/// supporting rich takbeerat cards, versioned channels, and custom sound configuration.
class PrayerNotificationScheduler {
  PrayerNotificationScheduler({
    required this.notificationService,
  });

  final NotificationService notificationService;

  static const String defaultPrayerChannelId = 'taqs_prayer_reminders_default_v2';
  static const String takbeeratPrayerChannelId = 'taqs_prayer_reminders_takbeerat_v1';
  static const String prayerChannelId = defaultPrayerChannelId;
  static const String prayerChannelName = 'تنبيهات مواقيت الصلاة';
  static const int basePrayerNotificationId = 20000;
  static const int rollingWindowDays = 7;

  /// Calculates and schedules all upcoming prayer notifications for the next 7 days.
  Future<int> scheduleRollingWeek({
    required double latitude,
    required double longitude,
    required String cityNameAr,
    required String cityNameEn,
    required PrayerSettingsState settings,
    required bool isArabic,
    DateTime? startDate,
  }) async {
    final now = startDate ?? DateTime.now();

    // If prayer reminders are disabled globally, cancel all scheduled prayer notifications.
    if (!settings.masterNotificationsEnabled) {
      await cancelAllPrayerNotifications();
      return 0;
    }

    final canExact = await notificationService.canScheduleExactAlarms();
    var scheduledCount = 0;

    // Channel selection based on sound configuration (Android channels are immutable once created)
    final targetChannelId = settings.takbeeratSoundEnabled
        ? takbeeratPrayerChannelId
        : defaultPrayerChannelId;

    for (var day = 0; day < rollingWindowDays; day++) {
      final targetDate = now.add(Duration(days: day));

      final bundle = PrayerTimesCalculator.calculate(
        latitude: latitude,
        longitude: longitude,
        date: targetDate,
        cityNameAr: cityNameAr,
        cityNameEn: cityNameEn,
        method: settings.calculationMethod,
        madhab: settings.madhab,
        adjustments: settings.adjustments,
      );

      for (var pIdx = 0; pIdx < bundle.prayers.length; pIdx++) {
        final prayer = bundle.prayers[pIdx];
        final notifId = basePrayerNotificationId + (day * 10) + pIdx;

        // Check if individual prayer is enabled
        final isEnabled = settings.enabledPrayers.contains(prayer.type);
        if (!isEnabled) {
          await notificationService.cancel(notifId);
          continue;
        }

        // Calculate reminder time (prayer time - lead time)
        final reminderTime =
            prayer.time.subtract(Duration(minutes: settings.leadTimeMinutes));

        // Only schedule future reminders
        if (reminderTime.isAfter(now)) {
          final isFriday = targetDate.weekday == DateTime.friday;
          final prayerNameAr = prayer.type.nameAr(isFriday: isFriday);
          final prayerNameEn = prayer.type.nameEn(isFriday: isFriday);

          final title = isArabic
              ? (settings.leadTimeMinutes == 0
                  ? 'حان الآن: أذان $prayerNameAr'
                  : 'بعد ${settings.leadTimeMinutes} دقائق: أذان $prayerNameAr')
              : (settings.leadTimeMinutes == 0
                  ? '$prayerNameEn Adhan now'
                  : '$prayerNameEn in ${settings.leadTimeMinutes} minutes');

          final body = isArabic
              ? 'مواقيت الصلاة في $cityNameAr'
              : 'Prayer times in $cityNameEn';

          // Detect active Eid period for the reminder time
          final eidPeriod = settings.eidModeEnabled
              ? EidDetector.detectEidPeriod(
                  date: reminderTime,
                  manualAdjustmentDays: settings.hijriDayAdjustment,
                )
              : EidPeriod.none;

          // Render rich takbeerat card image if enabled
          String? cardImagePath;
          if (settings.richNotificationCard) {
            try {
              cardImagePath = await TakbeeratCardImageService.generateCardImage(
                prayerType: prayer.type,
                isArabic: isArabic,
                leadTimeMinutes: settings.leadTimeMinutes,
                eidPeriod: eidPeriod,
              );
            } on Object catch (_) {
              cardImagePath = null;
            }
          }

          await notificationService.scheduleZonedNotification(
            id: notifId,
            title: title,
            body: body,
            scheduledDate: reminderTime,
            channelId: targetChannelId,
            channelName: prayerChannelName,
            channelDescription: isArabic
                ? 'تنبيهات مواقيت الصلاة قبل الأذان'
                : 'Prayer reminders before adhan',
            payload: '/prayer',
            exact: canExact,
            bigPicturePath: cardImagePath,
            useCustomSound: settings.takbeeratSoundEnabled,
            customSoundName: 'takbeerat',
          );
          scheduledCount++;
        } else {
          // Already passed, ensure no old notification lingers
          await notificationService.cancel(notifId);
        }
      }
    }

    debugPrint(
      'PrayerNotificationScheduler: scheduled $scheduledCount reminders on $targetChannelId (exact: $canExact)',
    );
    return scheduledCount;
  }

  /// Cancels all scheduled prayer notifications across the 7-day range.
  Future<void> cancelAllPrayerNotifications() async {
    for (var day = 0; day < rollingWindowDays; day++) {
      for (var pIdx = 0; pIdx < 6; pIdx++) {
        final notId = basePrayerNotificationId + (day * 10) + pIdx;
        await notificationService.cancel(notId);
      }
    }
  }
}

/// Provider for [PrayerNotificationScheduler].
final prayerNotificationSchedulerProvider =
    Provider<PrayerNotificationScheduler>((ref) {
  final notifService = ref.watch(notificationServiceProvider);
  return PrayerNotificationScheduler(notificationService: notifService);
});

/// High-level function to trigger reschedule from app open or background worker.
Future<void> triggerPrayerNotificationReschedule(
  WidgetRef ref, {
  required bool isArabic,
}) async {
  final loc = ref.read(locationControllerProvider).selectedLocation;
  final settings = ref.read(prayerSettingsControllerProvider);
  final scheduler = ref.read(prayerNotificationSchedulerProvider);

  await scheduler.scheduleRollingWeek(
    latitude: loc.latitude,
    longitude: loc.longitude,
    cityNameAr: loc.nameAr,
    cityNameEn: loc.nameEn,
    settings: settings,
    isArabic: isArabic,
  );
}

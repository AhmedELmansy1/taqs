import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/features/alerts/domain/entities/weather_alert.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Abstract contract for device local notifications.
abstract interface class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<bool> canScheduleExactAlarms();
  Future<bool> requestExactAlarmsPermission();
  Future<void> showSevereAlertNotification(
    WeatherAlert alert, {
    bool isArabic = true,
  });
  Future<void> showDailyBriefingNotification(
    CurrentWeather current, {
    bool isArabic = true,
  });
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
  });
  Future<void> showTestPrayerNotification({required bool isArabic});
  Future<void> cancel(int id);
  Future<void> cancelAll();
}

/// Production implementation of [NotificationService] using `flutter_local_notifications`.
class LocalNotificationServiceImpl implements NotificationService {
  LocalNotificationServiceImpl({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// Global callback invoked when the user taps on any notification with a payload.
  static void Function(String payload)? onNotificationTapped;

  static const String _alertChannelId = 'taqs_weather_alerts';
  static const String _alertChannelName = 'تحذيرات الطقس الحرج';
  static const String _briefingChannelId = 'taqs_daily_briefing';
  static const String _briefingChannelName = 'الملخص اليومي للطقس';
  static const String _prayerChannelId = 'taqs_prayer_reminders_default_v2';
  static const String _prayerChannelName = 'تنبيهات مواقيت الصلاة';

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const darwinSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          onNotificationTapped?.call(payload);
        }
      },
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final granted =
          await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosImplementation = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  @override
  Future<bool> canScheduleExactAlarms() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final canExact = await android.canScheduleExactNotifications();
      return canExact ?? false;
    }
    return true;
  }

  @override
  Future<bool> requestExactAlarmsPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestExactAlarmsPermission();
      return granted ?? false;
    }
    return true;
  }

  @override
  Future<void> showSevereAlertNotification(
    WeatherAlert alert, {
    bool isArabic = true,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      _alertChannelId,
      _alertChannelName,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
    );
    const darwinDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final title = isArabic ? alert.titleAr : alert.titleEn;
    final body = isArabic ? alert.descriptionAr : alert.descriptionEn;

    await _plugin.show(
      id: alert.id.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  @override
  Future<void> showDailyBriefingNotification(
    CurrentWeather current, {
    bool isArabic = true,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      _briefingChannelId,
      _briefingChannelName,
      icon: '@drawable/ic_notification',
    );
    const darwinDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final city = isArabic ? current.cityNameAr : current.cityNameEn;
    final title = isArabic
        ? 'طقس اليوم في $city: ${current.temperature}°'
        : "Today's weather in $city: ${current.temperature}°";
    final body = isArabic
        ? 'الشعور الفعلي ${current.feelsLike}° • سرعة الرياح ${current.windSpeedKmh} كم/س'
        : 'Feels like ${current.feelsLike}° • Wind ${current.windSpeedKmh} km/h';

    await _plugin.show(
      id: 1001,
      title: title,
      body: body,
      notificationDetails: details,
    );
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
    await initialize();

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final scheduleMode = exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final StyleInformation styleInformation;
    if (bigPicturePath != null && File(bigPicturePath).existsSync()) {
      styleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        contentTitle: title,
        summaryText: body,
      );
    } else {
      styleInformation = BigTextStyleInformation(
        body,
        contentTitle: title,
      );
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      styleInformation: styleInformation,
      sound: useCustomSound && customSoundName != null
          ? RawResourceAndroidNotificationSound(customSoundName)
          : null,
    );
    const darwinDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledDate,
      notificationDetails: details,
      androidScheduleMode: scheduleMode,
      payload: payload,
    );
  }

  @override
  Future<void> showTestPrayerNotification({required bool isArabic}) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      _prayerChannelId,
      _prayerChannelName,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
    );
    const darwinDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final title = isArabic
        ? 'تذكير تجريبي بمواقيت الصلاة'
        : 'Prayer Time Reminder Test';
    final body = isArabic
        ? 'تم التحقق من نظام الإشعارات وجدول التنبيهات بنجاح.'
        : 'Notification system and reminder schedule verified successfully.';

    await _plugin.show(
      id: 9999,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

/// Global provider for [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationServiceImpl();
});

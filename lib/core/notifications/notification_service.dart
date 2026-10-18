import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/features/alerts/domain/entities/weather_alert.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// Abstract contract for device local notifications.
abstract interface class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> showSevereAlertNotification(
    WeatherAlert alert, {
    bool isArabic = true,
  });
  Future<void> showDailyBriefingNotification(
    CurrentWeather current, {
    bool isArabic = true,
  });
  Future<void> cancelAll();
}

/// Production implementation of [NotificationService] using `flutter_local_notifications`.
class LocalNotificationServiceImpl implements NotificationService {
  LocalNotificationServiceImpl({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const String _alertChannelId = 'taqs_weather_alerts';
  static const String _alertChannelName = 'تحذيرات الطقس الحرج';
  static const String _briefingChannelId = 'taqs_daily_briefing';
  static const String _briefingChannelName = 'الملخص اليومي للطقس';

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(settings: settings);
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
      icon: '@mipmap/ic_launcher',
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
      icon: '@mipmap/ic_launcher',
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
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

/// Provider for [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationServiceImpl();
});

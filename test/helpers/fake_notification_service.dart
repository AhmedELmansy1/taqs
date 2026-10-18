import 'package:taqs/core/notifications/notification_service.dart';
import 'package:taqs/features/alerts/domain/entities/weather_alert.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// In-memory test fake for [NotificationService].
class FakeNotificationService implements NotificationService {
  bool permissionGranted = true;
  final List<WeatherAlert> severeAlertsShown = [];
  final List<CurrentWeather> briefingsShown = [];
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
  Future<void> cancelAll() async {
    severeAlertsShown.clear();
    briefingsShown.clear();
  }
}

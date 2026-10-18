import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/network/http_client.dart';
import 'package:taqs/core/notifications/notification_service.dart';
import 'package:taqs/core/notifications/prayer_notification_scheduler.dart';
import 'package:taqs/core/notifications/weather_notification_builder.dart';
import 'package:taqs/core/widgets/home_widget_manager.dart';
import 'package:taqs/features/location/domain/entities/location_item.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';
import 'package:taqs/features/prayer/domain/services/prayer_times_calculator.dart';
import 'package:taqs/features/prayer/presentation/providers/prayer_settings_controller.dart';
import 'package:taqs/features/weather/data/data_sources/open_meteo_remote_data_source.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:workmanager/workmanager.dart';

/// Top-level callback dispatcher required by WorkManager for background isolate execution.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != WeatherBackgroundWorker.briefingTaskName &&
        taskName != Workmanager.iOSBackgroundTask) {
      return true;
    }

    try {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();

      // Check if user enabled 12-hour daily briefings
      final dailyBriefingEnabled =
          prefs.getString(AppConstants.dailyBriefingNotificationKey) != 'false';
      if (!dailyBriefingEnabled) {
        return true;
      }

      // Read saved location or default to Cairo
      final savedLocRaw = prefs.getString('selected_location');
      var latitude = AppConstants.defaultLatitude;
      var longitude = AppConstants.defaultLongitude;
      var cityNameAr = AppConstants.defaultCityNameAr;
      var cityNameEn = AppConstants.defaultCityNameEn;

      if (savedLocRaw != null) {
        try {
          final loc = LocationItem.fromJson(
            jsonDecode(savedLocRaw) as Map<String, dynamic>,
          );
          latitude = loc.latitude;
          longitude = loc.longitude;
          cityNameAr = loc.nameAr;
          cityNameEn = loc.nameEn;
        } on Object catch (_) {}
      }

      // Read language preference
      final lang = prefs.getString(AppConstants.localePreferenceKey) ?? 'ar';
      final isArabic = lang != 'en';

      WeatherBundle? bundle;

      // 1. Attempt fresh remote fetch
      try {
        final httpClient = AppHttpClientImpl(client: http.Client());
        final dataSource =
            OpenMeteoRemoteDataSourceImpl(httpClient: httpClient);
        final dto = await dataSource.getForecast(
          latitude: latitude,
          longitude: longitude,
        );
        bundle = dto.toDomain(
          cityNameAr: cityNameAr,
          cityNameEn: cityNameEn,
        );
      } on Object catch (_) {
        // 2. Fall back to local cached bundle if network is offline
        final cacheKey =
            'weather_cache_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
        final cachedRaw = prefs.getString(cacheKey);
        if (cachedRaw != null) {
          try {
            final map = jsonDecode(cachedRaw) as Map<String, dynamic>;
            final rawBundle = map['bundle'] as Map<String, dynamic>;
            bundle = WeatherBundle.fromJson(rawBundle);
          } on Object catch (_) {}
        }
      }

      if (bundle == null) {
        return true;
      }

      // Build real weather notification message
      final msg = WeatherNotificationBuilder.buildBriefing(
        current: bundle.current,
        todayDaily: bundle.daily.isNotEmpty ? bundle.daily.first : null,
        isArabic: isArabic,
      );

      // Show via FlutterLocalNotificationsPlugin
      final plugin = FlutterLocalNotificationsPlugin();
      const androidDetails = AndroidNotificationDetails(
        'taqs_daily_briefing',
        'الملخص الدوري للطقس',
        channelDescription: 'تحديثات الطقس الحقيقية كل 12 ساعة',
        icon: '@mipmap/ic_launcher',
      );
      const darwinDetails = DarwinNotificationDetails();

      await plugin.show(
        id: 1001,
        title: msg.title,
        body: msg.body,
        notificationDetails: const NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
        ),
      );

      // Reschedule rolling 7-day prayer reminders as a background safety net
      try {
        final notifService = LocalNotificationServiceImpl(plugin: plugin);
        final prayerScheduler =
            PrayerNotificationScheduler(notificationService: notifService);
        final masterRaw =
            prefs.getString(AppConstants.prayerNotificationMasterKey);
        final leadRaw = prefs.getString(AppConstants.prayerLeadTimeKey);
        final methodRaw =
            prefs.getString(AppConstants.prayerCalculationMethodKey);
        final madhabRaw = prefs.getString(AppConstants.prayerMadhabKey);

        final masterEnabled = masterRaw != 'false';
        final leadMin = int.tryParse(leadRaw ?? '') ?? 5;
        final method = CalculationMethodOption.values.firstWhere(
          (m) => m.name == methodRaw,
          orElse: () => CalculationMethodOption.egyptian,
        );
        final madhab = MadhabOption.values.firstWhere(
          (m) => m.name == madhabRaw,
          orElse: () => MadhabOption.shafi,
        );

        await prayerScheduler.scheduleRollingWeek(
          latitude: latitude,
          longitude: longitude,
          cityNameAr: cityNameAr,
          cityNameEn: cityNameEn,
          settings: PrayerSettingsState(
            calculationMethod: method,
            madhab: madhab,
            masterNotificationsEnabled: masterEnabled,
            leadTimeMinutes: leadMin,
          ),
          isArabic: isArabic,
        );
      } on Object catch (_) {}

      // Update Android Home-Screen widgets from background worker
      try {
        final prayerBundle = PrayerTimesCalculator.calculate(
          latitude: latitude,
          longitude: longitude,
          date: DateTime.now(),
          cityNameAr: cityNameAr,
          cityNameEn: cityNameEn,
        );
        await HomeWidgetManager.updateWidgets(
          weather: bundle,
          prayerTimes: prayerBundle,
          isArabic: isArabic,
        );
      } on Object catch (_) {}

      return true;
    } on Object catch (_) {
      // Never crash background isolate
      return false;
    }
  });
}

/// Manages registration and scheduling of the 12-hour weather background job.
abstract interface class WeatherBackgroundWorker {
  static const String briefingTaskName = 'taqs_12h_weather_briefing';
  static const String briefingUniqueName = 'taqs_periodic_weather_job';

  Future<void> initialize();
  Future<void> schedule12HourBriefing();
  Future<void> cancel12HourBriefing();
}

/// Production implementation of [WeatherBackgroundWorker] using WorkManager.
class WorkmanagerWeatherBackgroundWorker implements WeatherBackgroundWorker {
  WorkmanagerWeatherBackgroundWorker({Workmanager? workmanager})
      : _workmanager = workmanager ?? Workmanager();

  final Workmanager _workmanager;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _workmanager.initialize(
        callbackDispatcher,
      );
      _initialized = true;
    } on Object catch (_) {}
  }

  @override
  Future<void> schedule12HourBriefing() async {
    await initialize();
    try {
      await _workmanager.registerPeriodicTask(
        WeatherBackgroundWorker.briefingUniqueName,
        WeatherBackgroundWorker.briefingTaskName,
        frequency: const Duration(hours: 12),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );
    } on Object catch (_) {}
  }

  @override
  Future<void> cancel12HourBriefing() async {
    try {
      await _workmanager.cancelByUniqueName(
        WeatherBackgroundWorker.briefingUniqueName,
      );
    } on Object catch (_) {}
  }
}

/// Provider for [WeatherBackgroundWorker].
final weatherBackgroundWorkerProvider =
    Provider<WeatherBackgroundWorker>((ref) {
  return WorkmanagerWeatherBackgroundWorker();
});

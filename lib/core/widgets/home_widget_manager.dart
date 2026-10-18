import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// Pure data model representing the payload synced to the Android home screen widget.
@immutable
class TaqsWidgetData {
  const TaqsWidgetData({
    required this.temperature,
    required this.cityName,
    required this.condition,
    required this.nextPrayer,
    required this.updatedTime,
  });

  final String temperature;
  final String cityName;
  final String condition;
  final String nextPrayer;
  final String updatedTime;
}

/// Service managing Android Home-Screen widgets synchronization.
class HomeWidgetManager {
  const HomeWidgetManager._();

  static const String keyTemperature = 'taqs_widget_temperature';
  static const String keyCityName = 'taqs_widget_city_name';
  static const String keyCondition = 'taqs_widget_condition';
  static const String keyNextPrayer = 'taqs_widget_next_prayer';
  static const String keyUpdatedTime = 'taqs_widget_updated_time';

  /// Maps domain weather and prayer models into widget fields.
  static TaqsWidgetData mapToWidgetData({
    required WeatherBundle weather,
    required PrayerTimesBundle prayerTimes,
    required bool isArabic,
  }) {
    final current = weather.current;
    final tempStr = '${current.temperature}°';
    final cityStr = isArabic ? current.cityNameAr : current.cityNameEn;
    final condStr = isArabic ? current.condition.name : current.condition.name;
    final next = prayerTimes.nextPrayer;
    final prayerTimeStr = DateFormat('h:mm a', isArabic ? 'ar' : 'en').format(next.time);
    final nextPrayerStr = isArabic
        ? '${next.nameAr()}: $prayerTimeStr'
        : '${next.nameEn()}: $prayerTimeStr';

    final nowTimeStr = DateFormat('h:mm a', isArabic ? 'ar' : 'en').format(DateTime.now());
    final statusStr = weather.isFromCache
        ? (isArabic ? 'قديم: $nowTimeStr' : 'Cached: $nowTimeStr')
        : (isArabic ? 'مُحدَّث: $nowTimeStr' : 'Updated: $nowTimeStr');

    return TaqsWidgetData(
      temperature: tempStr,
      cityName: cityStr,
      condition: condStr,
      nextPrayer: nextPrayerStr,
      updatedTime: statusStr,
    );
  }

  /// Updates all Android home screen widget instances with latest data.
  static Future<void> updateWidgets({
    required WeatherBundle weather,
    required PrayerTimesBundle prayerTimes,
    required bool isArabic,
  }) async {
    // Only execute on Android platform where widgets are supported in this phase
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final data = mapToWidgetData(
        weather: weather,
        prayerTimes: prayerTimes,
        isArabic: isArabic,
      );

      await HomeWidget.saveWidgetData<String>(keyTemperature, data.temperature);
      await HomeWidget.saveWidgetData<String>(keyCityName, data.cityName);
      await HomeWidget.saveWidgetData<String>(keyCondition, data.condition);
      await HomeWidget.saveWidgetData<String>(keyNextPrayer, data.nextPrayer);
      await HomeWidget.saveWidgetData<String>(keyUpdatedTime, data.updatedTime);

      // Trigger native widget refresh
      await HomeWidget.updateWidget(
        name: 'TaqsWidgetProvider',
        androidName: 'TaqsWidgetProvider',
      );
      await HomeWidget.updateWidget(
        name: 'TaqsWidget2x2Provider',
        androidName: 'TaqsWidget2x2Provider',
      );
    } on Object catch (e) {
      debugPrint('HomeWidgetManager error: $e');
    }
  }
}

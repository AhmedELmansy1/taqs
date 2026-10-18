import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// Formats localized, real weather summary messages for periodic 12-hour notifications.
abstract final class WeatherNotificationBuilder {
  /// Builds a localized 12-hour briefing message containing real current metrics.
  static ({String title, String body}) buildBriefing({
    required CurrentWeather current,
    DailyForecast? todayDaily,
    bool isArabic = true,
  }) {
    final city = isArabic ? current.cityNameAr : current.cityNameEn;
    final conditionText = _getConditionText(current.condition, isArabic: isArabic);

    final title = isArabic
        ? '$city: ${current.temperature}°، $conditionText'
        : '$city: ${current.temperature}°, $conditionText';

    final bodyBuffer = StringBuffer();

    if (todayDaily != null) {
      if (isArabic) {
        bodyBuffer.write('العظمى ${todayDaily.maxTemp}° والصغرى ${todayDaily.minTemp}°');
      } else {
        bodyBuffer.write('High ${todayDaily.maxTemp}° • Low ${todayDaily.minTemp}°');
      }
    } else {
      if (isArabic) {
        bodyBuffer.write('يبدو كـ ${current.feelsLike}°');
      } else {
        bodyBuffer.write('Feels like ${current.feelsLike}°');
      }
    }

    // Add quick localized dressing or atmospheric tip
    final tip = _getShortTip(current, isArabic: isArabic);
    if (tip.isNotEmpty) {
      bodyBuffer.write(isArabic ? ' — $tip' : ' — $tip');
    }

    return (title: title, body: bodyBuffer.toString());
  }

  static String _getConditionText(
    WeatherCondition condition, {
    required bool isArabic,
  }) {
    switch (condition) {
      case WeatherCondition.sunny:
        return isArabic ? 'مشمس وصافٍ' : 'Clear & Sunny';
      case WeatherCondition.partlyCloudy:
        return isArabic ? 'غائم جزئياً' : 'Partly Cloudy';
      case WeatherCondition.cloudy:
        return isArabic ? 'غائم' : 'Cloudy';
      case WeatherCondition.rainy:
        return isArabic ? 'أمطار متفرقة' : 'Showers / Rain';
      case WeatherCondition.fog:
        return isArabic ? 'شبورة مائية وضباب' : 'Fog & Mist';
      case WeatherCondition.dustStorm:
        return isArabic ? 'رياح خماسين وأتربة' : 'Dust / Sandstorm';
    }
  }

  static String _getShortTip(
    CurrentWeather current, {
    required bool isArabic,
  }) {
    if (current.condition == WeatherCondition.rainy) {
      return isArabic ? 'لا تنسَ المظلة' : 'Grab an umbrella';
    }
    if (current.condition == WeatherCondition.dustStorm) {
      return isArabic ? 'ارتدِ كمامة وتجنب الرياح' : 'Wear a mask against dust';
    }
    if (current.temperature >= 35) {
      return isArabic ? 'أجواء حارة، احرص على شرب الماء' : 'Hot day, stay hydrated';
    }
    if (current.temperature <= 14) {
      return isArabic ? 'طقس بارد، ارتدِ ملابس ثقيلة' : 'Chilly, wear warm layers';
    }
    if (current.uvIndex >= 7) {
      return isArabic ? 'أشعة شمس قوية، استخدم واقياً' : 'High UV, sun protection advised';
    }
    return isArabic ? 'أجواء معتدلة ومناسبة للخروج' : 'Mild weather, great for outdoors';
  }
}

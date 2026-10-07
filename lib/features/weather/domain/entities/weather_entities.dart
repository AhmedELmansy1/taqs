import 'package:flutter/foundation.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';

/// Immutable domain entity representing current real-time weather status.
@immutable
class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.cityNameAr,
    required this.cityNameEn,
    required this.condition,
    required this.humidityPercentage,
    required this.windSpeedKmh,
    required this.uvIndex,
  });

  final int temperature;
  final int feelsLike;
  final String cityNameAr;
  final String cityNameEn;
  final WeatherCondition condition;
  final int humidityPercentage;
  final int windSpeedKmh;
  final int uvIndex;
}

/// Hourly forecast slot entity.
@immutable
class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
  });

  final String time;
  final int temperature;
  final WeatherCondition condition;
}

/// 7-Day daily forecast entity.
@immutable
class DailyForecast {
  const DailyForecast({
    required this.dayNameAr,
    required this.dayNameEn,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
  });

  final String dayNameAr;
  final String dayNameEn;
  final int minTemp;
  final int maxTemp;
  final WeatherCondition condition;
}

/// Aggregated bundle entity representing full weather view for a location.
@immutable
class WeatherBundle {
  const WeatherBundle({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
}

import 'package:flutter/foundation.dart';
import 'package:taqs/features/air_quality/domain/entities/air_quality.dart';
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

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => CurrentWeather(
        temperature: json['temperature'] as int,
        feelsLike: json['feelsLike'] as int,
        cityNameAr: json['cityNameAr'] as String,
        cityNameEn: json['cityNameEn'] as String,
        condition: WeatherCondition.values.byName(json['condition'] as String),
        humidityPercentage: json['humidityPercentage'] as int,
        windSpeedKmh: json['windSpeedKmh'] as int,
        uvIndex: json['uvIndex'] as int,
      );

  final int temperature;
  final int feelsLike;
  final String cityNameAr;
  final String cityNameEn;
  final WeatherCondition condition;
  final int humidityPercentage;
  final int windSpeedKmh;
  final int uvIndex;

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'feelsLike': feelsLike,
        'cityNameAr': cityNameAr,
        'cityNameEn': cityNameEn,
        'condition': condition.name,
        'humidityPercentage': humidityPercentage,
        'windSpeedKmh': windSpeedKmh,
        'uvIndex': uvIndex,
      };
}

/// Hourly forecast slot entity.
@immutable
class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) => HourlyForecast(
        time: json['time'] as String,
        temperature: json['temperature'] as int,
        condition: WeatherCondition.values.byName(json['condition'] as String),
      );

  final String time;
  final int temperature;
  final WeatherCondition condition;

  Map<String, dynamic> toJson() => {
        'time': time,
        'temperature': temperature,
        'condition': condition.name,
      };
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

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
        dayNameAr: json['dayNameAr'] as String,
        dayNameEn: json['dayNameEn'] as String,
        minTemp: json['minTemp'] as int,
        maxTemp: json['maxTemp'] as int,
        condition: WeatherCondition.values.byName(json['condition'] as String),
      );

  final String dayNameAr;
  final String dayNameEn;
  final int minTemp;
  final int maxTemp;
  final WeatherCondition condition;

  Map<String, dynamic> toJson() => {
        'dayNameAr': dayNameAr,
        'dayNameEn': dayNameEn,
        'minTemp': minTemp,
        'maxTemp': maxTemp,
        'condition': condition.name,
      };
}

/// Aggregated bundle entity representing full weather view for a location.
@immutable
class WeatherBundle {
  const WeatherBundle({
    required this.current,
    required this.hourly,
    required this.daily,
    this.airQuality,
    this.fetchedAt,
    this.isFromCache = false,
  });

  factory WeatherBundle.fromJson(Map<String, dynamic> json) => WeatherBundle(
        current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
        hourly: (json['hourly'] as List<dynamic>)
            .map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
            .toList(),
        daily: (json['daily'] as List<dynamic>)
            .map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
            .toList(),
        airQuality: json['airQuality'] != null
            ? AirQuality.fromJson(json['airQuality'] as Map<String, dynamic>)
            : null,
        fetchedAt: json['fetchedAt'] != null
            ? DateTime.parse(json['fetchedAt'] as String)
            : null,
        isFromCache: (json['isFromCache'] as bool?) ?? false,
      );

  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final AirQuality? airQuality;
  final DateTime? fetchedAt;
  final bool isFromCache;

  WeatherBundle copyWith({
    CurrentWeather? current,
    List<HourlyForecast>? hourly,
    List<DailyForecast>? daily,
    AirQuality? airQuality,
    DateTime? fetchedAt,
    bool? isFromCache,
  }) {
    return WeatherBundle(
      current: current ?? this.current,
      hourly: hourly ?? this.hourly,
      daily: daily ?? this.daily,
      airQuality: airQuality ?? this.airQuality,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  Map<String, dynamic> toJson() => {
        'current': current.toJson(),
        'hourly': hourly.map((e) => e.toJson()).toList(),
        'daily': daily.map((e) => e.toJson()).toList(),
        if (airQuality != null) 'airQuality': airQuality!.toJson(),
        if (fetchedAt != null) 'fetchedAt': fetchedAt!.toIso8601String(),
        'isFromCache': isFromCache,
      };
}

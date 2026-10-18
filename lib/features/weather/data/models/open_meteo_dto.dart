import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// Maps WMO weather interpretation code to [WeatherCondition].
WeatherCondition mapWmoCodeToCondition(int code) {
  switch (code) {
    case 0:
      return WeatherCondition.sunny;
    case 1:
    case 2:
      return WeatherCondition.partlyCloudy;
    case 3:
      return WeatherCondition.cloudy;
    case 45:
    case 48:
      return WeatherCondition.fog;
    case 6:
    case 7:
    case 8:
    case 9:
    case 30:
    case 31:
    case 32:
    case 33:
    case 34:
    case 35:
      return WeatherCondition.dustStorm;
    case 51:
    case 53:
    case 55:
    case 56:
    case 57:
    case 61:
    case 63:
    case 65:
    case 66:
    case 67:
    case 71:
    case 73:
    case 75:
    case 77:
    case 80:
    case 81:
    case 82:
    case 85:
    case 86:
    case 95:
    case 96:
    case 99:
      return WeatherCondition.rainy;
    default:
      return WeatherCondition.sunny;
  }
}

/// Data Transfer Object for Open-Meteo Forecast API response.
class OpenMeteoForecastDto {
  const OpenMeteoForecastDto({
    required this.latitude,
    required this.longitude,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory OpenMeteoForecastDto.fromJson(Map<String, dynamic> json) {
    return OpenMeteoForecastDto(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      current: OpenMeteoCurrentDto.fromJson(
        json['current'] as Map<String, dynamic>,
      ),
      hourly: OpenMeteoHourlyDto.fromJson(
        json['hourly'] as Map<String, dynamic>,
      ),
      daily: OpenMeteoDailyDto.fromJson(
        json['daily'] as Map<String, dynamic>,
      ),
    );
  }

  final double latitude;
  final double longitude;
  final OpenMeteoCurrentDto current;
  final OpenMeteoHourlyDto hourly;
  final OpenMeteoDailyDto daily;

  /// Maps DTO to domain [WeatherBundle].
  WeatherBundle toDomain({
    String? cityNameAr,
    String? cityNameEn,
    DateTime? fetchedAt,
    bool isFromCache = false,
  }) {
    final now = DateTime.now();

    // Map current
    final uv = daily.uvIndexMax.isNotEmpty
        ? daily.uvIndexMax.first.round()
        : 6;

    final sunriseStr = daily.sunrise.isNotEmpty
        ? (DateTime.tryParse(daily.sunrise.first) != null
            ? '${DateTime.parse(daily.sunrise.first).hour.toString().padLeft(2, '0')}:${DateTime.parse(daily.sunrise.first).minute.toString().padLeft(2, '0')}'
            : '05:54')
        : '05:54';

    final sunsetStr = daily.sunset.isNotEmpty
        ? (DateTime.tryParse(daily.sunset.first) != null
            ? '${DateTime.parse(daily.sunset.first).hour.toString().padLeft(2, '0')}:${DateTime.parse(daily.sunset.first).minute.toString().padLeft(2, '0')}'
            : '18:22')
        : '18:22';

    final precip = daily.precipitationProbabilityMax.isNotEmpty
        ? daily.precipitationProbabilityMax.first.round()
        : (current.precipitation > 0 ? 80 : 0);

    final currentDomain = CurrentWeather(
      temperature: current.temperature2m.round(),
      feelsLike: current.apparentTemperature.round(),
      cityNameAr: cityNameAr ?? AppConstants.defaultCityNameAr,
      cityNameEn: cityNameEn ?? AppConstants.defaultCityNameEn,
      condition: mapWmoCodeToCondition(current.weatherCode),
      humidityPercentage: current.relativeHumidity2m.round(),
      windSpeedKmh: current.windSpeed10m.round(),
      uvIndex: uv,
      pressureHpa: current.surfacePressure?.round() ?? 1013,
      windDirectionDegrees: current.windDirection10m?.round() ?? 0,
      precipitationProbability: precip,
      sunriseTime: sunriseStr,
      sunsetTime: sunsetStr,
      isDay: current.isDay == 1,
    );

    // Map hourly (filter next 24 slots)
    final hourlyDomain = <HourlyForecast>[];
    final count = hourly.time.length;

    var startIndex = 0;
    for (var i = 0; i < count; i++) {
      final slotTime = DateTime.tryParse(hourly.time[i]);
      if (slotTime != null &&
          slotTime.isAfter(now.subtract(const Duration(hours: 1)))) {
        startIndex = i;
        break;
      }
    }

    final endIndex = (startIndex + 24).clamp(0, count);
    for (var i = startIndex; i < endIndex; i++) {
      final slotTime = DateTime.tryParse(hourly.time[i]);
      final formattedTime = slotTime != null
          ? '${slotTime.hour.toString().padLeft(2, '0')}:00'
          : hourly.time[i].split('T').last.substring(0, 5);

      hourlyDomain.add(
        HourlyForecast(
          time: formattedTime,
          temperature: hourly.temperature2m[i].round(),
          condition: mapWmoCodeToCondition(hourly.weatherCode[i]),
        ),
      );
    }

    // Map daily (7 days)
    final dailyDomain = <DailyForecast>[];
    final dailyCount = daily.time.length.clamp(0, 7);

    for (var i = 0; i < dailyCount; i++) {
      final dayDate =
          DateTime.tryParse(daily.time[i]) ?? now.add(Duration(days: i));
      final isToday = dayDate.year == now.year &&
          dayDate.month == now.month &&
          dayDate.day == now.day;
      final tomorrow = now.add(const Duration(days: 1));
      final isTomorrow = dayDate.year == tomorrow.year &&
          dayDate.month == tomorrow.month &&
          dayDate.day == tomorrow.day;

      final dayNames =
          _getLocalizedDayNames(dayDate.weekday, isToday, isTomorrow);

      dailyDomain.add(
        DailyForecast(
          dayNameAr: dayNames.ar,
          dayNameEn: dayNames.en,
          minTemp: daily.temperature2mMin[i].round(),
          maxTemp: daily.temperature2mMax[i].round(),
          condition: mapWmoCodeToCondition(daily.weatherCode[i]),
        ),
      );
    }

    return WeatherBundle(
      current: currentDomain,
      hourly: hourlyDomain,
      daily: dailyDomain,
      fetchedAt: fetchedAt ?? now,
      isFromCache: isFromCache,
    );
  }

  static ({String ar, String en}) _getLocalizedDayNames(
    int weekday,
    bool isToday,
    bool isTomorrow,
  ) {
    if (isToday) return (ar: 'اليوم', en: 'Today');
    if (isTomorrow) return (ar: 'غداً', en: 'Tomorrow');

    switch (weekday) {
      case DateTime.monday:
        return (ar: 'الإثنين', en: 'Mon');
      case DateTime.tuesday:
        return (ar: 'الثلاثاء', en: 'Tue');
      case DateTime.wednesday:
        return (ar: 'الأربعاء', en: 'Wed');
      case DateTime.thursday:
        return (ar: 'الخميس', en: 'Thu');
      case DateTime.friday:
        return (ar: 'الجمعة', en: 'Fri');
      case DateTime.saturday:
        return (ar: 'السبت', en: 'Sat');
      case DateTime.sunday:
      default:
        return (ar: 'الأحد', en: 'Sun');
    }
  }
}

class OpenMeteoCurrentDto {
  const OpenMeteoCurrentDto({
    required this.time,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.isDay,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
    this.surfacePressure,
    this.windDirection10m,
  });

  factory OpenMeteoCurrentDto.fromJson(Map<String, dynamic> json) {
    return OpenMeteoCurrentDto(
      time: json['time'] as String,
      temperature2m: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity2m: (json['relative_humidity_2m'] as num).toDouble(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      isDay: (json['is_day'] as num).toInt(),
      precipitation: ((json['precipitation'] ?? 0) as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed10m: (json['wind_speed_10m'] as num).toDouble(),
      surfacePressure: (json['surface_pressure'] as num?)?.toDouble(),
      windDirection10m: (json['wind_direction_10m'] as num?)?.toDouble(),
    );
  }

  final String time;
  final double temperature2m;
  final double relativeHumidity2m;
  final double apparentTemperature;
  final int isDay;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;
  final double? surfacePressure;
  final double? windDirection10m;
}

class OpenMeteoHourlyDto {
  const OpenMeteoHourlyDto({
    required this.time,
    required this.temperature2m,
    required this.weatherCode,
  });

  factory OpenMeteoHourlyDto.fromJson(Map<String, dynamic> json) {
    return OpenMeteoHourlyDto(
      time: (json['time'] as List<dynamic>).cast<String>(),
      temperature2m: (json['temperature_2m'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      weatherCode: (json['weather_code'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );
  }

  final List<String> time;
  final List<double> temperature2m;
  final List<int> weatherCode;
}

class OpenMeteoDailyDto {
  const OpenMeteoDailyDto({
    required this.time,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.uvIndexMax,
    this.sunrise = const [],
    this.sunset = const [],
    this.precipitationProbabilityMax = const [],
  });

  factory OpenMeteoDailyDto.fromJson(Map<String, dynamic> json) {
    return OpenMeteoDailyDto(
      time: (json['time'] as List<dynamic>).cast<String>(),
      weatherCode: (json['weather_code'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      temperature2mMax: (json['temperature_2m_max'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      temperature2mMin: (json['temperature_2m_min'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      uvIndexMax: (json['uv_index_max'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      sunrise: (json['sunrise'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sunset: (json['sunset'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      precipitationProbabilityMax:
          (json['precipitation_probability_max'] as List<dynamic>?)
                  ?.map((e) => (e as num).toDouble())
                  .toList() ??
              const [],
    );
  }

  final List<String> time;
  final List<int> weatherCode;
  final List<double> temperature2mMax;
  final List<double> temperature2mMin;
  final List<double> uvIndexMax;
  final List<String> sunrise;
  final List<String> sunset;
  final List<double> precipitationProbabilityMax;
}

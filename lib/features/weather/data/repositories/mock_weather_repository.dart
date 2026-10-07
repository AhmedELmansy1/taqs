import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/domain/repositories/weather_repository.dart';

/// Static mock repository supplying realistic Egypt weather data for Phase 1.
final class MockWeatherRepository implements WeatherRepository {
  const MockWeatherRepository();

  @override
  Future<WeatherBundle> getWeatherForLocation({
    required double latitude,
    required double longitude,
  }) async {
    // Simulate brief network latency for realistic state observation
    await Future<void>.delayed(const Duration(milliseconds: 150));

    return const WeatherBundle(
      current: CurrentWeather(
        temperature: 29,
        feelsLike: 31,
        cityNameAr: AppConstants.defaultCityNameAr,
        cityNameEn: AppConstants.defaultCityNameEn,
        condition: WeatherCondition.sunny,
        humidityPercentage: 42,
        windSpeedKmh: 16,
        uvIndex: 7,
      ),
      hourly: [
        HourlyForecast(
          time: '12:00',
          temperature: 28,
          condition: WeatherCondition.sunny,
        ),
        HourlyForecast(
          time: '13:00',
          temperature: 29,
          condition: WeatherCondition.sunny,
        ),
        HourlyForecast(
          time: '14:00',
          temperature: 30,
          condition: WeatherCondition.sunny,
        ),
        HourlyForecast(
          time: '15:00',
          temperature: 30,
          condition: WeatherCondition.partlyCloudy,
        ),
        HourlyForecast(
          time: '16:00',
          temperature: 29,
          condition: WeatherCondition.partlyCloudy,
        ),
        HourlyForecast(
          time: '17:00',
          temperature: 27,
          condition: WeatherCondition.partlyCloudy,
        ),
        HourlyForecast(
          time: '18:00',
          temperature: 25,
          condition: WeatherCondition.sunny,
        ),
        HourlyForecast(
          time: '19:00',
          temperature: 23,
          condition: WeatherCondition.sunny,
        ),
        HourlyForecast(
          time: '20:00',
          temperature: 22,
          condition: WeatherCondition.sunny,
        ),
      ],
      daily: [
        DailyForecast(
          dayNameAr: 'اليوم',
          dayNameEn: 'Today',
          minTemp: 21,
          maxTemp: 30,
          condition: WeatherCondition.sunny,
        ),
        DailyForecast(
          dayNameAr: 'غداً',
          dayNameEn: 'Tomorrow',
          minTemp: 20,
          maxTemp: 29,
          condition: WeatherCondition.partlyCloudy,
        ),
        DailyForecast(
          dayNameAr: 'الجمعة',
          dayNameEn: 'Fri',
          minTemp: 22,
          maxTemp: 31,
          condition: WeatherCondition.sunny,
        ),
        DailyForecast(
          dayNameAr: 'السبت',
          dayNameEn: 'Sat',
          minTemp: 23,
          maxTemp: 32,
          condition: WeatherCondition.sunny,
        ),
        DailyForecast(
          dayNameAr: 'الأحد',
          dayNameEn: 'Sun',
          minTemp: 21,
          maxTemp: 28,
          condition: WeatherCondition.dustStorm,
        ),
        DailyForecast(
          dayNameAr: 'الإثنين',
          dayNameEn: 'Mon',
          minTemp: 19,
          maxTemp: 26,
          condition: WeatherCondition.partlyCloudy,
        ),
        DailyForecast(
          dayNameAr: 'الثلاثاء',
          dayNameEn: 'Tue',
          minTemp: 18,
          maxTemp: 25,
          condition: WeatherCondition.rainy,
        ),
      ],
    );
  }
}

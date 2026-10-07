import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/features/weather/data/repositories/mock_weather_repository.dart';

void main() {
  group('MockWeatherRepository', () {
    late MockWeatherRepository repository;

    setUp(() {
      repository = const MockWeatherRepository();
    });

    test('getWeatherForLocation returns realistic data for Egypt', () async {
      final bundle = await repository.getWeatherForLocation(
        latitude: AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude,
      );

      expect(bundle.current.temperature, isPositive);
      expect(bundle.current.cityNameAr, equals(AppConstants.defaultCityNameAr));
      expect(bundle.current.cityNameEn, equals(AppConstants.defaultCityNameEn));
      expect(bundle.hourly, isNotEmpty);
      expect(bundle.daily, hasLength(7));
    });
  });
}

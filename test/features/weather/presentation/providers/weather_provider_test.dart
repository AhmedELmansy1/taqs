import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/storage/storage_providers.dart';
import 'package:taqs/features/weather/data/providers/weather_data_providers.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/domain/repositories/weather_repository.dart';
import 'package:taqs/features/weather/presentation/providers/weather_provider.dart';
import '../../../../helpers/fake_key_value_storage.dart';

class _FakeWeatherRepository implements WeatherRepository {
  int fetchCount = 0;

  @override
  Future<WeatherBundle> getWeatherForLocation({
    required double latitude,
    required double longitude,
    String? cityNameAr,
    String? cityNameEn,
    bool forceRefresh = false,
  }) async {
    fetchCount++;
    return const WeatherBundle(
      current: CurrentWeather(
        temperature: 30,
        feelsLike: 32,
        cityNameAr: AppConstants.defaultCityNameAr,
        cityNameEn: AppConstants.defaultCityNameEn,
        condition: WeatherCondition.sunny,
        humidityPercentage: 40,
        windSpeedKmh: 15,
        uvIndex: 6,
      ),
      hourly: [],
      daily: [],
    );
  }
}

void main() {
  group('WeatherViewModel', () {
    late _FakeWeatherRepository fakeRepository;
    late FakeKeyValueStorage fakeStorage;

    setUp(() {
      fakeRepository = _FakeWeatherRepository();
      fakeStorage = FakeKeyValueStorage();
    });

    test('build loads weather bundle successfully', () async {
      final container = ProviderContainer(
        overrides: [
          keyValueStorageProvider.overrideWithValue(fakeStorage),
          weatherRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(weatherViewModelProvider.future);

      expect(result.current.temperature, equals(30));
      expect(result.current.cityNameAr, equals(AppConstants.defaultCityNameAr));
      expect(fakeRepository.fetchCount, equals(1));
    });

    test('refresh invokes repository and updates state', () async {
      final container = ProviderContainer(
        overrides: [
          keyValueStorageProvider.overrideWithValue(fakeStorage),
          weatherRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(weatherViewModelProvider.future);
      expect(fakeRepository.fetchCount, equals(1));

      await container.read(weatherViewModelProvider.notifier).refresh();
      expect(fakeRepository.fetchCount, equals(2));
      expect(container.read(weatherViewModelProvider).hasValue, isTrue);
    });
  });
}

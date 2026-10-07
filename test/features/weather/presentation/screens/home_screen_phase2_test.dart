import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/design/components/error_state.dart';
import 'package:taqs/core/errors/app_failure.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/domain/repositories/weather_repository.dart';
import 'package:taqs/features/weather/presentation/screens/home_screen.dart';
import 'package:taqs/features/weather/presentation/widgets/offline_data_banner.dart';
import '../../../../helpers/pump_app.dart';

class _FakePhase2WeatherRepository implements WeatherRepository {
  _FakePhase2WeatherRepository({
    this.shouldThrow = false,
    this.isFromCache = false,
  });

  final bool shouldThrow;
  final bool isFromCache;

  @override
  Future<WeatherBundle> getWeatherForLocation({
    required double latitude,
    required double longitude,
    String? cityNameAr,
    String? cityNameEn,
    bool forceRefresh = false,
  }) async {
    if (shouldThrow) {
      throw const NoConnectionFailure();
    }

    return WeatherBundle(
      current: CurrentWeather(
        temperature: 27,
        feelsLike: 29,
        cityNameAr: cityNameAr ?? AppConstants.defaultCityNameAr,
        cityNameEn: cityNameEn ?? AppConstants.defaultCityNameEn,
        condition: WeatherCondition.sunny,
        humidityPercentage: 50,
        windSpeedKmh: 10,
        uvIndex: 5,
      ),
      hourly: const [],
      daily: const [],
      isFromCache: isFromCache,
      fetchedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );
  }
}

void main() {
  group('HomeScreen Phase 2', () {
    testWidgets('renders OfflineDataBanner when weather data is from cache',
        (tester) async {
      final fakeRepo = _FakePhase2WeatherRepository(isFromCache: true);

      await tester.pumpApp(
        const HomeScreen(),
        weatherRepository: fakeRepo,
      );
      await tester.pumpAndSettle();

      expect(find.byType(OfflineDataBanner), findsOneWidget);
      expect(find.text('27'), findsOneWidget);
    });

    testWidgets('renders ErrorState with retry button when repository throws error',
        (tester) async {
      final fakeRepo = _FakePhase2WeatherRepository(shouldThrow: true);

      await tester.pumpApp(
        const HomeScreen(),
        weatherRepository: fakeRepo,
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/weather/presentation/screens/home_screen.dart';
import 'package:taqs/features/weather/presentation/widgets/current_weather_card.dart';
import 'package:taqs/features/weather/presentation/widgets/daily_forecast_list.dart';
import 'package:taqs/features/weather/presentation/widgets/hourly_temperature_chart.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders skeleton layout with current, hourly, and weekly sections',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpApp(
        const HomeScreen(),
      );
      await tester.pumpAndSettle();

      // Check key layout components
      expect(find.byType(CurrentWeatherCard), findsOneWidget);
      expect(find.byType(HourlyTemperatureChart), findsOneWidget);
      expect(find.byType(DailyForecastList), findsOneWidget);

      // Check temperature and location
      expect(find.text('القاهرة'), findsOneWidget);
      expect(find.text('29'), findsOneWidget);
    });
  });
}

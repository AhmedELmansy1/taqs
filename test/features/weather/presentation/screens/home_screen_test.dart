import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/weather/presentation/screens/home_screen.dart';
import 'package:taqs/features/weather/presentation/widgets/current_weather_card.dart';
import 'package:taqs/features/weather/presentation/widgets/daily_forecast_list.dart';
import 'package:taqs/features/weather/presentation/widgets/hourly_forecast_strip.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders skeleton layout with current, hourly, and weekly sections',
        (tester) async {
      await tester.pumpApp(
        const HomeScreen(),
      );
      await tester.pumpAndSettle();

      // Check key layout components
      expect(find.byType(CurrentWeatherCard), findsOneWidget);
      expect(find.byType(HourlyForecastStrip), findsOneWidget);
      expect(find.byType(DailyForecastList), findsOneWidget);

      // Check temperature and location
      expect(find.text('القاهرة، مصر'), findsOneWidget);
      expect(find.text('29'), findsOneWidget);
    });
  });
}

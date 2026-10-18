import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/air_quality/domain/entities/air_quality.dart';
import 'package:taqs/features/air_quality/presentation/widgets/air_quality_card.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  group('AirQualityCard', () {
    const airQuality = AirQuality(
      europeanAqi: 28,
      pm10: 24.5,
      pm2_5: 12,
      dust: 8.3,
    );

    testWidgets('renders European AQI, PM metrics, and health advice in Arabic',
        (tester) async {
      await tester.pumpApp(
        const AirQualityCard(
          airQuality: airQuality,
          isArabic: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('28'), findsOneWidget);
      expect(find.text('EAQI'), findsOneWidget);
      expect(find.text('مقبولة'), findsOneWidget);
      expect(find.text('24.5 µg'), findsOneWidget);
      expect(find.text('12.0 µg'), findsOneWidget);
      expect(find.text('8.3 µg'), findsOneWidget);
      expect(find.text('PM2.5'), findsOneWidget);
      expect(find.text('PM10'), findsOneWidget);
      expect(find.text('الغبار'), findsOneWidget);
    });

    testWidgets('renders in English when isArabic is false', (tester) async {
      await tester.pumpApp(
        const AirQualityCard(
          airQuality: airQuality,
          isArabic: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('28'), findsOneWidget);
      expect(find.text('Fair'), findsOneWidget);
      expect(find.text('Dust'), findsOneWidget);
    });
  });
}

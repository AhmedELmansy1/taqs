import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/alerts/domain/entities/weather_alert.dart';
import 'package:taqs/features/alerts/presentation/widgets/severe_weather_alert_card.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  group('SevereWeatherAlertCard', () {
    const alert = WeatherAlert(
      id: 'khamsin_test',
      type: AlertType.khamsinDust,
      severity: AlertSeverity.severe,
      titleAr: 'تحذير: رياح الخماسين والعواصف الرملية',
      titleEn: 'Severe Warning: Khamsin Dust Storm',
      descriptionAr: 'رياح نشطة محملة بالرمال والأتربة.',
      descriptionEn: 'Strong winds carrying desert dust.',
      safetyTipsAr: [
        'ارتداء الكمامة الطبية الواقية',
        'تجنب السير في الطرق الصحراوية المفتوحة',
      ],
      safetyTipsEn: [
        'Wear a protective face mask',
        'Avoid driving on open desert highways',
      ],
    );

    testWidgets('renders alert title, description, and expands safety guidance in Arabic',
        (tester) async {
      await tester.pumpApp(
        const SevereWeatherAlertCard(
          alert: alert,
          isArabic: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تحذير: رياح الخماسين والعواصف الرملية'), findsOneWidget);
      expect(find.text('رياح نشطة محملة بالرمال والأتربة.'), findsOneWidget);

      // Initially tips are collapsed
      expect(find.text('ارتداء الكمامة الطبية الواقية'), findsNothing);

      // Tap expand icon button
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Tips are now expanded
      expect(find.text('ارتداء الكمامة الطبية الواقية'), findsOneWidget);
      expect(find.text('تجنب السير في الطرق الصحراوية المفتوحة'), findsOneWidget);
    });

    testWidgets('renders in English when isArabic is false', (tester) async {
      await tester.pumpApp(
        const SevereWeatherAlertCard(
          alert: alert,
          isArabic: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Severe Warning: Khamsin Dust Storm'), findsOneWidget);
      expect(find.text('Strong winds carrying desert dust.'), findsOneWidget);
    });
  });
}

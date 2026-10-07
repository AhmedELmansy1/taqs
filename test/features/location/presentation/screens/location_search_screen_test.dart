import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/location/presentation/screens/location_search_screen.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  group('LocationSearchScreen', () {
    testWidgets('renders search field, current location card, and governorates',
        (tester) async {
      await tester.pumpApp(
        const LocationSearchScreen(),
      );
      await tester.pumpAndSettle();

      // Check search field
      expect(find.byType(TextField), findsOneWidget);

      // Check current location button
      expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);

      // Check Egyptian governorates quick-pick chips
      expect(find.text('القاهرة'), findsWidgets);
      expect(find.text('الإسكندرية'), findsWidgets);
      expect(find.text('الجيزة'), findsWidgets);
      expect(find.text('الشرقية'), findsOneWidget);
    });
  });
}

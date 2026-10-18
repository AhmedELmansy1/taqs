import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/localization/locale_controller.dart';
import 'package:taqs/features/about/presentation/screens/about_developer_screen.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  group('AboutDeveloperScreen', () {
    testWidgets('renders developer details correctly in Arabic', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpApp(
        const AboutDeveloperScreen(),
      );
      await tester.pumpAndSettle();

      // Check Developer Name
      expect(find.text('أحمد المنسي'), findsOneWidget);

      // Check Education & Graduation Project
      expect(find.textContaining('جامعة بنها'), findsOneWidget);
      expect(find.textContaining('كشف التزييف'), findsAtLeastNWidgets(1));

      // Check Skills
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('FastAPI'), findsOneWidget);
      expect(find.text('Cybersecurity'), findsOneWidget);

      // Check Projects
      expect(find.text('Shoot Live'), findsOneWidget);
      expect(find.text('Forests Team'), findsOneWidget);
      expect(find.text('Mansy Store'), findsOneWidget);

      // Check Contact Info
      expect(find.text('ahmedelmansy1311@gmail.com'), findsOneWidget);

      // Check Tech Focus, Why Taqs, and Action Buttons
      expect(find.text('التركيز التقني والهندسي'), findsOneWidget);
      expect(find.text('لماذا طقس؟'), findsOneWidget);
      expect(find.text('مشاركة تطبيق طقس'), findsOneWidget);
      expect(find.text('تراخيص البرمجيات مفتوحة المصدر'), findsOneWidget);
    });

    testWidgets('renders developer details correctly in English', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpApp(
        const AboutDeveloperScreen(),
        locale: AppLocales.english,
      );
      await tester.pumpAndSettle();

      expect(find.text('Ahmed Elmansy'), findsOneWidget);
      expect(find.textContaining('Benha University'), findsOneWidget);
      expect(find.textContaining('Graduation Project: Forgery Detection'), findsOneWidget);
      expect(find.text('Technical Focus Areas'), findsOneWidget);
      expect(find.text('Why Taqs?'), findsOneWidget);
      expect(find.text('Share Taqs App'), findsOneWidget);
      expect(find.text('Open Source Licenses'), findsOneWidget);
    });
  });
}

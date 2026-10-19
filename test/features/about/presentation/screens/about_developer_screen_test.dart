import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/localization/locale_controller.dart';
import 'package:taqs/features/about/presentation/screens/about_developer_screen.dart';
import 'package:taqs/features/about/presentation/widgets/currently_building_card.dart';
import 'package:taqs/features/about/presentation/widgets/cv_download_button.dart';
import 'package:taqs/features/about/presentation/widgets/developer_hero_header.dart';
import 'package:taqs/features/about/presentation/widgets/subtle_gradient_divider.dart';
import 'package:taqs/features/about/presentation/widgets/work_together_card.dart';

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

      // Check Hero Header
      expect(find.byType(DeveloperHeroHeader), findsOneWidget);

      // Check Currently Building Card
      expect(find.byType(CurrentlyBuildingCard), findsOneWidget);
      expect(find.text('يعمل حالياً على'), findsOneWidget);
      expect(find.text('تطبيق طقس ومواقيت الصلاة (Taqs)'), findsOneWidget);

      // Check Subtle Gradient Dividers
      expect(find.byType(SubtleGradientDivider), findsAtLeastNWidgets(3));

      // Check Education & Graduation Project
      expect(find.textContaining('جامعة بنها'), findsOneWidget);
      expect(find.textContaining('كشف التزييف'), findsAtLeastNWidgets(1));

      // Check Skills
      expect(find.text('Flutter'), findsAtLeastNWidgets(1));
      expect(find.text('FastAPI'), findsOneWidget);
      expect(find.text('Cybersecurity'), findsOneWidget);

      // Check Projects
      expect(find.text('Shoot Live'), findsOneWidget);
      expect(find.text('Forests Team'), findsOneWidget);
      expect(find.text('Mansy Store'), findsOneWidget);

      // Check Work Together CTA Card
      expect(find.byType(WorkTogetherCard), findsOneWidget);
      expect(find.text('لنعمل معاً'), findsOneWidget);

      // Scroll down to reveal contact and footer
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      // Check Contact Info
      expect(find.text('ahmedelmansy1311@gmail.com'), findsOneWidget);

      // Check Tech Focus, Why Taqs, and Action Buttons
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
      expect(find.text('Currently Building'), findsOneWidget);
      expect(find.text('Taqs — Weather & Prayer Times App'), findsOneWidget);
      expect(find.textContaining('Benha University'), findsOneWidget);
      expect(find.textContaining('Graduation Project: Forgery Detection'), findsOneWidget);
      expect(find.text('Technical Focus Areas'), findsOneWidget);
      expect(find.text("Let's Work Together"), findsOneWidget);

      // Scroll down to reveal footer
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.text('Why Taqs?'), findsOneWidget);
      expect(find.text('Share Taqs App'), findsOneWidget);
      expect(find.text('Open Source Licenses'), findsOneWidget);
    });

    testWidgets('renders in Dark theme without error', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpApp(
        Theme(
          data: ThemeData.dark(useMaterial3: true),
          child: const AboutDeveloperScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('أحمد المنسي'), findsOneWidget);
      expect(find.byType(WorkTogetherCard), findsOneWidget);
      expect(find.byType(CurrentlyBuildingCard), findsOneWidget);
    });

    testWidgets('adapts gracefully to narrow 320dp width without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpApp(
        const AboutDeveloperScreen(),
      );
      await tester.pumpAndSettle();

      expect(find.text('أحمد المنسي'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('adapts gracefully to 1.5x large text scaling without overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: AboutDeveloperScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('أحمد المنسي'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CvDownloadButton handles missing asset fallback gracefully', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: CvDownloadButton(),
        ),
      );
      await tester.pumpAndSettle();

      // Either rendered or safely hidden (SizedBox.shrink) without throwing
      expect(tester.takeException(), isNull);
    });
  });
}

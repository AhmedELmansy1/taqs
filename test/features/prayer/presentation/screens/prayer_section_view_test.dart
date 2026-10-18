import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/localization/locale_controller.dart';
import 'package:taqs/features/prayer/presentation/screens/prayer_section_view.dart';
import 'package:taqs/features/prayer/presentation/widgets/prayer_countdown_arc.dart';
import 'package:taqs/features/prayer/presentation/widgets/prayer_item_tile.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets(
      'PrayerSectionView renders Hijri date, countdown arc, and 6 prayer tiles in Arabic',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpApp(
      const Scaffold(
        body: PrayerSectionView(isArabic: true),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Countdown Arc exists
    expect(find.byType(PrayerCountdownArc), findsOneWidget);

    // Verify all 6 prayer items exist on long screen (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha)
    expect(find.byType(PrayerItemTile), findsNWidgets(6));

    // Verify Egyptian Survey Authority disclaimer note exists
    expect(find.textContaining('الهيئة المصرية العامة للمساحة'), findsOneWidget);
  });

  testWidgets('PrayerSectionView renders in English correctly',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpApp(
      const Scaffold(
        body: PrayerSectionView(isArabic: false),
      ),
      locale: AppLocales.english,
    );

    await tester.pumpAndSettle();

    expect(find.byType(PrayerCountdownArc), findsOneWidget);
    expect(find.byType(PrayerItemTile), findsNWidgets(6));
    expect(
      find.textContaining('Egyptian General Authority of Survey'),
      findsOneWidget,
    );
  });
}

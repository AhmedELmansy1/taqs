import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/localization/locale_controller.dart';
import 'package:taqs/features/prayer/data/takbeerat_texts.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';
import 'package:taqs/features/prayer/domain/services/eid_detector.dart';
import 'package:taqs/features/prayer/presentation/providers/prayer_settings_controller.dart';
import 'package:taqs/features/prayer/presentation/providers/prayer_view_model.dart';
import 'package:taqs/features/prayer/presentation/screens/prayer_section_view.dart';
import 'package:taqs/features/prayer/presentation/widgets/takbeerat_card.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('TakbeeratCard widget tests', () {
    testWidgets('Renders pre-adhan takbeerat in Arabic with calligraphic styling',
        (tester) async {
      final fajr = PrayerItem(
        type: PrayerType.fajr,
        time: DateTime.now().add(const Duration(minutes: 4)),
        isNext: true,
        isPast: false,
      );

      await tester.pumpApp(
        Scaffold(
          body: TakbeeratCard(
            isArabic: true,
            nextPrayer: fajr,
            remainingMinutes: 4,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify authentic pre-adhan takbeer text from TakbeeratTexts
      expect(find.text(TakbeeratTexts.preAdhanTakbeerAr), findsOneWidget);
      expect(find.text(TakbeeratTexts.preAdhanPreparationAr), findsOneWidget);
      expect(find.textContaining('الفجر'), findsOneWidget);
    });

    testWidgets('Renders pre-adhan takbeerat in English', (tester) async {
      final asr = PrayerItem(
        type: PrayerType.asr,
        time: DateTime.now().add(const Duration(minutes: 5)),
        isNext: true,
        isPast: false,
      );

      await tester.pumpApp(
        Scaffold(
          body: TakbeeratCard(
            isArabic: false,
            nextPrayer: asr,
            remainingMinutes: 5,
          ),
        ),
        locale: AppLocales.english,
      );

      await tester.pumpAndSettle();

      expect(find.text(TakbeeratTexts.preAdhanTakbeerEn), findsOneWidget);
      expect(find.text(TakbeeratTexts.preAdhanPreparationEn), findsOneWidget);
      expect(find.textContaining('Asr'), findsOneWidget);
    });

    testWidgets('Renders Eid takbeerat and Eid greeting in Eid mode',
        (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: TakbeeratCard(
            isArabic: true,
            eidPeriod: EidPeriod.eidAlFitr,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(TakbeeratTexts.eidTakbeerConciseAr), findsOneWidget);
      expect(find.text(TakbeeratTexts.eidGreetingAr), findsOneWidget);
      expect(find.text('عيد الفطر المبارك'), findsOneWidget);
    });

    testWidgets(
        'PrayerSectionView shows TakbeeratCard when timeToNext <= leadTime',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      // Set next prayer 3 minutes from now (within 5-min default lead time)
      final dhuhrItem = PrayerItem(
        type: PrayerType.dhuhr,
        time: now.add(const Duration(minutes: 3)),
        isNext: true,
        isPast: false,
      );

      final testBundle = PrayerTimesBundle(
        date: now,
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
        hijriFormattedAr: '15 شوال 1447 هـ',
        hijriFormattedEn: '15 Shawwal 1447 AH',
        gregorianFormattedAr: 'الأحد 25 أكتوبر 2026',
        gregorianFormattedEn: 'Sunday, October 25, 2026',
        prayers: [dhuhrItem],
        nextPrayer: dhuhrItem,
        timeToNextPrayer: const Duration(minutes: 3),
        isFriday: false,
      );

      await tester.pumpApp(
        ProviderScope(
          overrides: [
            prayerViewModelProvider.overrideWith((ref) => testBundle),
            prayerSettingsControllerProvider.overrideWith(
              () => _StubSettingsController(
                const PrayerSettingsState(),
              ),
            ),
          ],
          child: const Scaffold(
            body: PrayerSectionView(isArabic: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // TakbeeratCard should be visible because 3 mins <= 5 mins lead time
      expect(find.byType(TakbeeratCard), findsOneWidget);
    });

    testWidgets(
        'PrayerSectionView hides TakbeeratCard when timeToNext > leadTime',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      // Next prayer 45 minutes from now (> 5 min lead time)
      final dhuhrFar = PrayerItem(
        type: PrayerType.dhuhr,
        time: now.add(const Duration(minutes: 45)),
        isNext: true,
        isPast: false,
      );

      final testBundle = PrayerTimesBundle(
        date: now,
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
        hijriFormattedAr: '15 رجب 1447 هـ',
        hijriFormattedEn: '15 Rajab 1447 AH',
        gregorianFormattedAr: 'الأحد 25 أكتوبر 2026',
        gregorianFormattedEn: 'Sunday, October 25, 2026',
        prayers: [dhuhrFar],
        nextPrayer: dhuhrFar,
        timeToNextPrayer: const Duration(minutes: 45),
        isFriday: false,
      );

      await tester.pumpApp(
        ProviderScope(
          overrides: [
            prayerViewModelProvider.overrideWith((ref) => testBundle),
            prayerSettingsControllerProvider.overrideWith(
              () => _StubSettingsController(
                const PrayerSettingsState(),
              ),
            ),
          ],
          child: const Scaffold(
            body: PrayerSectionView(isArabic: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // TakbeeratCard should NOT be visible
      expect(find.byType(TakbeeratCard), findsNothing);
    });
  });
}

class _StubSettingsController extends PrayerSettingsController {
  _StubSettingsController(this._initial);
  final PrayerSettingsState _initial;

  @override
  PrayerSettingsState build() => _initial;
}

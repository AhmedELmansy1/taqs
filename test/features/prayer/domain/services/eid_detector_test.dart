import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:taqs/features/prayer/domain/services/eid_detector.dart';

void main() {
  group('EidDetector tests', () {
    test('Correctly identifies Eid al-Fitr (1st to 3rd Shawwal)', () {
      // Find a Gregorian date corresponding to 1st of Shawwal
      final h1 = HijriCalendar()
        ..hYear = 1447
        ..hMonth = 10
        ..hDay = 1;
      final gDateDay1 = h1.hijriToGregorian(1447, 10, 1);
      final gDateDay2 = h1.hijriToGregorian(1447, 10, 2);
      final gDateDay3 = h1.hijriToGregorian(1447, 10, 3);
      final gDateDay4 = h1.hijriToGregorian(1447, 10, 4);

      expect(
        EidDetector.detectEidPeriod(date: gDateDay1),
        equals(EidPeriod.eidAlFitr),
      );
      expect(
        EidDetector.detectEidPeriod(date: gDateDay2),
        equals(EidPeriod.eidAlFitr),
      );
      expect(
        EidDetector.detectEidPeriod(date: gDateDay3),
        equals(EidPeriod.eidAlFitr),
      );
      // 4th Shawwal is past Eid al-Fitr
      expect(
        EidDetector.detectEidPeriod(date: gDateDay4),
        equals(EidPeriod.none),
      );
    });

    test(
        'Correctly identifies Eid al-Adha and Tashreeq (9th to 13th Dhu al-Hijjah)',
        () {
      final h = HijriCalendar();
      final gArafah = h.hijriToGregorian(1447, 12, 9);
      final gNahr = h.hijriToGregorian(1447, 12, 10);
      final gTashreeq3 = h.hijriToGregorian(1447, 12, 13);
      final gPast = h.hijriToGregorian(1447, 12, 14);

      expect(
        EidDetector.detectEidPeriod(date: gArafah),
        equals(EidPeriod.eidAlAdha),
      );
      expect(
        EidDetector.detectEidPeriod(date: gNahr),
        equals(EidPeriod.eidAlAdha),
      );
      expect(
        EidDetector.detectEidPeriod(date: gTashreeq3),
        equals(EidPeriod.eidAlAdha),
      );
      expect(
        EidDetector.detectEidPeriod(date: gPast),
        equals(EidPeriod.none),
      );
    });

    test('Identifies non-Eid days as EidPeriod.none', () {
      final h = HijriCalendar();
      // Ramadan 15
      final gRamadan = h.hijriToGregorian(1447, 9, 15);
      expect(
        EidDetector.detectEidPeriod(date: gRamadan),
        equals(EidPeriod.none),
      );
    });

    test('Respects manual ±1 day adjustment', () {
      final h = HijriCalendar();
      // 30th Ramadan (day before Shawwal 1)
      final gLastRamadan = h.hijriToGregorian(1447, 9, 30);

      // Without adjustment -> none
      expect(
        EidDetector.detectEidPeriod(date: gLastRamadan),
        equals(EidPeriod.none),
      );

      // With +1 day adjustment -> acts as 1st of Shawwal (Eid al-Fitr)
      expect(
        EidDetector.detectEidPeriod(date: gLastRamadan, manualAdjustmentDays: 1),
        equals(EidPeriod.eidAlFitr),
      );

      // 4th of Shawwal with -1 day adjustment -> acts as 3rd of Shawwal (Eid al-Fitr)
      final gDay4Shawwal = h.hijriToGregorian(1447, 10, 4);
      expect(
        EidDetector.detectEidPeriod(
            date: gDay4Shawwal, manualAdjustmentDays: -1),
        equals(EidPeriod.eidAlFitr),
      );
    });

    test('Returns localized Eid labels in Arabic and English', () {
      expect(
        EidDetector.getEidLabel(EidPeriod.eidAlFitr, isArabic: true),
        equals('عيد الفطر المبارك'),
      );
      expect(
        EidDetector.getEidLabel(EidPeriod.eidAlFitr, isArabic: false),
        equals('Eid al-Fitr'),
      );
      expect(
        EidDetector.getEidLabel(EidPeriod.eidAlAdha, isArabic: true),
        equals('عيد الأضحى المبارك وأيام التشريق'),
      );
      expect(
        EidDetector.getEidLabel(EidPeriod.eidAlAdha, isArabic: false),
        equals('Eid al-Adha & Tashreeq'),
      );
      expect(
        EidDetector.getEidLabel(EidPeriod.none, isArabic: true),
        isNull,
      );
    });
  });
}

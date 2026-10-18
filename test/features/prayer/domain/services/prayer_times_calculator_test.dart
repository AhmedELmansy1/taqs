import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';
import 'package:taqs/features/prayer/domain/services/prayer_times_calculator.dart';

void main() {
  group('PrayerTimesCalculator', () {
    test('calculates Cairo prayer times for fixed date within expected astronomical tolerance', () {
      // 18 October 2026 - Cairo Coordinates
      final testDate = DateTime(2026, 10, 18, 12);
      final bundle = PrayerTimesCalculator.calculate(
        latitude: 30.0444,
        longitude: 31.2357,
        date: testDate,
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
      );

      expect(bundle.prayers.length, 6);
      expect(bundle.cityNameAr, 'القاهرة');
      expect(bundle.cityNameEn, 'Cairo');

      final fajr = bundle.prayers.firstWhere((p) => p.type == PrayerType.fajr);
      final sunrise = bundle.prayers.firstWhere((p) => p.type == PrayerType.sunrise);
      final dhuhr = bundle.prayers.firstWhere((p) => p.type == PrayerType.dhuhr);
      final asr = bundle.prayers.firstWhere((p) => p.type == PrayerType.asr);
      final maghrib = bundle.prayers.firstWhere((p) => p.type == PrayerType.maghrib);
      final isha = bundle.prayers.firstWhere((p) => p.type == PrayerType.isha);

      // Verify sequence order
      expect(fajr.time.isBefore(sunrise.time), isTrue);
      expect(sunrise.time.isBefore(dhuhr.time), isTrue);
      expect(dhuhr.time.isBefore(asr.time), isTrue);
      expect(asr.time.isBefore(maghrib.time), isTrue);
      expect(maghrib.time.isBefore(isha.time), isTrue);

      // Dhuhr in Cairo is around 11:40 - 11:45 UTC or local ~11:40/12:40 depending on DST
      expect(dhuhr.time.hour, inInclusiveRange(11, 13));
    });

    test('labels Dhuhr as Jumuah on Fridays', () {
      // 23 October 2026 is Friday
      final fridayDate = DateTime(2026, 10, 23, 10);
      final bundle = PrayerTimesCalculator.calculate(
        latitude: 30.0444,
        longitude: 31.2357,
        date: fridayDate,
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
      );

      final dhuhr = bundle.prayers.firstWhere((p) => p.type == PrayerType.dhuhr);
      expect(dhuhr.nameAr(), 'الجمعة');
      expect(dhuhr.nameEn(), "Jumu'ah");
    });

    test('labels Dhuhr normally on non-Fridays', () {
      // 18 October 2026 is Sunday
      final sundayDate = DateTime(2026, 10, 18, 10);
      final bundle = PrayerTimesCalculator.calculate(
        latitude: 30.0444,
        longitude: 31.2357,
        date: sundayDate,
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
      );

      final dhuhr = bundle.prayers.firstWhere((p) => p.type == PrayerType.dhuhr);
      expect(dhuhr.nameAr(), 'الظهر');
      expect(dhuhr.nameEn(), 'Dhuhr');
    });

    test('computes Hijri date string correctly', () {
      final date = DateTime(2026, 10, 18);
      final bundle = PrayerTimesCalculator.calculate(
        latitude: 30.0444,
        longitude: 31.2357,
        date: date,
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
      );

      expect(bundle.hijriFormattedAr, contains('1448'));
      expect(bundle.hijriFormattedEn, contains('1448'));
    });

    test('applies manual adjustments accurately', () {
      final date = DateTime(2026, 10, 18);
      final baseline = PrayerTimesCalculator.calculate(
        latitude: 30.0444,
        longitude: 31.2357,
        date: date,
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
      );

      final adjusted = PrayerTimesCalculator.calculate(
        latitude: 30.0444,
        longitude: 31.2357,
        date: date,
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
        adjustments: const PrayerAdjustments(fajr: 5, maghrib: -3),
      );

      final baseFajr = baseline.prayers.firstWhere((p) => p.type == PrayerType.fajr);
      final adjFajr = adjusted.prayers.firstWhere((p) => p.type == PrayerType.fajr);
      expect(adjFajr.time.difference(baseFajr.time).inMinutes, 5);

      final baseMaghrib = baseline.prayers.firstWhere((p) => p.type == PrayerType.maghrib);
      final adjMaghrib = adjusted.prayers.firstWhere((p) => p.type == PrayerType.maghrib);
      expect(adjMaghrib.time.difference(baseMaghrib.time).inMinutes, -3);
    });

    test('verifies geographical reference gradient across Cairo, Alexandria, and Aswan', () {
      // Reference date: 18 October 2026
      // Source: Egyptian General Authority of Survey (Fajr 19.5°, Isha 17.5°, Shafi'i Asr)
      final date = DateTime(2026, 10, 18, 12);

      final cairo = PrayerTimesCalculator.calculate(
        latitude: 30.0444,
        longitude: 31.2357,
        date: date,
        cityNameAr: 'القاهرة',
        cityNameEn: 'Cairo',
      );

      final alexandria = PrayerTimesCalculator.calculate(
        latitude: 31.2001,
        longitude: 29.9187,
        date: date,
        cityNameAr: 'الإسكندرية',
        cityNameEn: 'Alexandria',
      );

      final aswan = PrayerTimesCalculator.calculate(
        latitude: 24.0889,
        longitude: 32.8998,
        date: date,
        cityNameAr: 'أسوان',
        cityNameEn: 'Aswan',
      );

      final cairoDhuhr = cairo.prayers.firstWhere((p) => p.type == PrayerType.dhuhr).time;
      final alexDhuhr = alexandria.prayers.firstWhere((p) => p.type == PrayerType.dhuhr).time;
      final aswanDhuhr = aswan.prayers.firstWhere((p) => p.type == PrayerType.dhuhr).time;

      // Alexandria is west of Cairo (29.92°E vs 31.24°E = ~1.32° diff ~5.3 minutes later)
      final alexDiffMinutes = alexDhuhr.difference(cairoDhuhr).inMinutes;
      expect(alexDiffMinutes, inInclusiveRange(4, 6));

      // Aswan is east of Cairo (32.90°E vs 31.24°E = ~1.66° diff ~6.6 minutes earlier)
      final aswanDiffMinutes = cairoDhuhr.difference(aswanDhuhr).inMinutes;
      expect(aswanDiffMinutes, inInclusiveRange(5, 8));
    });
  });
}

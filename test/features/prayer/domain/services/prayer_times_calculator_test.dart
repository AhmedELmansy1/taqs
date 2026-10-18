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
  });
}

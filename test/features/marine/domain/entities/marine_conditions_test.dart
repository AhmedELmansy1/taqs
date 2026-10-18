import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/features/marine/domain/entities/marine_conditions.dart';

void main() {
  group('SeaStateRating', () {
    test('evaluates wave height thresholds deterministically', () {
      expect(SeaStateRating.fromWaveHeight(0.5), SeaStateRating.calm);
      expect(SeaStateRating.fromWaveHeight(0.99), SeaStateRating.calm);
      expect(SeaStateRating.fromWaveHeight(1), SeaStateRating.moderate);
      expect(SeaStateRating.fromWaveHeight(1.8), SeaStateRating.moderate);
      expect(SeaStateRating.fromWaveHeight(2), SeaStateRating.rough);
      expect(SeaStateRating.fromWaveHeight(2.9), SeaStateRating.rough);
      expect(SeaStateRating.fromWaveHeight(3), SeaStateRating.dangerous);
      expect(SeaStateRating.fromWaveHeight(4.5), SeaStateRating.dangerous);
    });

    test('returns Arabic and English labels for all ratings', () {
      for (final rating in SeaStateRating.values) {
        expect(rating.labelAr(), isNotEmpty);
        expect(rating.labelEn(), isNotEmpty);
      }
    });
  });

  group('MarineConditions', () {
    test('computes compass directions correctly', () {
      final conditionsNorth = MarineConditions(
        waveHeightMeters: 0.8,
        wavePeriodSeconds: 5,
        waveDirectionDegrees: 10,
        windWaveHeightMeters: 0.2,
        rating: SeaStateRating.calm,
        fetchedAt: DateTime(2026, 10, 18),
      );
      expect(conditionsNorth.directionCompass(isArabic: false), contains('North'));
      expect(conditionsNorth.directionCompass(isArabic: true), contains('شمالي'));

      final conditionsWest = MarineConditions(
        waveHeightMeters: 2.2,
        wavePeriodSeconds: 7,
        waveDirectionDegrees: 270,
        windWaveHeightMeters: 1.1,
        rating: SeaStateRating.rough,
        fetchedAt: DateTime(2026, 10, 18),
      );
      expect(conditionsWest.directionCompass(isArabic: false), contains('West'));
      expect(conditionsWest.directionCompass(isArabic: true), contains('غربي'));
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/features/location/presentation/providers/location_controller.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';
import 'package:taqs/features/prayer/domain/services/prayer_times_calculator.dart';
import 'package:taqs/features/prayer/presentation/providers/prayer_settings_controller.dart';

/// Provider returning the active [PrayerTimesBundle] calculated offline for current coordinates.
final prayerViewModelProvider = Provider<PrayerTimesBundle>((ref) {
  final locationState = ref.watch(locationControllerProvider);
  final settings = ref.watch(prayerSettingsControllerProvider);

  final loc = locationState.selectedLocation;
  final lat = loc.latitude;
  final lon = loc.longitude;
  final nameAr = loc.nameAr.isNotEmpty ? loc.nameAr : AppConstants.defaultCityNameAr;
  final nameEn = loc.nameEn.isNotEmpty ? loc.nameEn : AppConstants.defaultCityNameEn;

  return PrayerTimesCalculator.calculate(
    latitude: lat,
    longitude: lon,
    date: DateTime.now(),
    cityNameAr: nameAr,
    cityNameEn: nameEn,
    method: settings.calculationMethod,
    madhab: settings.madhab,
    adjustments: settings.adjustments,
  );
});

import 'package:flutter/foundation.dart';

/// Supported daily prayers and solar markers.
enum PrayerType {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha;

  /// Returns localized Arabic prayer name with Jumu'ah on Friday.
  String nameAr({bool isFriday = false}) {
    switch (this) {
      case PrayerType.fajr:
        return 'الفجر';
      case PrayerType.sunrise:
        return 'الشروق';
      case PrayerType.dhuhr:
        return isFriday ? 'الجمعة' : 'الظهر';
      case PrayerType.asr:
        return 'العصر';
      case PrayerType.maghrib:
        return 'المغرب';
      case PrayerType.isha:
        return 'العشاء';
    }
  }

  /// Returns localized English prayer name with Jumu'ah on Friday.
  String nameEn({bool isFriday = false}) {
    switch (this) {
      case PrayerType.fajr:
        return 'Fajr';
      case PrayerType.sunrise:
        return 'Sunrise';
      case PrayerType.dhuhr:
        return isFriday ? "Jumu'ah" : 'Dhuhr';
      case PrayerType.asr:
        return 'Asr';
      case PrayerType.maghrib:
        return 'Maghrib';
      case PrayerType.isha:
        return 'Isha';
    }
  }
}

/// Calculation methods supported for astronomical prayer times.
enum CalculationMethodOption {
  egyptian,
  muslimWorldLeague,
  ummAlQura,
  karachi;

  String nameAr() {
    switch (this) {
      case CalculationMethodOption.egyptian:
        return 'الهيئة المصرية العامة للمساحة (الافتراضي)';
      case CalculationMethodOption.muslimWorldLeague:
        return 'رابطة العالم الإسلامي';
      case CalculationMethodOption.ummAlQura:
        return 'أم القرى (مكة المكرمة)';
      case CalculationMethodOption.karachi:
        return 'جامعة العلوم الإسلامية بكراتشي';
    }
  }

  String nameEn() {
    switch (this) {
      case CalculationMethodOption.egyptian:
        return 'Egyptian General Authority of Survey (Default)';
      case CalculationMethodOption.muslimWorldLeague:
        return 'Muslim World League';
      case CalculationMethodOption.ummAlQura:
        return 'Umm al-Qura (Makkah)';
      case CalculationMethodOption.karachi:
        return 'University of Islamic Sciences, Karachi';
    }
  }
}

/// Jurisprudence method for Asr calculation.
enum MadhabOption {
  shafi,
  hanafi;

  String nameAr() {
    switch (this) {
      case MadhabOption.shafi:
        return 'الشافعي / المالكي / الحنبلي (طول الظل مساوٍ)';
      case MadhabOption.hanafi:
        return 'الحنفي (طول الظل ضعف القامة)';
    }
  }

  String nameEn() {
    switch (this) {
      case MadhabOption.shafi:
        return 'Shafi’i / Maliki / Hanbali (Default)';
      case MadhabOption.hanafi:
        return 'Hanafi (Shadow ratio 2:1)';
    }
  }
}

/// Single prayer entry representation.
@immutable
class PrayerItem {
  const PrayerItem({
    required this.type,
    required this.time,
    required this.isNext,
    required this.isPast,
    this.isFriday = false,
  });

  final PrayerType type;
  final DateTime time;
  final bool isNext;
  final bool isPast;
  final bool isFriday;

  String nameAr() => type.nameAr(isFriday: isFriday);
  String nameEn() => type.nameEn(isFriday: isFriday);
}

/// Complete bundle of calculated prayer times for a calendar day.
@immutable
class PrayerTimesBundle {
  const PrayerTimesBundle({
    required this.date,
    required this.cityNameAr,
    required this.cityNameEn,
    required this.hijriFormattedAr,
    required this.hijriFormattedEn,
    required this.gregorianFormattedAr,
    required this.gregorianFormattedEn,
    required this.prayers,
    required this.nextPrayer,
    required this.timeToNextPrayer,
    required this.isFriday,
    this.previousPrayer,
    this.calculationMethod = CalculationMethodOption.egyptian,
    this.madhab = MadhabOption.shafi,
  });

  final DateTime date;
  final String cityNameAr;
  final String cityNameEn;
  final String hijriFormattedAr;
  final String hijriFormattedEn;
  final String gregorianFormattedAr;
  final String gregorianFormattedEn;
  final List<PrayerItem> prayers;
  final PrayerItem nextPrayer;
  final Duration timeToNextPrayer;
  final PrayerItem? previousPrayer;
  final bool isFriday;
  final CalculationMethodOption calculationMethod;
  final MadhabOption madhab;
}

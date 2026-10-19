import 'package:hijri/hijri_calendar.dart';

/// The Islamic Eid occasion currently observed.
enum EidPeriod {
  /// Regular days (not an Eid or Arafah/Tashreeq period).
  none,

  /// Eid al-Fitr: 1st, 2nd, and 3rd of Shawwal (Month 10).
  eidAlFitr,

  /// Eid al-Adha & Days of Tashreeq: 9th (Day of Arafah) through 13th of Dhu al-Hijjah (Month 12).
  eidAlAdha;

  bool get isEid => this != EidPeriod.none;
}

/// Service that detects Eid al-Fitr and Eid al-Adha periods using the Hijri calendar,
/// supporting a ±1 day manual adjustment for official local moon-sighting alignment.
class EidDetector {
  const EidDetector._();

  /// Month constants in the Islamic Hijri calendar.
  static const int shawwalMonth = 10;
  static const int dhuAlHijjahMonth = 12;

  /// Detects whether [date] falls into an Eid or Tashreeq period.
  ///
  /// [manualAdjustmentDays] applies a ±1 (or custom) day offset to synchronize
  /// algorithmic astronomical calculation with official national religious announcements.
  static EidPeriod detectEidPeriod({
    DateTime? date,
    int manualAdjustmentDays = 0,
  }) {
    final effectiveDate = (date ?? DateTime.now()).add(
      Duration(days: manualAdjustmentDays),
    );

    final hijri = HijriCalendar.fromDate(effectiveDate);
    final month = hijri.hMonth;
    final day = hijri.hDay;

    // 1. Eid al-Fitr: 1 to 3 Shawwal
    if (month == shawwalMonth && day >= 1 && day <= 3) {
      return EidPeriod.eidAlFitr;
    }

    // 2. Eid al-Adha + Arafah + Tashreeq: 9 to 13 Dhu al-Hijjah
    if (month == dhuAlHijjahMonth && day >= 9 && day <= 13) {
      return EidPeriod.eidAlAdha;
    }

    return EidPeriod.none;
  }

  /// Returns localized label for the active Eid period.
  static String? getEidLabel(EidPeriod period, {required bool isArabic}) {
    switch (period) {
      case EidPeriod.eidAlFitr:
        return isArabic ? 'عيد الفطر المبارك' : 'Eid al-Fitr';
      case EidPeriod.eidAlAdha:
        return isArabic ? 'عيد الأضحى المبارك وأيام التشريق' : 'Eid al-Adha & Tashreeq';
      case EidPeriod.none:
        return null;
    }
  }
}

import 'package:adhan/adhan.dart' as adhan;
import 'package:hijri/hijri_calendar.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';

/// Configuration adjustments applied to calculated prayer times.
class PrayerAdjustments {
  const PrayerAdjustments({
    this.fajr = 0,
    this.sunrise = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
  });

  final int fajr;
  final int sunrise;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;
}

/// Offline astronomical prayer calculation engine using the adhan library.
///
/// Defaults to the Egyptian General Authority of Survey (Fajr 19.5°, Isha 17.5°).
abstract final class PrayerTimesCalculator {
  /// Computes a [PrayerTimesBundle] for the specified [date] and coordinates.
  static PrayerTimesBundle calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
    required String cityNameAr,
    required String cityNameEn,
    CalculationMethodOption method = CalculationMethodOption.egyptian,
    MadhabOption madhab = MadhabOption.shafi,
    PrayerAdjustments adjustments = const PrayerAdjustments(),
  }) {
    final coordinates = adhan.Coordinates(latitude, longitude);
    final dateComponents = adhan.DateComponents(date.year, date.month, date.day);

    final params = _getParams(method)
      ..madhab =
          madhab == MadhabOption.hanafi ? adhan.Madhab.hanafi : adhan.Madhab.shafi;

    final adhanTimes = adhan.PrayerTimes(coordinates, dateComponents, params);

    // Apply manual minute adjustments if configured
    final fajrTime = adhanTimes.fajr.add(Duration(minutes: adjustments.fajr));
    final sunriseTime = adhanTimes.sunrise.add(Duration(minutes: adjustments.sunrise));
    final dhuhrTime = adhanTimes.dhuhr.add(Duration(minutes: adjustments.dhuhr));
    final asrTime = adhanTimes.asr.add(Duration(minutes: adjustments.asr));
    final maghribTime = adhanTimes.maghrib.add(Duration(minutes: adjustments.maghrib));
    final ishaTime = adhanTimes.isha.add(Duration(minutes: adjustments.isha));

    final isFriday = date.weekday == DateTime.friday;
    final now = DateTime.now();

    final rawList = [
      (type: PrayerType.fajr, time: fajrTime),
      (type: PrayerType.sunrise, time: sunriseTime),
      (type: PrayerType.dhuhr, time: dhuhrTime),
      (type: PrayerType.asr, time: asrTime),
      (type: PrayerType.maghrib, time: maghribTime),
      (type: PrayerType.isha, time: ishaTime),
    ];

    // Determine next and previous prayer
    PrayerItem? next;
    PrayerItem? prev;

    for (var i = 0; i < rawList.length; i++) {
      final item = rawList[i];
      if (item.time.isAfter(now) && next == null) {
        next = PrayerItem(
          type: item.type,
          time: item.time,
          isNext: true,
          isPast: false,
          isFriday: isFriday,
        );
        if (i > 0) {
          prev = PrayerItem(
            type: rawList[i - 1].type,
            time: rawList[i - 1].time,
            isNext: false,
            isPast: true,
            isFriday: isFriday,
          );
        }
      }
    }

    // If all prayers today have passed, next prayer is tomorrow's Fajr
    if (next == null) {
      final tomorrow = date.add(const Duration(days: 1));
      final tomorrowComponents =
          adhan.DateComponents(tomorrow.year, tomorrow.month, tomorrow.day);
      final tomorrowTimes =
          adhan.PrayerTimes(coordinates, tomorrowComponents, params);
      final tomorrowFajr =
          tomorrowTimes.fajr.add(Duration(minutes: adjustments.fajr));

      next = PrayerItem(
        type: PrayerType.fajr,
        time: tomorrowFajr,
        isNext: true,
        isPast: false,
        isFriday: tomorrow.weekday == DateTime.friday,
      );
      prev = PrayerItem(
        type: PrayerType.isha,
        time: ishaTime,
        isNext: false,
        isPast: true,
        isFriday: isFriday,
      );
    }

    final timeToNext = next.time.difference(now);

    final prayerItems = rawList.map((entry) {
      final isNextItem = entry.type == next!.type && entry.time.day == next.time.day;
      final isPastItem = entry.time.isBefore(now);
      return PrayerItem(
        type: entry.type,
        time: entry.time,
        isNext: isNextItem,
        isPast: isPastItem,
        isFriday: isFriday,
      );
    }).toList();

    // Hijri date calculations
    final hijriCalendar = HijriCalendar.fromDate(date);
    final hijriAr =
        '${hijriCalendar.hDay} ${_getHijriMonthNameAr(hijriCalendar.hMonth)} ${hijriCalendar.hYear} هـ';
    final hijriEn =
        '${hijriCalendar.hDay} ${_getHijriMonthNameEn(hijriCalendar.hMonth)} ${hijriCalendar.hYear} AH';

    // Synchronous localized Gregorian formatting
    final dayNameAr = _arabicDayNames[date.weekday - 1];
    final monthNameAr = _arabicMonthNames[date.month - 1];
    final gregorianAr = '$dayNameAr، ${date.day} $monthNameAr ${date.year}';

    final dayNameEn = _englishDayNames[date.weekday - 1];
    final monthNameEn = _englishMonthNames[date.month - 1];
    final gregorianEn = '$dayNameEn, ${date.day} $monthNameEn ${date.year}';

    return PrayerTimesBundle(
      date: date,
      cityNameAr: cityNameAr,
      cityNameEn: cityNameEn,
      hijriFormattedAr: hijriAr,
      hijriFormattedEn: hijriEn,
      gregorianFormattedAr: gregorianAr,
      gregorianFormattedEn: gregorianEn,
      prayers: prayerItems,
      nextPrayer: next,
      timeToNextPrayer: timeToNext.isNegative ? Duration.zero : timeToNext,
      previousPrayer: prev,
      isFriday: isFriday,
      calculationMethod: method,
      madhab: madhab,
    );
  }

  static adhan.CalculationParameters _getParams(CalculationMethodOption method) {
    switch (method) {
      case CalculationMethodOption.egyptian:
        return adhan.CalculationMethod.egyptian.getParameters();
      case CalculationMethodOption.muslimWorldLeague:
        return adhan.CalculationMethod.muslim_world_league.getParameters();
      case CalculationMethodOption.ummAlQura:
        return adhan.CalculationMethod.umm_al_qura.getParameters();
      case CalculationMethodOption.karachi:
        return adhan.CalculationMethod.karachi.getParameters();
    }
  }

  static const List<String> _arabicDayNames = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static const List<String> _arabicMonthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static const List<String> _englishDayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _englishMonthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String _getHijriMonthNameAr(int month) {
    const months = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  static String _getHijriMonthNameEn(int month) {
    const months = [
      'Muharram',
      'Safar',
      "Rabi' I",
      "Rabi' II",
      'Jumada I',
      'Jumada II',
      'Rajab',
      "Sha'ban",
      'Ramadan',
      'Shawwal',
      "Dhu al-Qi'dah",
      'Dhu al-Hijjah',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}

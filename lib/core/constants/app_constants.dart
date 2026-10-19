/// Technical and global application constants.
///
/// Contains core identifiers and app naming configurations.
abstract final class AppConstants {
  /// App name constant used throughout the application.
  /// Easy to edit in a single place.
  static const String appNameAr = 'طقس';
  static const String appNameEn = 'Taqs';

  /// Brand tagline for the combined Weather & Prayer Times experience.
  static const String appTaglineAr = 'طقس ومواقيت الصلاة';
  static const String appTaglineEn = 'Weather & Prayer Times';

  /// Primary storage keys for user preferences
  static const String themePreferenceKey = 'taqs_theme_mode_preference';
  static const String localePreferenceKey = 'taqs_locale_preference';
  static const String severeAlertsNotificationKey = 'taqs_severe_alerts_notification';
  static const String dailyBriefingNotificationKey = 'taqs_daily_briefing_notification';
  static const String homeTabPreferenceKey = 'taqs_home_selected_tab';
  static const String farmerModePreferenceKey = 'taqs_farmer_mode_preference';
  static const String prayerNotificationMasterKey = 'taqs_prayer_notification_master';
  static const String prayerLeadTimeKey = 'taqs_prayer_lead_time_minutes';
  static const String prayerCalculationMethodKey = 'taqs_prayer_calculation_method';
  static const String prayerMadhabKey = 'taqs_prayer_madhab';
  static const String takbeeratCardKey = 'taqs_takbeerat_card_enabled';
  static const String takbeeratRichNotifKey = 'taqs_takbeerat_rich_notif_enabled';
  static const String takbeeratSoundKey = 'taqs_takbeerat_sound_enabled';
  static const String eidModeKey = 'taqs_eid_mode_enabled';
  static const String hijriDayAdjustmentKey = 'taqs_hijri_day_adjustment';

  /// Default application location for Egypt weather foundation
  static const String defaultCityNameAr = 'القاهرة، مصر';
  static const String defaultCityNameEn = 'Cairo, Egypt';
  static const double defaultLatitude = 30.0444;
  static const double defaultLongitude = 31.2357;
}

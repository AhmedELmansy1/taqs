/// Technical and global application constants.
///
/// Contains core identifiers and app naming configurations.
abstract final class AppConstants {
  /// App name constant used throughout the application.
  /// Easy to edit in a single place.
  static const String appNameAr = 'طقس';
  static const String appNameEn = 'Taqs';

  /// Primary storage keys for user preferences
  static const String themePreferenceKey = 'taqs_theme_mode_preference';
  static const String localePreferenceKey = 'taqs_locale_preference';

  /// Default application location for Egypt weather foundation
  static const String defaultCityNameAr = 'القاهرة، مصر';
  static const String defaultCityNameEn = 'Cairo, Egypt';
  static const double defaultLatitude = 30.0444;
  static const double defaultLongitude = 31.2357;
}

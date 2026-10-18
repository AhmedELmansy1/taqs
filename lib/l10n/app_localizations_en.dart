// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Taqs';

  @override
  String get appTagline => 'Smart Weather Application for Egypt';

  @override
  String get navHome => 'Home';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeTitle => 'Today\'s Weather';

  @override
  String get defaultCity => 'Cairo, Egypt';

  @override
  String feelsLike(int temp) {
    return 'Feels like $temp°';
  }

  @override
  String get humidity => 'Humidity';

  @override
  String get windSpeed => 'Wind Speed';

  @override
  String windSpeedUnit(int speed) {
    return '$speed km/h';
  }

  @override
  String get uvIndex => 'UV Index';

  @override
  String get airQuality => 'Air Quality';

  @override
  String get airQualityGood => 'Good';

  @override
  String get hourlyForecastTitle => 'Hourly Forecast';

  @override
  String get weeklyForecastTitle => '7-Day Forecast';

  @override
  String get conditionSunny => 'Sunny';

  @override
  String get conditionPartlyCloudy => 'Partly Cloudy';

  @override
  String get conditionCloudy => 'Cloudy';

  @override
  String get conditionRainy => 'Rainy';

  @override
  String get conditionDustStorm => 'Dust Storm';

  @override
  String get conditionFog => 'Fog';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance & Display';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light Mode';

  @override
  String get themeDark => 'Dark Mode';

  @override
  String get languageSection => 'Language & Region';

  @override
  String get language => 'App Language';

  @override
  String get languageArabic => 'العربية (Arabic)';

  @override
  String get languageEnglish => 'English';

  @override
  String get aboutSection => 'About App';

  @override
  String get aboutDeveloper => 'About the Developer';

  @override
  String get aboutDeveloperSubtitle =>
      'Ahmed Elmansy • Profile & Contact Details';

  @override
  String get developerName => 'Ahmed Elmansy';

  @override
  String get developerTitle => 'Flutter Developer • Cybersecurity • AI';

  @override
  String get developerLocation => 'Sharqia, Egypt';

  @override
  String get developerSummary =>
      'Flutter Developer, AI & Cybersecurity enthusiast, Computer Science graduate.';

  @override
  String get educationSectionTitle => 'Education & Degrees';

  @override
  String get educationDegree =>
      'Bachelor\'s in Computer Science and Information, Benha University';

  @override
  String get educationSpecialization =>
      'Specialization: Information Security & Digital Forensics (Grade: Very Good)';

  @override
  String get educationGraduationProject =>
      'Graduation Project: Forgery Detection (AI-powered image/audio forgery detection) — Excellent';

  @override
  String get skillsSectionTitle => 'Skills & Technologies';

  @override
  String get projectsSectionTitle => 'Projects';

  @override
  String get contactSectionTitle => 'Contact Information';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get github => 'GitHub Profile';

  @override
  String get linkedin => 'LinkedIn Profile';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get callPhone => 'Call';

  @override
  String get openGitHub => 'Open Profile';

  @override
  String get openLinkedIn => 'Open Profile';

  @override
  String cannotLaunchUrl(String target) {
    return 'Could not launch link: $target';
  }

  @override
  String copiedToClipboard(String text) {
    return 'Copied to clipboard: $text';
  }

  @override
  String get builtWithFlutter => 'Built with Flutter';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get retry => 'Retry';

  @override
  String get emptyStateMessage => 'No data available at the moment';

  @override
  String get errorStateMessage =>
      'An unexpected error occurred while loading data';

  @override
  String get splashLoading => 'Initializing Taqs Egypt...';

  @override
  String get openMeteoAttribution => 'Weather data by Open-Meteo.com';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get searchLocationHint => 'Search governorate or city...';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get egyptianGovernorates => 'Egyptian Governorates';

  @override
  String get savedLocations => 'Saved Locations';

  @override
  String get noSavedLocations => 'No saved locations yet';

  @override
  String get locationPermissionTitle => 'Location Permission Required';

  @override
  String get locationPermissionRationale =>
      'Taqs needs your location access to display accurate local weather forecasts.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String offlineDataBanner(String time) {
    return 'Offline data • Last updated: $time';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get windUnit => 'Wind Speed Unit';

  @override
  String get windUnitKmh => 'km/h (Kilometers per hour)';

  @override
  String get windUnitMs => 'm/s (Meters per second)';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get severeAlertsToggle => 'Severe Weather Warnings (Khamsin & Fog)';

  @override
  String get severeAlertsSubtitle =>
      'Early warnings for severe storms, dust and dense fog';

  @override
  String get dailyBriefingToggle => 'Daily Morning Briefing';

  @override
  String get dailyBriefingSubtitle =>
      'Daily summary of weather conditions and clothing advice';

  @override
  String get whatToWearTitle => 'What to wear today?';

  @override
  String get safetyTipsTitle => 'Safety Guidance:';

  @override
  String get dustMetric => 'Dust';
}

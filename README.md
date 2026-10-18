# طقس ومواقيت الصلاة • Taqs: Weather & Prayer Times

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod_3-black?logo=flutter)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/AhmedELmansy1/taqs/actions/workflows/ci.yml/badge.svg)](.github/workflows/ci.yml)

> **طقس (Taqs)** is an Arabic-first, production-grade combined **Weather & Prayer Times** application crafted specifically for Egypt. Designed with deep navy atmospheric aesthetics, electric blue and metallic gold accents, strict type safety, Feature-First Clean Architecture, offline astronomical prayer computations, 5-minute pre-prayer exact notifications, live Open-Meteo meteorological and coastal marine forecasts, agricultural farming mode, highway driving safety index, governorate comparison, social card sharing, and Android Home-Screen widgets.

---

## 🌟 Key Features

### 1. Dual-Core Home Switcher
- **Segmented Header Switch**: Seamless top pill switch toggling between **"الطقس / Weather"** and **"مواقيت الصلاة / Prayer Times"**.
- **Sliding Indicator & Haptics**: Smooth cubic animation with physical haptic feedback and persistence of the user's last active section.
- **Deep Linking Support**: Supports direct deep links (e.g. `/prayer` or `/?tab=prayer`) opening the app directly to prayer times when tapped from notifications or widgets.

### 2. Astronomical Prayer Times Engine (`lib/features/prayer`)
- **100% Offline Computation**: Calculates prayer times locally from GPS or selected Egyptian governorate coordinates using astronomical algorithms.
- **Egyptian General Authority of Survey Standards**: Default calculation method is configured to official Egyptian survey angles:
  - **Fajr**: 19.5°
  - **Isha**: 17.5°
- **Shafi'i & Hanafi Asr Madhab**: Defaults to Shafi'i / Maliki / Hanbali (shadow ratio 1:1), with selectable Hanafi option (shadow ratio 2:1).
- **Manual Minute Adjustments**: Per-prayer fine-tuning sliders (±15 minutes) in Settings to match local mosque timetables.
- **Friday / Jumu'ah Dynamic Labeling**: Dhuhr prayer is automatically labeled **"الجمعة / Jumu'ah"** on Fridays.
- **Live Arc & Countdown**: Custom-painted golden arc (`PrayerCountdownArc`) showing remaining time and live second countdown to the next prayer, respecting `disableAnimations` / reduced motion.
- **Dual Calendar**: Arabic and English Hijri and Gregorian dates.
  > **Note & Disclaimer**: *Calculated prayer times and Hijri dates are based on astronomical calculations and may vary by ±1–2 minutes or ±1 day compared to official local sighting and mosque timetables. Users are encouraged to verify against their local mosque.*

### 3. 5-Minute Pre-Prayer Notifications
- **Lead Time Reminders**: Automatically alerts users before prayer calls (default: **5 minutes before**, customizable to 0, 5, 10, or 15 minutes).
- **Rolling 7-Day Window**: Pre-schedules a rolling week of notifications using local notification alarms.
- **Automated Rescheduling Lifecycle**:
  - Automatically regenerates on app launch, location changes, calculation settings edits, device reboot (`BOOT_COMPLETED`), and from the 12-hour background worker safety net.
- **Google Play Exact Alarm Compliance (`SCHEDULE_EXACT_ALARM`)**:
  - Complies with Android 12–14 Google Play Store exact alarm restrictions.
  - Dynamically checks `canScheduleExactNotifications()` at runtime.
  - If denied, gracefully falls back to inexact scheduling with an honest transparent status note and one-tap deep link to Android system settings.
- **Notification Channel**: High-importance dedicated Android channel: *"تنبيهات مواقيت الصلاة (Prayer reminders)"*.
- **Battery Optimization Transparency**: Standard Android Doze mode and manufacturer power savers (Xiaomi, Samsung, Huawei) may defer non-whitelisted alarms. In-app settings explain how to whitelist the app for reliable delivery.
- **Custom Adhan Audio**: Uses system notification sounds by default (no copyrighted audio bundled). Users can optionally provide their own licensed adhan audio by placing an MP3 at `android/app/src/main/res/raw/adhan.mp3`.

### 4. Coastal Marine Conditions
- **Open-Meteo Marine API**: Automatically queries significant wave height, wave period, wave direction, and wind waves for coastal coordinates.
- **Verified Coastal Presets**: Alexandria, Marsa Matrouh, North Coast (Alamein / Sidi Abdel Rahman), Port Said, Hurghada, Sharm El Sheikh, and Dahab.
- **Contextual Marine Card**: Appears on the Weather section **only** when marine data is available for the location; gracefully hidden for inland points with zero errors.
- **Deterministic Sea State Rating**:
  - `calm`: Wave height < 1.0m (Safe for swimming)
  - `moderate`: 1.0m – 2.0m (Moderate waves)
  - `rough`: 2.0m – 3.0m (Caution advised; red flag)
  - `dangerous`: ≥ 3.0m (Dangerous; swimming prohibited)
- **Safety Disclaimer**: *Marine conditions are indicative forecasts. Always observe beach lifeguard flags and official port authorities.*

### 5. Highway Driving Safety Index
- **Deterministic Domain Engine**: Evaluates road safety for travel across Egypt by correlating:
  - Dense morning agricultural & desert fog (`visibilityKm <= 0.6km` → Extreme Risk, `<= 2.0km` → Hazardous)
  - Khamsin dust storm conditions with gale winds (`windSpeedKmh >= 50` → Extreme Risk)
  - Torrential rain & aquaplaning risks
  - Night driving illumination reminders
- **4 Safety Levels**: Good, Caution, Hazardous, and Extreme Risk, accompanied by actionable Arabic/English highway survival tips.

### 6. Agricultural Farming Mode
- **Farmer Mode Toggle**: Discreet toggle in Settings tailored for Egyptian agriculturalists, farmers, and greenhouse managers.
- **Frost Risk Detection**: Detects crop-damaging frost risks (High when forecast minimum temp ≤ 2°C, Moderate at 3–5°C) with nocturnal misting advice for sensitive crops (tomatoes, strawberries).
- **Daily Reference Evapotranspiration (ET0)**: Computes irrigation evaporation benchmarks in mm based on temperature, wind speed, solar radiation, and humidity.
- **Soil Metrics & Rain Outlook**: Estimated 0–7cm soil temperature and moisture, advising when to delay spraying to prevent fertilizer washout.

### 7. Social Weather Card Sharing & Governorate Comparison
- **Share Card as Image (`WeatherShareCard`)**:
  - High-DPI 3x resolution off-screen render via `RepaintBoundary` and PNG export.
  - Branded layout with Taqs vector logo, location name, temperature, weather artwork, rain chance, and next prayer time.
  - Seamless native sharing via `share_plus` directly to WhatsApp, Telegram, and social networks with temporary file cleanup.
- **Compare Two Governorates (`CompareGovernoratesScreen`)**:
  - Side-by-side comparative screen with independent asynchronous loading.
  - Temperature differential banner (e.g. *"القاهرة أدفأ بـ 4°م من الإسكندرية"*).
  - Comparative metrics for temperature, feels-like, rain chance, wind speed, humidity, and European AQI.
  - 3-day forecast outlook side-by-side.
  - Complete error isolation: if one location's query fails, the other continues rendering without crash.

### 8. Android Home-Screen Widgets
- **4×2 Expanded Widget**: Displays current temperature, weather condition, location name, next prayer name + time, and last update timestamp. Tapping opens the app directly.
- **2×2 Compact Widget**: Compact tile displaying temperature, condition, city name, and next prayer.
- **Stale Cache Indicator**: Indicates cached data timestamp if device is offline.
- **Periodic Sync**: Automatically updated on app launch, weather refresh, and in the background via `workmanager`.
- *(iOS widgets are documented as deferred to a future macOS/Xcode build phase).*

---

## 🔒 Permissions & Privacy Commitment

Everything in Taqs runs strictly on-device without telemetry, user tracking, or analytical SDKs.

| Permission | Platform | Purpose | Privacy Guarantee |
| :--- | :--- | :--- | :--- |
| `ACCESS_FINE_LOCATION`<br>`ACCESS_COARSE_LOCATION` | Android & iOS | Query local meteorological and prayer calculations for user's GPS coordinates | GPS coordinates are processed **strictly on-device**. Coordinates are sent directly to Open-Meteo for forecasts and are never stored or logged on any external server. |
| `POST_NOTIFICATIONS` | Android 13+ & iOS | Deliver pre-prayer reminders and 12-hour weather briefings | All notifications are generated locally on the phone. |
| `SCHEDULE_EXACT_ALARM` | Android 12+ | Ensure pre-prayer reminders fire precisely 5 minutes before the adhan | Used strictly for prayer times. If permission is denied, the app gracefully falls back to inexact alarms. |
| `RECEIVE_BOOT_COMPLETED` | Android | Re-schedule the 7-day rolling prayer reminders after device restart | Used solely by local receivers to restore prayer reminders after phone reboot. |

---

## 🔊 How to Add a Custom Adhan Audio

By default, Taqs uses the clean system notification sound to avoid copyright issues and respect user device audio preferences. To enable a custom Adhan audio:

1. Obtain a licensed or open-license audio recording in MP3 or WAV format.
2. Rename the file to `adhan.mp3`.
3. Place it in:
   ```
   android/app/src/main/res/raw/adhan.mp3
   ```
4. Rebuild the app:
   ```bash
   flutter build apk --debug
   ```
If the file is absent, Taqs automatically and silently defaults to the standard system notification tone.

---

## 🏗️ Architecture & Code Quality

The codebase enforces **Feature-First Clean Architecture** with **MVVM** in the presentation layer:

```
lib/
├── app.dart                                # App entry point, widget update listeners, notification routing
├── core/                                   # Cross-cutting technical infrastructure
│   ├── constants/                          # App branding and SharedPreferences keys
│   ├── design/                             # Tokens, Cairo typography, themes, components
│   ├── errors/                             # Failure definitions and localization
│   ├── localization/                       # LocaleController with Arabic-first priority
│   ├── navigation/                         # GoRouter route declarations and shell navigation
│   ├── network/                            # Robust HTTP client with exponential backoff
│   ├── notifications/                      # LocalNotificationService, PrayerNotificationScheduler, Worker
│   ├── sharing/                            # CardImageSharer (RepaintBoundary to PNG via share_plus)
│   ├── storage/                            # KeyValueStorage abstraction
│   └── widgets/                            # HomeWidgetManager (Android AppWidget sync)
└── features/                               # Domain features
    ├── advisor/                            # ClothingAdvisor domain engine
    ├── air_quality/                        # European AQI and particulate matter feature
    ├── alerts/                             # Severe weather alert evaluator
    ├── compare/                            # Governorates comparative analysis feature
    ├── driving/                            # Highway driving safety evaluator
    ├── farming/                            # Agricultural frost, ET0, and soil evaluator
    ├── location/                           # Geolocation, 27 Egyptian governorates repository
    ├── marine/                             # Open-Meteo Marine conditions for coastal cities
    ├── onboarding/                         # First-launch contextual permissions flow
    ├── prayer/                             # Offline astronomical prayer times calculations & UI
    ├── settings/                           # Appearance, language, notification, prayer settings
    ├── splash/                             # Vector brand animated splash screen
    └── weather/                            # Open-Meteo forecast repository, daily/hourly cards
```

---

## 🧪 Quality Gates & Verification

- **Linting**: 100% adherence to `very_good_analysis` rules with **0 analyzer warnings**.
- **Test Suite**: Over **100+ automated unit and widget tests** covering:
  - Astronomical prayer times calculations against Egyptian General Authority of Survey tolerances for Cairo, Alexandria, and Aswan.
  - Friday / Jumu'ah labeling logic and live countdown calculations.
  - Rolling 7-day notification window scheduling and exact alarm fallback fakes.
  - Coastal marine rating thresholds and wind wave compass orientations.
  - Highway driving safety index edge cases (Khamsin dust storm, dense fog, torrential rain).
  - Farming mode ET0 and frost risk classifications.
  - Side-by-side governorate comparison and error isolation.
  - Home-screen widget data mapping.
  - Segmented switch header animations and RTL layout correctness.

To run the verification suite locally:
```bash
dart analyze .
flutter test
```

---

## 👨‍💻 Author

**Ahmed Elmansy (أحمد المنسي)**  
*Flutter Developer • Cybersecurity • AI*  
- 📍 **Location**: Sharqia, Egypt  
- 🎓 **Education**: Bachelor's in Computer Science and Information, Benha University  
  - *Specialization*: Information Security & Digital Forensics (Grade: Very Good)  
  - *Graduation Project*: AI-powered Audio & Image Forgery Detection (Grade: Excellent)  
- 📧 **Email**: [ahmedelmansy1311@gmail.com](mailto:ahmedelmansy1311@gmail.com)  
- 💼 **LinkedIn**: [linkedin.com/in/ahmed-elmansy](https://www.linkedin.com/in/ahmed-elmansy-a6b494346)  
- 🐙 **GitHub**: [github.com/AhmedELmansy1](https://github.com/AhmedELmansy1)  

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

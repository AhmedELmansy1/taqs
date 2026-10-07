# طقس • Taqs

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod_3-black?logo=flutter)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/AhmedELmansy1/taqs/actions/workflows/ci.yml/badge.svg)](.github/workflows/ci.yml)

> **طقس (Taqs)** is an Arabic-first, production-grade weather application crafted specifically for Egypt. Designed with deep navy atmospheric aesthetics, strict type safety, Feature-First Clean Architecture, and full RTL/LTR internationalization.

---

## 🌟 Project Vision & Roadmap

While global weather apps treat the Middle East as an afterthought, **طقس (Taqs)** is purpose-built to address Egypt's unique meteorological patterns and cultural context.

### Phase 1 (Current Foundation)
- [x] **Architecture & State Foundation**: Feature-first Clean Architecture, Riverpod state management & DI, and GoRouter navigation with persistent bottom navigation shell.
- [x] **Design System (`lib/core/design`)**: Calm, premium deep navy palette, electric blue and cyan accents, metallic-gold highlights, accessible contrast, responsive breakpoints, and Cairo typography.
- [x] **Arabic-First Localization**: Native Arabic default with complete RTL support, dynamic English switching, and local preference persistence via SharedPreferences.
- [x] **Weather Skeleton**: Mock repository contracts simulating Egypt forecasts (current temperature hero card, hourly scroll strip, 7-day forecast).
- [x] **Developer Showcase**: Dedicated, verified profile page for **Ahmed Elmansy** with contact actions and platform integrations.

### Phase 2 Roadmap
- [ ] **Live Open-Meteo Integration**: Swap `MockWeatherRepository` with real Open-Meteo REST API data source and DTO mappers.
- [ ] **Location Services**: Geolocation with permission management for automatic Egyptian governorate detection (Cairo, Alexandria, Mansoura, Zagazig, Aswan, etc.).
- [ ] **Egypt-Specific Severe Alerts**: Early warning indicators for dust storms (الخماسين), dense morning highway fog (الشبورة المائية), heat waves, and localized torrential rain.
- [ ] **"What Should I Wear?" AI Advice**: Smart contextual recommendations based on humidity and perceived temperature.
- [ ] **Air Quality Index (AQI)**: Particulate matter monitoring (PM2.5 / PM10).
- [ ] **Home Screen Widget**: Glanceable Android & iOS widget.

---

## 🏗️ Architecture

The codebase follows **Feature-First Clean Architecture** with **MVVM** in presentation:

```mermaid
graph TD
    subgraph UI ["Presentation Layer"]
        Screen["Screen / Widget"]
        VM["ViewModel (Notifier / AsyncNotifier)"]
    end

    subgraph Domain ["Domain Layer"]
        Contract["Repository Contract (Interface)"]
        Entity["Domain Entities (Immutable)"]
    end

    subgraph Data ["Data Layer"]
        RepoImpl["Repository Implementation"]
        DataSource["Local / Remote Data Source"]
    end

    subgraph Core ["Technical Infrastructure"]
        Storage["KeyValueStorage (SharedPreferences)"]
        Router["GoRouter (StatefulShellRoute)"]
        Design["Design Tokens & Widgets"]
    end

    Screen --> VM
    VM --> Contract
    Contract --> Entity
    RepoImpl -. implements .-> Contract
    RepoImpl --> DataSource
    DataSource --> Storage
    Screen --> Router
    Screen --> Design
```

### Folder Layout
```text
lib/
├── app.dart                   # Root MaterialApp with router & theme setup
├── main.dart                  # Async initialization & ProviderScope overrides
├── l10n/                      # ARB localization sources (ar, en)
├── core/
│   ├── constants/             # App naming & storage keys
│   ├── design/                # Tokens, Typography (Cairo), Theme, Components
│   ├── localization/          # LocaleController & language switching
│   ├── navigation/            # GoRouter configuration & shell navigation
│   ├── storage/               # KeyValueStorage contracts & implementations
│   └── theme/                 # ThemeController (Light / Dark / System)
└── features/
    ├── about/                 # Developer profile presentation & model
    ├── settings/              # Appearance & language preferences
    ├── splash/                # Initial boot & splash screen
    └── weather/               # Domain entities, repo contracts, mock data, widgets
```

---

## 🛠️ Tech Stack

- **Framework**: [Flutter 3.47+](https://flutter.dev) (Dart 3.13+)
- **State Management**: [flutter_riverpod 3.4.3](https://pub.dev/packages/flutter_riverpod)
- **Routing**: [go_router 18.0.2](https://pub.dev/packages/go_router)
- **Storage**: [shared_preferences 2.5.6](https://pub.dev/packages/shared_preferences)
- **Internationalization**: `flutter_localizations` & `intl 0.20.3`
- **Typography & Icons**: Cairo font family & Cupertino/Material icons
- **Utilities**: `url_launcher 6.3.3`, `package_info_plus 10.2.2`
- **Analysis & Testing**: `very_good_analysis 11.0.0`, `mocktail 1.0.5`, `flutter_test`

---

## 🚀 Getting Started

Follow these 4 simple steps to run the app locally:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/AhmedELmansy1/taqs.git
   cd taqs
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify analyzer and test suite**:
   ```bash
   flutter analyze
   flutter test
   ```

4. **Launch the application**:
   ```bash
   flutter run
   ```

---

## 📱 Screenshots

| Home (Dark - Arabic RTL) | Settings (Arabic) | About Developer |
| :---: | :---: | :---: |
| *(Screenshot Placeholder)* | *(Screenshot Placeholder)* | *(Screenshot Placeholder)* |

---

## 👨‍💻 About the Developer

**Ahmed Elmansy (أحمد المنسي)**  
*Flutter Developer • Cybersecurity • AI*  
- 📍 **Location**: Sharqia, Egypt  
- 🎓 **Education**: Bachelor's in Computer Science and Information, Benha University (Information Security & Digital Forensics)  
- 📧 **Email**: [ahmedelmansy1311@gmail.com](mailto:ahmedelmansy1311@gmail.com)  
- 💼 **LinkedIn**: [linkedin.com/in/ahmed-elmansy](https://www.linkedin.com/in/ahmed-elmansy-a6b494346)  
- 🐙 **GitHub**: [github.com/AhmedELmansy1](https://github.com/AhmedELmansy1)  

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

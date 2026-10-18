import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/design/theme/app_theme.dart';
import 'package:taqs/core/localization/locale_controller.dart';
import 'package:taqs/core/navigation/app_router.dart';
import 'package:taqs/core/notifications/notification_service.dart';
import 'package:taqs/core/notifications/prayer_notification_scheduler.dart';
import 'package:taqs/core/theme/theme_controller.dart';
import 'package:taqs/core/widgets/home_widget_manager.dart';
import 'package:taqs/features/location/presentation/providers/location_controller.dart';
import 'package:taqs/features/prayer/presentation/providers/prayer_settings_controller.dart';
import 'package:taqs/features/prayer/presentation/providers/prayer_view_model.dart';
import 'package:taqs/features/weather/presentation/providers/weather_provider.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Root application widget configuring routing, themes, and localization.
class TaqsApp extends ConsumerWidget {
  const TaqsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    // Deep link tap handling for prayer and weather notifications
    LocalNotificationServiceImpl.onNotificationTapped = (payload) {
      if (payload.isNotEmpty) {
        unawaited(router.push(payload));
      }
    };

    // Auto-reschedule 7-day prayer reminders whenever settings or location change
    ref.listen(prayerSettingsControllerProvider, (_, _) {
      unawaited(
        triggerPrayerNotificationReschedule(
          ref,
          isArabic: locale.languageCode != 'en',
        ),
      );
    });
    ref.listen(locationControllerProvider, (_, _) {
      unawaited(
        triggerPrayerNotificationReschedule(
          ref,
          isArabic: locale.languageCode != 'en',
        ),
      );
    });

    // Update Android Home-Screen widgets whenever weather or prayer times update
    ref.listen(weatherViewModelProvider, (_, weatherState) {
      final weather = weatherState.asData?.value;
      if (weather == null) return;
      final prayer = ref.read(prayerViewModelProvider);
      unawaited(
        HomeWidgetManager.updateWidgets(
          weather: weather,
          prayerTimes: prayer,
          isArabic: locale.languageCode != 'en',
        ),
      );
    });

    return MaterialApp.router(
      title: locale.languageCode == 'ar'
          ? AppConstants.appNameAr
          : AppConstants.appNameEn,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

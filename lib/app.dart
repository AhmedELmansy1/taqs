import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/design/theme/app_theme.dart';
import 'package:taqs/core/localization/locale_controller.dart';
import 'package:taqs/core/navigation/app_router.dart';
import 'package:taqs/core/theme/theme_controller.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Root application widget configuring routing, themes, and localization.
class TaqsApp extends ConsumerWidget {
  const TaqsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

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

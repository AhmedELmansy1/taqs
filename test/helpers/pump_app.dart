import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/design/theme/app_theme.dart';
import 'package:taqs/core/localization/locale_controller.dart';
import 'package:taqs/core/notifications/notification_service.dart';
import 'package:taqs/core/storage/storage_providers.dart';
import 'package:taqs/features/weather/data/providers/weather_data_providers.dart';
import 'package:taqs/features/weather/data/repositories/mock_weather_repository.dart';
import 'package:taqs/features/weather/domain/repositories/weather_repository.dart';
import 'package:taqs/l10n/app_localizations.dart';
import 'fake_key_value_storage.dart';
import 'fake_notification_service.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    Locale locale = AppLocales.arabic,
    WeatherRepository? weatherRepository,
  }) async {
    final fakeStorage = FakeKeyValueStorage();
    final fakeNotifications = FakeNotificationService();
    await pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStorageProvider.overrideWithValue(fakeStorage),
          notificationServiceProvider.overrideWithValue(fakeNotifications),
          weatherRepositoryProvider.overrideWithValue(
            weatherRepository ?? const MockWeatherRepository(),
          ),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: widget,
        ),
      ),
    );
    await pump();
  }
}

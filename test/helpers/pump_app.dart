import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/design/theme/app_theme.dart';
import 'package:taqs/core/localization/locale_controller.dart';
import 'package:taqs/core/storage/storage_providers.dart';
import 'package:taqs/l10n/app_localizations.dart';
import 'fake_key_value_storage.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    Locale locale = AppLocales.arabic,
  }) async {
    final fakeStorage = FakeKeyValueStorage();
    await pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStorageProvider.overrideWithValue(fakeStorage),
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/storage/key_value_storage.dart';
import 'package:taqs/core/storage/storage_providers.dart';

/// Supported locales in the application.
abstract final class AppLocales {
  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');

  static const List<Locale> supportedLocales = [
    arabic,
    english,
  ];
}

/// Notifier managing application locale with Arabic as the default.
class LocaleController extends Notifier<Locale> {
  late final KeyValueStorage _storage;

  @override
  Locale build() {
    _storage = ref.watch(keyValueStorageProvider);
    unawaited(_loadPersistedLocale());
    // Default language is Arabic for Egypt
    return AppLocales.arabic;
  }

  Future<void> _loadPersistedLocale() async {
    final savedCode =
        await _storage.getString(AppConstants.localePreferenceKey);
    if (savedCode == null) return;

    final resolved = AppLocales.supportedLocales.firstWhere(
      (l) => l.languageCode == savedCode,
      orElse: () => AppLocales.arabic,
    );

    if (ref.mounted) {
      state = resolved;
    }
  }

  /// Sets new locale and persists choice to storage.
  Future<void> setLocale(Locale newLocale) async {
    if (!AppLocales.supportedLocales.contains(newLocale)) return;
    state = newLocale;
    await _storage.setString(
      AppConstants.localePreferenceKey,
      newLocale.languageCode,
    );
  }

  /// Toggles between Arabic and English.
  Future<void> toggleLocale() async {
    final next = state.languageCode == 'ar'
        ? AppLocales.english
        : AppLocales.arabic;
    await setLocale(next);
  }
}

/// Global provider for [LocaleController].
final localeControllerProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);

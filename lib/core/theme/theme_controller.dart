import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/storage/key_value_storage.dart';
import 'package:taqs/core/storage/storage_providers.dart';

/// Notifier managing application theme mode selection and local persistence.
class ThemeController extends Notifier<ThemeMode> {
  late final KeyValueStorage _storage;

  @override
  ThemeMode build() {
    _storage = ref.watch(keyValueStorageProvider);
    unawaited(_loadPersistedTheme());
    return ThemeMode.system;
  }

  Future<void> _loadPersistedTheme() async {
    final savedMode = await _storage.getString(AppConstants.themePreferenceKey);
    if (savedMode == null) return;

    final resolved = ThemeMode.values.firstWhere(
      (m) => m.name == savedMode,
      orElse: () => ThemeMode.system,
    );

    if (ref.mounted) {
      state = resolved;
    }
  }

  /// Updates current theme mode and persists choice to storage.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _storage.setString(AppConstants.themePreferenceKey, mode.name);
  }
}

/// Global provider for [ThemeController].
final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

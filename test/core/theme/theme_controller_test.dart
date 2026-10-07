import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/storage/storage_providers.dart';
import 'package:taqs/core/theme/theme_controller.dart';
import '../../helpers/fake_key_value_storage.dart';

void main() {
  group('ThemeController', () {
    late FakeKeyValueStorage storage;
    late ProviderContainer container;

    setUp(() {
      storage = FakeKeyValueStorage();
      container = ProviderContainer(
        overrides: [
          keyValueStorageProvider.overrideWithValue(storage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initializes with ThemeMode.system by default', () {
      final state = container.read(themeControllerProvider);
      expect(state, equals(ThemeMode.system));
    });

    test('setThemeMode updates state and persists to storage', () async {
      final controller = container.read(themeControllerProvider.notifier);

      await controller.setThemeMode(ThemeMode.dark);

      expect(container.read(themeControllerProvider), equals(ThemeMode.dark));
      final saved = await storage.getString(AppConstants.themePreferenceKey);
      expect(saved, equals(ThemeMode.dark.name));
    });

    test('restores previously saved theme from storage', () async {
      await storage.setString(
        AppConstants.themePreferenceKey,
        ThemeMode.light.name,
      );

      final newContainer = ProviderContainer(
        overrides: [
          keyValueStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(newContainer.dispose);

      // Trigger build and wait microtasks for async load
      final _ = newContainer.read(themeControllerProvider);
      await Future<void>.delayed(Duration.zero);

      expect(
        newContainer.read(themeControllerProvider),
        equals(ThemeMode.light),
      );
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/localization/locale_controller.dart';
import 'package:taqs/core/storage/storage_providers.dart';
import '../../helpers/fake_key_value_storage.dart';

void main() {
  group('LocaleController', () {
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

    test('initializes with Arabic locale as default for Egypt', () {
      final state = container.read(localeControllerProvider);
      expect(state, equals(AppLocales.arabic));
      expect(state.languageCode, equals('ar'));
    });

    test('setLocale changes locale and persists language code', () async {
      final controller = container.read(localeControllerProvider.notifier);

      await controller.setLocale(AppLocales.english);

      expect(container.read(localeControllerProvider), equals(AppLocales.english));
      final saved = await storage.getString(AppConstants.localePreferenceKey);
      expect(saved, equals('en'));
    });

    test('toggleLocale switches between Arabic and English', () async {
      final controller = container.read(localeControllerProvider.notifier);

      await controller.toggleLocale();
      expect(container.read(localeControllerProvider), equals(AppLocales.english));

      await controller.toggleLocale();
      expect(container.read(localeControllerProvider), equals(AppLocales.arabic));
    });
  });
}

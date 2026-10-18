import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/storage/key_value_storage.dart';
import 'package:taqs/core/storage/storage_providers.dart';

/// The two primary operational sections of the Taqs Home experience.
enum HomeTab {
  weather,
  prayer,
}

/// Controller managing the persistent active section (Weather vs. Prayer Times).
class HomeTabController extends Notifier<HomeTab> {
  late final KeyValueStorage _storage;

  @override
  HomeTab build() {
    _storage = ref.watch(keyValueStorageProvider);
    unawaited(_loadPersistedTab());
    return HomeTab.weather;
  }

  Future<void> _loadPersistedTab() async {
    final saved = await _storage.getString(AppConstants.homeTabPreferenceKey);
    if (saved == 'prayer' && ref.mounted) {
      state = HomeTab.prayer;
    }
  }

  /// Sets the active tab, saving the user preference.
  Future<void> setTab(HomeTab tab) async {
    if (state == tab) return;
    state = tab;
    await _storage.setString(
      AppConstants.homeTabPreferenceKey,
      tab == HomeTab.prayer ? 'prayer' : 'weather',
    );
  }
}

/// Global provider for [HomeTabController].
final homeTabControllerProvider =
    NotifierProvider<HomeTabController, HomeTab>(HomeTabController.new);

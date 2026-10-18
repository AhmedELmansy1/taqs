import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/storage/key_value_storage.dart';
import 'package:taqs/core/storage/storage_providers.dart';

/// Notifier managing persistent state of agricultural "Farmer Mode".
class FarmerModeController extends Notifier<bool> {
  late final KeyValueStorage _storage;

  @override
  bool build() {
    _storage = ref.watch(keyValueStorageProvider);
    unawaited(_load());
    return false;
  }

  Future<void> _load() async {
    final raw = await _storage.getString(AppConstants.farmerModePreferenceKey);
    if (raw == 'true' && ref.mounted) {
      state = true;
    }
  }

  /// Sets Farmer Mode enabled/disabled and saves to local storage.
  Future<void> setFarmerMode({required bool enabled}) async {
    state = enabled;
    await _storage.setString(
      AppConstants.farmerModePreferenceKey,
      enabled.toString(),
    );
  }
}

/// Provider for [FarmerModeController].
final farmerModeControllerProvider =
    NotifierProvider<FarmerModeController, bool>(FarmerModeController.new);

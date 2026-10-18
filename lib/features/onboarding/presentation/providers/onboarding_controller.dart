import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/storage/key_value_storage.dart';
import 'package:taqs/core/storage/storage_providers.dart';

/// Manages first-launch onboarding state and persistent flag.
class OnboardingController extends Notifier<bool> {
  static const String onboardingCompletedKey = 'taqs_onboarding_completed';

  KeyValueStorage get _storage => ref.read(keyValueStorageProvider);

  @override
  bool build() {
    return false;
  }

  /// Checks storage to determine if onboarding was completed previously.
  Future<bool> checkStatus() async {
    final value = await _storage.getString(onboardingCompletedKey);
    final completed = value == 'true';
    state = completed;
    return completed;
  }

  /// Marks onboarding as completed and persists the flag.
  Future<void> completeOnboarding() async {
    await _storage.setString(onboardingCompletedKey, 'true');
    state = true;
  }
}

/// Global provider for [OnboardingController].
final onboardingControllerProvider =
    NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);

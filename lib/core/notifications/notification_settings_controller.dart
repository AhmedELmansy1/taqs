import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/notifications/notification_service.dart';
import 'package:taqs/core/storage/key_value_storage.dart';
import 'package:taqs/core/storage/storage_providers.dart';

/// Preference state model for notification channels in Taqs.
class NotificationSettingsState {
  const NotificationSettingsState({
    this.severeAlertsEnabled = true,
    this.dailyBriefingEnabled = true,
  });

  final bool severeAlertsEnabled;
  final bool dailyBriefingEnabled;

  NotificationSettingsState copyWith({
    bool? severeAlertsEnabled,
    bool? dailyBriefingEnabled,
  }) {
    return NotificationSettingsState(
      severeAlertsEnabled: severeAlertsEnabled ?? this.severeAlertsEnabled,
      dailyBriefingEnabled: dailyBriefingEnabled ?? this.dailyBriefingEnabled,
    );
  }
}

/// Controller managing notification settings preferences and permission prompts.
class NotificationSettingsController
    extends Notifier<NotificationSettingsState> {
  late final KeyValueStorage _storage;
  late final NotificationService _notificationService;
  Future<void>? _loadFuture;

  @override
  NotificationSettingsState build() {
    _storage = ref.watch(keyValueStorageProvider);
    _notificationService = ref.watch(notificationServiceProvider);
    _loadFuture = _loadPersistedSettings();
    return const NotificationSettingsState();
  }

  Future<void> _loadPersistedSettings() async {
    final severeStr =
        await _storage.getString(AppConstants.severeAlertsNotificationKey);
    final dailyStr =
        await _storage.getString(AppConstants.dailyBriefingNotificationKey);

    final severeEnabled = severeStr != 'false';
    final dailyEnabled = dailyStr != 'false';

    if (ref.mounted) {
      state = NotificationSettingsState(
        severeAlertsEnabled: severeEnabled,
        dailyBriefingEnabled: dailyEnabled,
      );
    }
  }

  /// Toggles severe weather alerts and requests permission if enabled.
  Future<void> setSevereAlertsEnabled({required bool enabled}) async {
    await _loadFuture;
    if (enabled) {
      final granted = await _notificationService.requestPermission();
      if (!granted) return;
    }

    state = state.copyWith(severeAlertsEnabled: enabled);
    await _storage.setString(
      AppConstants.severeAlertsNotificationKey,
      enabled.toString(),
    );
  }

  /// Toggles daily morning briefing and requests permission if enabled.
  Future<void> setDailyBriefingEnabled({required bool enabled}) async {
    await _loadFuture;
    if (enabled) {
      final granted = await _notificationService.requestPermission();
      if (!granted) return;
    }

    state = state.copyWith(dailyBriefingEnabled: enabled);
    await _storage.setString(
      AppConstants.dailyBriefingNotificationKey,
      enabled.toString(),
    );
  }
}

/// Global provider for [NotificationSettingsController].
final notificationSettingsControllerProvider = NotifierProvider<
    NotificationSettingsController, NotificationSettingsState>(
  NotificationSettingsController.new,
);

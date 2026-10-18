import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/storage/key_value_storage.dart';
import 'package:taqs/core/storage/storage_providers.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';
import 'package:taqs/features/prayer/domain/services/prayer_times_calculator.dart';

/// State model representing prayer settings, calculation preferences, and reminder toggles.
class PrayerSettingsState {
  const PrayerSettingsState({
    this.calculationMethod = CalculationMethodOption.egyptian,
    this.madhab = MadhabOption.shafi,
    this.adjustments = const PrayerAdjustments(),
    this.masterNotificationsEnabled = true,
    this.leadTimeMinutes = 5,
    this.enabledPrayers = const {
      PrayerType.fajr,
      PrayerType.dhuhr,
      PrayerType.asr,
      PrayerType.maghrib,
      PrayerType.isha,
    },
  });

  final CalculationMethodOption calculationMethod;
  final MadhabOption madhab;
  final PrayerAdjustments adjustments;
  final bool masterNotificationsEnabled;
  final int leadTimeMinutes;
  final Set<PrayerType> enabledPrayers;

  PrayerSettingsState copyWith({
    CalculationMethodOption? calculationMethod,
    MadhabOption? madhab,
    PrayerAdjustments? adjustments,
    bool? masterNotificationsEnabled,
    int? leadTimeMinutes,
    Set<PrayerType>? enabledPrayers,
  }) {
    return PrayerSettingsState(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      adjustments: adjustments ?? this.adjustments,
      masterNotificationsEnabled:
          masterNotificationsEnabled ?? this.masterNotificationsEnabled,
      leadTimeMinutes: leadTimeMinutes ?? this.leadTimeMinutes,
      enabledPrayers: enabledPrayers ?? this.enabledPrayers,
    );
  }
}

/// Controller managing user preferences for prayer calculation and reminder alerts.
class PrayerSettingsController extends Notifier<PrayerSettingsState> {
  late final KeyValueStorage _storage;

  @override
  PrayerSettingsState build() {
    _storage = ref.watch(keyValueStorageProvider);
    unawaited(_loadSettings());
    return const PrayerSettingsState();
  }

  Future<void> _loadSettings() async {
    final methodRaw =
        await _storage.getString(AppConstants.prayerCalculationMethodKey);
    final madhabRaw = await _storage.getString(AppConstants.prayerMadhabKey);
    final masterRaw =
        await _storage.getString(AppConstants.prayerNotificationMasterKey);
    final leadRaw =
        await _storage.getString(AppConstants.prayerLeadTimeKey);

    var method = CalculationMethodOption.egyptian;
    if (methodRaw != null) {
      method = CalculationMethodOption.values.firstWhere(
        (m) => m.name == methodRaw,
        orElse: () => CalculationMethodOption.egyptian,
      );
    }

    var madhab = MadhabOption.shafi;
    if (madhabRaw != null) {
      madhab = MadhabOption.values.firstWhere(
        (m) => m.name == madhabRaw,
        orElse: () => MadhabOption.shafi,
      );
    }

    final masterEnabled = masterRaw != 'false';
    final leadMinutes = int.tryParse(leadRaw ?? '') ?? 5;

    if (ref.mounted) {
      state = state.copyWith(
        calculationMethod: method,
        madhab: madhab,
        masterNotificationsEnabled: masterEnabled,
        leadTimeMinutes: leadMinutes,
      );
    }
  }

  /// Sets calculation method and persists choice.
  Future<void> setCalculationMethod(CalculationMethodOption method) async {
    state = state.copyWith(calculationMethod: method);
    await _storage.setString(
      AppConstants.prayerCalculationMethodKey,
      method.name,
    );
  }

  /// Sets Asr madhab and persists choice.
  Future<void> setMadhab(MadhabOption madhab) async {
    state = state.copyWith(madhab: madhab);
    await _storage.setString(
      AppConstants.prayerMadhabKey,
      madhab.name,
    );
  }

  /// Sets notification master toggle.
  Future<void> setMasterNotificationsEnabled({required bool enabled}) async {
    state = state.copyWith(masterNotificationsEnabled: enabled);
    await _storage.setString(
      AppConstants.prayerNotificationMasterKey,
      enabled.toString(),
    );
  }

  /// Sets lead time minutes before prayer (e.g. 0, 5, 10, 15).
  Future<void> setLeadTimeMinutes(int minutes) async {
    state = state.copyWith(leadTimeMinutes: minutes);
    await _storage.setString(
      AppConstants.prayerLeadTimeKey,
      minutes.toString(),
    );
  }

  /// Toggles individual prayer reminder.
  void togglePrayerReminder(PrayerType prayer, {required bool enabled}) {
    final updated = Set<PrayerType>.from(state.enabledPrayers);
    if (enabled) {
      updated.add(prayer);
    } else {
      updated.remove(prayer);
    }
    state = state.copyWith(enabledPrayers: updated);
  }

  /// Sets manual ±minute adjustments for prayers.
  void setAdjustments(PrayerAdjustments adjustments) {
    state = state.copyWith(adjustments: adjustments);
  }
}

/// Global provider for [PrayerSettingsController].
final prayerSettingsControllerProvider =
    NotifierProvider<PrayerSettingsController, PrayerSettingsState>(
  PrayerSettingsController.new,
);

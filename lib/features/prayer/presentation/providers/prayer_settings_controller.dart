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
    this.showTakbeeratCard = true,
    this.richNotificationCard = true,
    this.takbeeratSoundEnabled = false,
    this.eidModeEnabled = true,
    this.hijriDayAdjustment = 0,
  });

  final CalculationMethodOption calculationMethod;
  final MadhabOption madhab;
  final PrayerAdjustments adjustments;
  final bool masterNotificationsEnabled;
  final int leadTimeMinutes;
  final Set<PrayerType> enabledPrayers;

  /// Whether to display the pre-adhan/Eid takbeerat card in the prayer section.
  final bool showTakbeeratCard;

  /// Whether to schedule rich notifications containing the takbeerat card image.
  final bool richNotificationCard;

  /// Whether to play takbeerat sound on notification (requires android/app/src/main/res/raw/takbeerat.mp3).
  final bool takbeeratSoundEnabled;

  /// Whether to auto-enable Eid takbeerat during Eid al-Fitr and Eid al-Adha.
  final bool eidModeEnabled;

  /// Manual ±1 day adjustment to align calculated Hijri dates with official announcements.
  final int hijriDayAdjustment;

  PrayerSettingsState copyWith({
    CalculationMethodOption? calculationMethod,
    MadhabOption? madhab,
    PrayerAdjustments? adjustments,
    bool? masterNotificationsEnabled,
    int? leadTimeMinutes,
    Set<PrayerType>? enabledPrayers,
    bool? showTakbeeratCard,
    bool? richNotificationCard,
    bool? takbeeratSoundEnabled,
    bool? eidModeEnabled,
    int? hijriDayAdjustment,
  }) {
    return PrayerSettingsState(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      adjustments: adjustments ?? this.adjustments,
      masterNotificationsEnabled:
          masterNotificationsEnabled ?? this.masterNotificationsEnabled,
      leadTimeMinutes: leadTimeMinutes ?? this.leadTimeMinutes,
      enabledPrayers: enabledPrayers ?? this.enabledPrayers,
      showTakbeeratCard: showTakbeeratCard ?? this.showTakbeeratCard,
      richNotificationCard: richNotificationCard ?? this.richNotificationCard,
      takbeeratSoundEnabled:
          takbeeratSoundEnabled ?? this.takbeeratSoundEnabled,
      eidModeEnabled: eidModeEnabled ?? this.eidModeEnabled,
      hijriDayAdjustment: hijriDayAdjustment ?? this.hijriDayAdjustment,
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
    final takbeeratCardRaw =
        await _storage.getString(AppConstants.takbeeratCardKey);
    final takbeeratRichNotifRaw =
        await _storage.getString(AppConstants.takbeeratRichNotifKey);
    final takbeeratSoundRaw =
        await _storage.getString(AppConstants.takbeeratSoundKey);
    final eidModeRaw =
        await _storage.getString(AppConstants.eidModeKey);
    final hijriAdjRaw =
        await _storage.getString(AppConstants.hijriDayAdjustmentKey);

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
    final showCard = takbeeratCardRaw != 'false';
    final richNotif = takbeeratRichNotifRaw != 'false';
    final soundEnabled = takbeeratSoundRaw == 'true';
    final eidMode = eidModeRaw != 'false';
    final hijriAdj = int.tryParse(hijriAdjRaw ?? '') ?? 0;

    if (ref.mounted) {
      state = state.copyWith(
        calculationMethod: method,
        madhab: madhab,
        masterNotificationsEnabled: masterEnabled,
        leadTimeMinutes: leadMinutes,
        showTakbeeratCard: showCard,
        richNotificationCard: richNotif,
        takbeeratSoundEnabled: soundEnabled,
        eidModeEnabled: eidMode,
        hijriDayAdjustment: hijriAdj,
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

  /// Toggles whether takbeerat card appears in the prayer section.
  Future<void> setShowTakbeeratCard({required bool enabled}) async {
    state = state.copyWith(showTakbeeratCard: enabled);
    await _storage.setString(
      AppConstants.takbeeratCardKey,
      enabled.toString(),
    );
  }

  /// Toggles rich notifications with pre-rendered card image.
  Future<void> setRichNotificationCard({required bool enabled}) async {
    state = state.copyWith(richNotificationCard: enabled);
    await _storage.setString(
      AppConstants.takbeeratRichNotifKey,
      enabled.toString(),
    );
  }

  /// Toggles custom takbeerat notification sound.
  Future<void> setTakbeeratSoundEnabled({required bool enabled}) async {
    state = state.copyWith(takbeeratSoundEnabled: enabled);
    await _storage.setString(
      AppConstants.takbeeratSoundKey,
      enabled.toString(),
    );
  }

  /// Toggles Eid mode auto-takbeerat display.
  Future<void> setEidModeEnabled({required bool enabled}) async {
    state = state.copyWith(eidModeEnabled: enabled);
    await _storage.setString(
      AppConstants.eidModeKey,
      enabled.toString(),
    );
  }

  /// Sets manual ±1 day adjustment for Hijri calendar calculations.
  Future<void> setHijriDayAdjustment(int adjustment) async {
    state = state.copyWith(hijriDayAdjustment: adjustment);
    await _storage.setString(
      AppConstants.hijriDayAdjustmentKey,
      adjustment.toString(),
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

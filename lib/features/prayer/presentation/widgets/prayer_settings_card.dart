import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/core/notifications/notification_service.dart';
import 'package:taqs/core/notifications/prayer_notification_scheduler.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';
import 'package:taqs/features/prayer/domain/services/prayer_times_calculator.dart';
import 'package:taqs/features/prayer/presentation/providers/prayer_settings_controller.dart';

/// Comprehensive settings card for prayer calculation methods, madhab, manual adjustments,
/// pre-prayer reminder lead time, and Android exact-alarm status.
class PrayerSettingsCard extends ConsumerStatefulWidget {
  const PrayerSettingsCard({
    required this.isArabic,
    super.key,
  });

  final bool isArabic;

  @override
  ConsumerState<PrayerSettingsCard> createState() => _PrayerSettingsCardState();
}

class _PrayerSettingsCardState extends ConsumerState<PrayerSettingsCard> {
  bool? _exactAlarmsAllowed;

  @override
  void initState() {
    super.initState();
    unawaited(_checkExactAlarmStatus());
  }

  Future<void> _checkExactAlarmStatus() async {
    try {
      final allowed =
          await ref.read(notificationServiceProvider).canScheduleExactAlarms();
      if (mounted) {
        setState(() {
          _exactAlarmsAllowed = allowed;
        });
      }
    } on Object catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(prayerSettingsControllerProvider);
    final controller = ref.read(prayerSettingsControllerProvider.notifier);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.metallicGold.withValues(alpha: 0.15),
                  borderRadius: AppRadius.borderMd,
                ),
                child: const Icon(
                  Icons.mosque_outlined,
                  color: AppColors.metallicGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  widget.isArabic
                      ? 'إعدادات مواقيت الصلاة والأذان'
                      : 'Prayer Times & Adhan Settings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Master Reminder Toggle
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.metallicGold,
            title: Text(
              widget.isArabic
                  ? 'تنبيهات مواقيت الصلاة'
                  : 'Prayer Time Reminders',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              widget.isArabic
                  ? 'إشعار تذكير قبل كل صلاة بـ ${settings.leadTimeMinutes} دقائق'
                  : 'Reminder notification ${settings.leadTimeMinutes} mins before each prayer',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            value: settings.masterNotificationsEnabled,
            onChanged: (val) async {
              unawaited(HapticFeedback.selectionClick());
              await controller.setMasterNotificationsEnabled(enabled: val);
              await _rescheduleNotifications();
            },
          ),

          if (settings.masterNotificationsEnabled) ...[
            const Divider(height: AppSpacing.lg),

            // Lead Time Selection
            Text(
              widget.isArabic ? 'وقت التنبيه المسبق' : 'Reminder Lead Time',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              children: [0, 5, 10, 15].map((mins) {
                final isSelected = settings.leadTimeMinutes == mins;
                return ChoiceChip(
                  label: Text(
                    widget.isArabic
                        ? (mins == 0 ? 'عند الأذان' : '$mins دقائق')
                        : (mins == 0 ? 'At adhan' : '$mins min'),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.metallicGold.withValues(alpha: 0.25),
                  checkmarkColor: AppColors.metallicGold,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.metallicGold
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                  ),
                  onSelected: (selected) async {
                    if (selected) {
                      unawaited(HapticFeedback.selectionClick());
                      await controller.setLeadTimeMinutes(mins);
                      await _rescheduleNotifications();
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.md),

            // Per-Prayer Toggles
            Text(
              widget.isArabic
                  ? 'الصلوات المفعلة للتنبيه'
                  : 'Enabled Prayers for Reminders',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: PrayerType.values.map((prayer) {
                final isEnabled = settings.enabledPrayers.contains(prayer);
                final label = widget.isArabic
                    ? prayer.nameAr()
                    : prayer.nameEn();
                return FilterChip(
                  label: Text(label),
                  selected: isEnabled,
                  selectedColor: AppColors.metallicGold.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.metallicGold,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    color: isEnabled
                        ? AppColors.metallicGold
                        : (isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted),
                  ),
                  onSelected: (selected) async {
                    unawaited(HapticFeedback.selectionClick());
                    controller.togglePrayerReminder(prayer, enabled: selected);
                    await _rescheduleNotifications();
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.md),

            // Exact Alarm Permission Status
            _buildExactAlarmStatusBanner(isDark),
          ],

          const Divider(height: AppSpacing.xl),

          // Calculation Method Dropdown
          Text(
            widget.isArabic ? 'طريقة الحساب الفلكي' : 'Calculation Method',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<CalculationMethodOption>(
            initialValue: settings.calculationMethod,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                ),
              ),
            ),
            items: CalculationMethodOption.values.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(
                  widget.isArabic ? method.nameAr() : method.nameEn(),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
            onChanged: (method) async {
              if (method != null) {
                unawaited(HapticFeedback.selectionClick());
                await controller.setCalculationMethod(method);
                await _rescheduleNotifications();
              }
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Madhab Dropdown
          Text(
            widget.isArabic ? 'مذهب صلاة العصر' : 'Asr Juristic Madhab',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<MadhabOption>(
            initialValue: settings.madhab,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                ),
              ),
            ),
            items: MadhabOption.values.map((madhab) {
              return DropdownMenuItem(
                value: madhab,
                child: Text(
                  widget.isArabic ? madhab.nameAr() : madhab.nameEn(),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
            onChanged: (madhab) async {
              if (madhab != null) {
                unawaited(HapticFeedback.selectionClick());
                await controller.setMadhab(madhab);
                await _rescheduleNotifications();
              }
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Action Buttons: Manual Adjustments & Test Prayer Notification
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                  ),
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: Text(
                    widget.isArabic ? 'تعديل الدقائق' : '± Adjustments',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () => _showManualAdjustmentsSheet(context),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    side: const BorderSide(color: AppColors.metallicGold),
                    foregroundColor: AppColors.metallicGold,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                  ),
                  icon: const Icon(Icons.notifications_active_outlined, size: 16),
                  label: Text(
                    widget.isArabic ? 'تجربة التنبيه' : 'Test Reminder',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () async {
                    unawaited(HapticFeedback.lightImpact());
                    await ref
                        .read(notificationServiceProvider)
                        .showTestPrayerNotification(
                          isArabic: widget.isArabic,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.isArabic
                                ? 'تم إرسال تنبيه تجريبي للأذان'
                                : 'Test prayer reminder sent',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Honest Mosque Verification Disclaimer
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceHover.withValues(alpha: 0.3)
                  : AppColors.lightSurfaceElevated,
              borderRadius: AppRadius.borderSm,
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorderSubtle
                    : AppColors.lightBorderSubtle,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppColors.metallicGold,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    widget.isArabic
                        ? 'ملاحظة: المواقيت محسوبة فلكياً وفقاً لموقعك. يُرجى مراجعة المسجد المحلي في مدينتك للتأكد.'
                        : 'Note: Times are calculated astronomically for your coordinates. Please verify with your local mosque timetable.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExactAlarmStatusBanner(bool isDark) {
    final allowed = _exactAlarmsAllowed ?? true;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: allowed
            ? (isDark
                ? AppColors.cyanAccent.withValues(alpha: 0.08)
                : AppColors.lightSurfaceElevated)
            : AppColors.alertRed.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: allowed
              ? (isDark
                  ? AppColors.cyanAccent.withValues(alpha: 0.3)
                  : AppColors.lightBorderSubtle)
              : AppColors.alertRed.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allowed ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                size: 16,
                color: allowed ? AppColors.cyanAccent : AppColors.alertRed,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  allowed
                      ? (widget.isArabic
                          ? 'المنبهات الدقيقة مفعلة بنجاح'
                          : 'Exact Alarms Active')
                      : (widget.isArabic
                          ? 'إذن المنبهات الدقيقة غير مفعل'
                          : 'Exact Alarm Permission Missing'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: allowed
                        ? AppColors.cyanAccent
                        : AppColors.alertRed,
                  ),
                ),
              ),
              if (!allowed)
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () async {
                    await ref
                        .read(notificationServiceProvider)
                        .requestExactAlarmsPermission();
                    await _checkExactAlarmStatus();
                  },
                  child: Text(
                    widget.isArabic ? 'تفعيل الإذن' : 'Grant',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.alertRed,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            allowed
                ? (widget.isArabic
                    ? 'ستصل التنبيهات بدقة في الوقت المحدد دون تأخير نظام توفير الطاقة.'
                    : 'Reminders will trigger accurately without battery optimization delays.')
                : (widget.isArabic
                    ? 'في حالة عدم تفعيل الإذن، سيتم استخدام جدولة تقريبية متوافقة مع بطارية أندرويد.'
                    : 'Without exact alarm permission, Taqs gracefully falls back to inexact scheduling.'),
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rescheduleNotifications() async {
    await triggerPrayerNotificationReschedule(
      ref,
      isArabic: widget.isArabic,
    );
  }

  void _showManualAdjustmentsSheet(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => _ManualAdjustmentsSheet(isArabic: widget.isArabic),
      ),
    );
  }
}

class _ManualAdjustmentsSheet extends ConsumerWidget {
  const _ManualAdjustmentsSheet({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(prayerSettingsControllerProvider);
    final controller = ref.read(prayerSettingsControllerProvider.notifier);
    final adj = settings.adjustments;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'تعديل أوقات الصلاة يدوياً' : 'Manual Time Adjustments',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Text(
            isArabic
                ? 'يمكنك إضافة أو خصم دقائق لمطابقة مواقيت المسجد في حيك:'
                : 'Add or subtract minutes to match your neighborhood mosque timetable:',
            style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildAdjustmentStepper(
            label: isArabic ? 'الفجر' : 'Fajr',
            currentValue: adj.fajr,
            onChanged: (val) {
              controller.setAdjustments(
                PrayerAdjustments(
                  fajr: val,
                  sunrise: adj.sunrise,
                  dhuhr: adj.dhuhr,
                  asr: adj.asr,
                  maghrib: adj.maghrib,
                  isha: adj.isha,
                ),
              );
            },
          ),
          _buildAdjustmentStepper(
            label: isArabic ? 'الشروق' : 'Sunrise',
            currentValue: adj.sunrise,
            onChanged: (val) {
              controller.setAdjustments(
                PrayerAdjustments(
                  fajr: adj.fajr,
                  sunrise: val,
                  dhuhr: adj.dhuhr,
                  asr: adj.asr,
                  maghrib: adj.maghrib,
                  isha: adj.isha,
                ),
              );
            },
          ),
          _buildAdjustmentStepper(
            label: isArabic ? 'الظهر' : 'Dhuhr',
            currentValue: adj.dhuhr,
            onChanged: (val) {
              controller.setAdjustments(
                PrayerAdjustments(
                  fajr: adj.fajr,
                  sunrise: adj.sunrise,
                  dhuhr: val,
                  asr: adj.asr,
                  maghrib: adj.maghrib,
                  isha: adj.isha,
                ),
              );
            },
          ),
          _buildAdjustmentStepper(
            label: isArabic ? 'العصر' : 'Asr',
            currentValue: adj.asr,
            onChanged: (val) {
              controller.setAdjustments(
                PrayerAdjustments(
                  fajr: adj.fajr,
                  sunrise: adj.sunrise,
                  dhuhr: adj.dhuhr,
                  asr: val,
                  maghrib: adj.maghrib,
                  isha: adj.isha,
                ),
              );
            },
          ),
          _buildAdjustmentStepper(
            label: isArabic ? 'المغرب' : 'Maghrib',
            currentValue: adj.maghrib,
            onChanged: (val) {
              controller.setAdjustments(
                PrayerAdjustments(
                  fajr: adj.fajr,
                  sunrise: adj.sunrise,
                  dhuhr: adj.dhuhr,
                  asr: adj.asr,
                  maghrib: val,
                  isha: adj.isha,
                ),
              );
            },
          ),
          _buildAdjustmentStepper(
            label: isArabic ? 'العشاء' : 'Isha',
            currentValue: adj.isha,
            onChanged: (val) {
              controller.setAdjustments(
                PrayerAdjustments(
                  fajr: adj.fajr,
                  sunrise: adj.sunrise,
                  dhuhr: adj.dhuhr,
                  asr: adj.asr,
                  maghrib: adj.maghrib,
                  isha: val,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentStepper({
    required String label,
    required int currentValue,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () => onChanged(currentValue - 1),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 44),
                alignment: Alignment.center,
                child: Text(
                  currentValue > 0 ? '+$currentValue د' : '$currentValue د',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => onChanged(currentValue + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

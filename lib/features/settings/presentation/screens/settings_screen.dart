import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/components/section_header.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/core/localization/locale_controller.dart';
import 'package:taqs/core/navigation/app_routes.dart';
import 'package:taqs/core/notifications/notification_service.dart';
import 'package:taqs/core/notifications/notification_settings_controller.dart';
import 'package:taqs/core/theme/theme_controller.dart';
import 'package:taqs/features/prayer/presentation/widgets/prayer_settings_card.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/presentation/providers/weather_provider.dart';
import 'package:taqs/features/weather/presentation/widgets/farmer_mode_card.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Settings screen managing theme preferences, language, and app information.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentThemeMode = ref.watch(themeControllerProvider);
    final currentLocale = ref.watch(localeControllerProvider);
    final isArabic = currentLocale.languageCode == 'ar';
    final notificationSettings =
        ref.watch(notificationSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            children: [
              // --- Appearance Section ---
              SectionHeader(title: l10n.appearanceSection),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.palette_outlined,
                          size: 20,
                          color: AppColors.cyanAccent,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          l10n.themeMode,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.system,
                            icon: const Icon(Icons.brightness_auto, size: 16),
                            label: Text(l10n.themeSystem),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            icon: const Icon(Icons.light_mode, size: 16),
                            label: Text(l10n.themeLight),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            icon: const Icon(Icons.dark_mode, size: 16),
                            label: Text(l10n.themeDark),
                          ),
                        ],
                        selected: {currentThemeMode},
                        onSelectionChanged: (selected) {
                          unawaited(
                            ref
                                .read(themeControllerProvider.notifier)
                                .setThemeMode(selected.first),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // --- Language Section ---
              SectionHeader(title: l10n.languageSection),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.language_rounded,
                          size: 20,
                          color: AppColors.electricBlue,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          l10n.language,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _LanguageOptionTile(
                      title: l10n.languageArabic,
                      isSelected: currentLocale.languageCode == 'ar',
                      onTap: () {
                        unawaited(
                          ref
                              .read(localeControllerProvider.notifier)
                              .setLocale(AppLocales.arabic),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LanguageOptionTile(
                      title: l10n.languageEnglish,
                      isSelected: currentLocale.languageCode == 'en',
                      onTap: () {
                        unawaited(
                          ref
                              .read(localeControllerProvider.notifier)
                              .setLocale(AppLocales.english),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // --- Notifications Section ---
              SectionHeader(title: l10n.notificationsSection),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                child: Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        secondary: Container(
                          padding: const EdgeInsets.all(AppSpacing.xs + 2),
                          decoration: BoxDecoration(
                            color: AppColors.metallicGold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            size: 20,
                            color: AppColors.metallicGold,
                          ),
                        ),
                        title: Text(
                          l10n.severeAlertsToggle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          l10n.severeAlertsSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        activeTrackColor: AppColors.cyanAccent,
                        activeThumbColor: Colors.black,
                        value: notificationSettings.severeAlertsEnabled,
                        onChanged: (val) {
                          unawaited(
                            ref
                                .read(
                                  notificationSettingsControllerProvider.notifier,
                                )
                                .setSevereAlertsEnabled(enabled: val),
                          );
                        },
                      ),
                    ),
                    const Divider(height: AppSpacing.md),
                    Material(
                      color: Colors.transparent,
                      child: SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        secondary: Container(
                          padding: const EdgeInsets.all(AppSpacing.xs + 2),
                          decoration: BoxDecoration(
                            color: AppColors.cyanAccent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wb_sunny_outlined,
                            size: 20,
                            color: AppColors.cyanAccent,
                          ),
                        ),
                        title: Text(
                          l10n.dailyBriefingToggle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          l10n.dailyBriefingSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        activeTrackColor: AppColors.cyanAccent,
                        activeThumbColor: Colors.black,
                        value: notificationSettings.dailyBriefingEnabled,
                        onChanged: (val) {
                          unawaited(
                            ref
                                .read(
                                  notificationSettingsControllerProvider.notifier,
                                )
                                .setDailyBriefingEnabled(enabled: val),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        side: const BorderSide(color: AppColors.cyanAccent),
                        foregroundColor: AppColors.cyanAccent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd,
                        ),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: Text(
                        isArabic
                            ? 'إرسال إشعار تجريبي الآن'
                            : 'Send test notification now',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: () async {
                        unawaited(HapticFeedback.lightImpact());
                        final weather =
                            ref.read(weatherViewModelProvider).value;
                        final current = weather?.current ??
                            const CurrentWeather(
                              temperature: 28,
                              feelsLike: 29,
                              cityNameAr: 'القاهرة',
                              cityNameEn: 'Cairo',
                              condition: WeatherCondition.sunny,
                              humidityPercentage: 45,
                              windSpeedKmh: 18,
                              uvIndex: 6,
                            );
                        await ref
                            .read(notificationServiceProvider)
                            .showDailyBriefingNotification(
                              current,
                              isArabic: isArabic,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isArabic
                                    ? 'تم إرسال إشعار تجريبي بنجاح'
                                    : 'Test notification sent successfully',
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm + 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceHover.withValues(alpha: 0.4)
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
                            size: 16,
                            color: AppColors.cyanAccent,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              isArabic
                                  ? 'تنويه: توقيت الإشعارات في الخلفية يخضع لتحسينات بطارية أندرويد (Doze Mode) وقيود نظام iOS لتوفير الطاقة.'
                                  : 'Note: Background notification timing is approximate due to Android Doze optimizations and iOS background execution limits.',
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
              ),
              const SizedBox(height: AppSpacing.xl),

              // --- Prayer Times & Reminders Section ---
              SectionHeader(
                title: isArabic
                    ? 'مواقيت الصلاة والتنبيهات'
                    : 'Prayer Times & Reminders',
              ),
              const SizedBox(height: AppSpacing.xs),
              PrayerSettingsCard(isArabic: isArabic),
              const SizedBox(height: AppSpacing.xl),

              // --- Smart Modes: Farmer Mode ---
              SectionHeader(
                title: isArabic ? 'الأنماط الذكية' : 'Smart Modes',
              ),
              const SizedBox(height: AppSpacing.xs),
              FarmerModeCard(isArabic: isArabic),
              const SizedBox(height: AppSpacing.xl),

              // --- About Section ---
              SectionHeader(title: l10n.aboutSection),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                onTap: () => context.push(AppRoutes.about),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: const Icon(
                        Icons.person_pin_circle_outlined,
                        color: AppColors.cyanAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.aboutDeveloper,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.aboutDeveloperSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.darkTextMuted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // --- Weather Data Attribution Section ---
              SectionHeader(title: l10n.openMeteoAttribution),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_sync_outlined,
                      color: AppColors.cyanAccent,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.openMeteoAttribution,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'https://open-meteo.com',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppColors.electricBlue.withValues(alpha: 0.15)
                    : AppColors.electricBlue.withValues(alpha: 0.08))
                : Colors.transparent,
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: isSelected
                  ? AppColors.electricBlue
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark
                          ? AppColors.cyanAccent
                          : AppColors.electricBlue)
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: AppColors.cyanAccent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

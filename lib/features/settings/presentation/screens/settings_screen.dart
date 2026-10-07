import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/components/section_header.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/core/localization/locale_controller.dart';
import 'package:taqs/core/navigation/app_routes.dart';
import 'package:taqs/core/theme/theme_controller.dart';
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

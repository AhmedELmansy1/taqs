import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/core/design/typography/app_typography.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/presentation/widgets/weather_artwork.dart';
import 'package:taqs/features/weather/presentation/widgets/weather_condition_helper.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Luxury Hero Weather presentation showcasing custom-painted weather artwork,
/// massive tabular temperature typography, gold-accented feels-like metric,
/// and quick-tap location switcher.
class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({
    required this.weather,
    required this.isArabic,
    this.onLocationTap,
    super.key,
  });

  final CurrentWeather weather;
  final bool isArabic;
  final VoidCallback? onLocationTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cityName = isArabic ? weather.cityNameAr : weather.cityNameEn;
    final conditionName =
        WeatherConditionHelper.getLocalizedName(context, weather.condition);
    final conditionIcon =
        WeatherConditionHelper.getIcon(weather.condition);
    final conditionColor =
        WeatherConditionHelper.getIconColor(weather.condition);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      borderRadius: AppRadius.borderXl,
      child: Column(
        children: [
          // 1. Location Bar with Tap-to-Change Affordance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  unawaited(HapticFeedback.selectionClick());
                  onLocationTap?.call();
                },
                borderRadius: AppRadius.borderPill,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceHover.withValues(alpha: 0.5)
                        : AppColors.lightSurfaceElevated,
                    borderRadius: AppRadius.borderPill,
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.cyanAccent,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        cityName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ],
                  ),
                ),
              ),

              // Weather condition badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: conditionColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderPill,
                  border: Border.all(
                    color: conditionColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(conditionIcon, size: 14, color: conditionColor),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      conditionName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // 2. Weather Artwork & Huge Tabular Temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Custom-painted animated weather illustration
              WeatherArtwork(
                condition: weather.condition,
                isDay: weather.isDay,
                size: 116,
              ),

              const SizedBox(width: AppSpacing.lg),

              // Huge Temperature Figures
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${weather.temperature}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 84,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -3,
                      height: 1,
                      fontFeatures: AppTypography.tabularFigures,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const Text(
                    '°',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 44,
                      fontWeight: FontWeight.w300,
                      color: AppColors.cyanAccent,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 3. Metallic Gold "Feels Like" Highlight Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.metallicGold.withValues(alpha: 0.16),
                  AppColors.metallicGoldLight.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: AppRadius.borderPill,
              border: Border.all(
                color: AppColors.metallicGold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.thermostat_rounded,
                  size: 16,
                  color: AppColors.metallicGoldLight,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.feelsLike(weather.feelsLike),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFF92400E),
                    fontWeight: FontWeight.w700,
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

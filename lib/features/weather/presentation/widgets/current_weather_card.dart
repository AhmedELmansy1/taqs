import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/presentation/widgets/weather_condition_helper.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Hero temperature card displaying current real-time meteorological metrics.
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
      padding: const EdgeInsets.all(AppSpacing.xl),
      backgroundColor: isDark
          ? AppColors.darkSurfaceElevated
          : Colors.white,
      borderColor: isDark
          ? AppColors.darkBorder
          : AppColors.lightBorder,
      child: Column(
        children: [
          // Location & Date Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onLocationTap,
                borderRadius: AppRadius.borderSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs,
                    horizontal: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
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
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderPill,
                ),
                child: Row(
                  children: [
                    Icon(conditionIcon, size: 14, color: conditionColor),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      conditionName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
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
          const SizedBox(height: AppSpacing.xl),

          // Main Temperature & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather.temperature}',
                style: const TextStyle(
                  fontSize: 76,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              const Text(
                '°',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: AppColors.cyanAccent,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(
                  conditionIcon,
                  size: 64,
                  color: conditionColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Feels Like
          Text(
            l10n.feelsLike(weather.feelsLike),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Metrics Grid (Humidity, Wind, UV, Air Quality)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem(
                icon: Icons.water_drop_outlined,
                iconColor: AppColors.cyanAccent,
                label: l10n.humidity,
                value: '${weather.humidityPercentage}%',
              ),
              _MetricItem(
                icon: Icons.air_rounded,
                iconColor: AppColors.electricBlue,
                label: l10n.windSpeed,
                value: l10n.windSpeedUnit(weather.windSpeedKmh),
              ),
              _MetricItem(
                icon: Icons.wb_sunny_outlined,
                iconColor: AppColors.metallicGold,
                label: l10n.uvIndex,
                value: '${weather.uvIndex}',
              ),
              _MetricItem(
                icon: Icons.eco_outlined,
                iconColor: AppColors.cyanAccent,
                label: l10n.airQuality,
                value: l10n.airQualityGood,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

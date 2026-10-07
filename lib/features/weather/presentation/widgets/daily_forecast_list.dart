import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/presentation/widgets/weather_condition_helper.dart';

/// 7-day weather forecast list widget.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    required this.daily,
    required this.isArabic,
    super.key,
  });

  final List<DailyForecast> daily;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: daily.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _DailyForecastTile(item: item, isArabic: isArabic),
        );
      }).toList(),
    );
  }
}

class _DailyForecastTile extends StatelessWidget {
  const _DailyForecastTile({
    required this.item,
    required this.isArabic,
  });

  final DailyForecast item;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dayName = isArabic ? item.dayNameAr : item.dayNameEn;
    final conditionName =
        WeatherConditionHelper.getLocalizedName(context, item.condition);
    final icon = WeatherConditionHelper.getIcon(item.condition);
    final iconColor = WeatherConditionHelper.getIconColor(item.condition);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      borderRadius: AppRadius.borderMd,
      child: Row(
        children: [
          // Day Name
          SizedBox(
            width: 80,
            child: Text(
              dayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
          // Condition Icon & Label
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    conditionName,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Temperature Range (Min / Max)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${item.minTemp}°',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '/',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${item.maxTemp}°',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.cyanAccent
                      : AppColors.electricBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

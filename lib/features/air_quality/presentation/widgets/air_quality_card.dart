import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/air_quality/domain/entities/air_quality.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Presentation card displaying atmospheric air quality and particulate metrics.
class AirQualityCard extends StatelessWidget {
  const AirQualityCard({
    required this.airQuality,
    required this.isArabic,
    super.key,
  });

  final AirQuality airQuality;
  final bool isArabic;

  Color _getLevelColor(AirQualityLevel level) {
    switch (level) {
      case AirQualityLevel.good:
      case AirQualityLevel.fair:
        return AppColors.cyanAccent;
      case AirQualityLevel.moderate:
        return AppColors.metallicGold;
      case AirQualityLevel.poor:
      case AirQualityLevel.veryPoor:
        return AppColors.alertRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final levelName =
        isArabic ? airQuality.localizedLevelAr : airQuality.localizedLevelEn;
    final healthAdvice =
        isArabic ? airQuality.healthAdviceAr : airQuality.healthAdviceEn;
    final levelColor = _getLevelColor(airQuality.level);

    return AppCard(
      backgroundColor: isDark
          ? AppColors.darkSurfaceElevated
          : Colors.white,
      borderColor: isDark
          ? AppColors.darkBorder
          : AppColors.lightBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.air_rounded,
                    color: AppColors.cyanAccent,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    l10n.airQuality,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.15),
                  borderRadius: AppRadius.borderPill,
                  border: Border.all(
                    color: levelColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  levelName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: levelColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Main Metric Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${airQuality.europeanAqi}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'EAQI',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Particulate breakdown metrics
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground.withValues(alpha: 0.5)
                  : AppColors.lightBackground,
              borderRadius: AppRadius.borderMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MetricItem(
                  label: 'PM2.5',
                  value: '${airQuality.pm2_5.toStringAsFixed(1)} µg',
                  isDark: isDark,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                _MetricItem(
                  label: 'PM10',
                  value: '${airQuality.pm10.toStringAsFixed(1)} µg',
                  isDark: isDark,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                _MetricItem(
                  label: isArabic ? 'الغبار' : 'Dust',
                  value: '${airQuality.dust.toStringAsFixed(1)} µg',
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Health recommendation hint
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.health_and_safety_outlined,
                size: 16,
                color: AppColors.cyanAccent,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  healthAdvice,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
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
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isDark
                ? AppColors.darkTextMuted
                : AppColors.lightTextMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}

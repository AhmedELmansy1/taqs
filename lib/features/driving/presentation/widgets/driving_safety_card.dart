import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/driving/domain/services/driving_safety_evaluator.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// Card presenting deterministic road conditions and safety advice for drivers.
class DrivingSafetyCard extends StatelessWidget {
  const DrivingSafetyCard({
    required this.weather,
    required this.isArabic,
    super.key,
  });

  final CurrentWeather weather;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final report = DrivingSafetyEvaluator.evaluate(weather);

    final (badgeColor, badgeTextColor) = switch (report.level) {
      RoadSafetyLevel.good => (
          AppColors.cyanAccent.withValues(alpha: 0.15),
          AppColors.cyanAccent,
        ),
      RoadSafetyLevel.caution => (
          AppColors.metallicGold.withValues(alpha: 0.2),
          AppColors.metallicGold,
        ),
      RoadSafetyLevel.hazardous => (
          const Color(0xFFFB8C00).withValues(alpha: 0.2),
          const Color(0xFFFFB74D),
        ),
      RoadSafetyLevel.extremeRisk => (
          AppColors.alertRed.withValues(alpha: 0.2),
          AppColors.alertRed,
        ),
    };

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
                  color: badgeColor,
                  borderRadius: AppRadius.borderMd,
                ),
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: badgeTextColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isArabic ? 'مؤشر أمان القيادة' : 'Road Driving Safety',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: AppRadius.borderPill,
                ),
                child: Text(
                  isArabic ? report.level.labelAr() : report.level.labelEn(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Headline & Tip
          Text(
            isArabic ? report.headlineAr : report.headlineEn,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isArabic ? report.tipAr : report.tipEn,
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 3 Metric Pills
          Row(
            children: [
              Expanded(
                child: _buildMetricPill(
                  label: isArabic ? 'الرؤية' : 'Visibility',
                  value: '${weather.visibilityKm.toStringAsFixed(1)} km',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _buildMetricPill(
                  label: isArabic ? 'الرياح' : 'Wind',
                  value: '${weather.windSpeedKmh} km/h',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _buildMetricPill(
                  label: isArabic ? 'الأمطار' : 'Rain',
                  value: '${weather.precipitationProbability}%',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: isDark
              ? AppColors.darkBorderSubtle
              : AppColors.lightBorderSubtle,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

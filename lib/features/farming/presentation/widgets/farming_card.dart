import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/farming/domain/services/farming_evaluator.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// Card presenting agricultural metrics, frost warning, and irrigation advice.
class FarmingCard extends StatelessWidget {
  const FarmingCard({
    required this.bundle,
    required this.isArabic,
    super.key,
  });

  final WeatherBundle bundle;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final report = FarmingEvaluator.evaluate(bundle);

    final (frostColor, frostTextColor) = switch (report.frostRisk) {
      FrostRiskLevel.none => (
          const Color(0xFF2E7D32).withValues(alpha: 0.2),
          const Color(0xFF4CAF50),
        ),
      FrostRiskLevel.moderate => (
          AppColors.metallicGold.withValues(alpha: 0.2),
          AppColors.metallicGold,
        ),
      FrostRiskLevel.high => (
          AppColors.alertRed.withValues(alpha: 0.2),
          AppColors.alertRed,
        ),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Plant Icon & Frost Risk Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                  borderRadius: AppRadius.borderMd,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isArabic ? 'الوضع الزراعي ومؤشرات الري' : 'Agricultural & Crop Mode',
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
                  color: frostColor,
                  borderRadius: AppRadius.borderPill,
                ),
                child: Text(
                  isArabic ? report.frostRisk.labelAr() : report.frostRisk.labelEn(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: frostTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Crop Protection Advice
          Text(
            isArabic ? report.cropProtectionTipAr : report.cropProtectionTipEn,
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 4 Metric Tiles
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: isArabic ? 'البخر اليومي (ET0)' : 'Daily ET0',
                  value: isArabic
                      ? '${report.referenceEt0Mm} ملم'
                      : '${report.referenceEt0Mm} mm',
                  icon: Icons.water_drop_outlined,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMetricTile(
                  title: isArabic ? 'حرارة التربة (0-7 سم)' : 'Soil Temp (0-7cm)',
                  value: '${report.estimatedSoilTempC}°C',
                  icon: Icons.thermostat_rounded,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: isArabic ? 'رطوبة التربة المقدرة' : 'Soil Moisture',
                  value: '${report.estimatedSoilMoisturePercent}%',
                  icon: Icons.grass_rounded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMetricTile(
                  title: isArabic ? 'توقعات المطر' : 'Rain Outlook',
                  value: isArabic
                      ? (report.rainExpectedSoon ? 'أمطار قادمة' : 'طقس جاف')
                      : (report.rainExpectedSoon ? 'Rain Expected' : 'Dry Spell'),
                  icon: Icons.cloud_outlined,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Irrigation Advice Note
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
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
                  Icons.tips_and_updates_outlined,
                  size: 15,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    isArabic
                        ? report.irrigationAdviceAr
                        : report.irrigationAdviceEn,
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

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isDark
              ? AppColors.darkBorderSubtle
              : AppColors.lightBorderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF4CAF50)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

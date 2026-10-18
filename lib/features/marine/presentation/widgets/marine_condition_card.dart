import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/marine/domain/entities/marine_conditions.dart';

/// Presentation card displaying sea and wave conditions for coastal locations.
class MarineConditionCard extends StatelessWidget {
  const MarineConditionCard({
    required this.marine,
    required this.isArabic,
    super.key,
  });

  final MarineConditions marine;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rating = marine.rating;

    final (badgeColor, badgeTextColor) = switch (rating) {
      SeaStateRating.calm => (
          AppColors.cyanAccent.withValues(alpha: 0.15),
          AppColors.cyanAccent,
        ),
      SeaStateRating.moderate => (
          AppColors.electricBlue.withValues(alpha: 0.18),
          AppColors.cyanAccent,
        ),
      SeaStateRating.rough => (
          AppColors.metallicGold.withValues(alpha: 0.2),
          AppColors.metallicGold,
        ),
      SeaStateRating.dangerous => (
          AppColors.alertRed.withValues(alpha: 0.2),
          AppColors.alertRed,
        ),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Icon & Rating Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.cyanAccent.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderMd,
                ),
                child: const Icon(
                  Icons.surfing_rounded,
                  color: AppColors.cyanAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isArabic ? 'حالة البحر والأمواج' : 'Marine & Sea State',
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
                  isArabic ? rating.labelAr() : rating.labelEn(),
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

          // 4-Tile Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: isArabic ? 'ارتفاع الموج' : 'Wave Height',
                  value: isArabic
                      ? '${marine.waveHeightMeters.toStringAsFixed(1)} م'
                      : '${marine.waveHeightMeters.toStringAsFixed(1)} m',
                  icon: Icons.waves_rounded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: isArabic ? 'زمن الدورة' : 'Wave Period',
                  value: isArabic
                      ? '${marine.wavePeriodSeconds.toStringAsFixed(0)} ثانية'
                      : '${marine.wavePeriodSeconds.toStringAsFixed(0)} s',
                  icon: Icons.timer_outlined,
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
                  context,
                  title: isArabic ? 'اتجاه الموج' : 'Wave Direction',
                  value: marine.directionCompass(isArabic: isArabic),
                  icon: Icons.explore_outlined,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: isArabic ? 'أمواج الرياح' : 'Wind Waves',
                  value: isArabic
                      ? '${marine.windWaveHeightMeters.toStringAsFixed(1)} م'
                      : '${marine.windWaveHeightMeters.toStringAsFixed(1)} m',
                  icon: Icons.air_rounded,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Official Disclaimer Note
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
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppColors.cyanAccent,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    isArabic
                        ? 'تنبيه: حالة البحر إرشادية فقط؛ يُرجى اتباع رايات الإنقاذ على الشواطئ والتحذيرات الرسمية لمصلحة الأرصاد.'
                        : 'Disclaimer: Sea conditions are indicative only; please follow lifeguard flags and official coast guard alerts.',
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

  Widget _buildMetricTile(
    BuildContext context, {
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
              Icon(icon, size: 14, color: AppColors.cyanAccent),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
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
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

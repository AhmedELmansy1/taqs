import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';

/// Card tile presenting a single prayer time with active highlight for the next prayer.
class PrayerItemTile extends StatelessWidget {
  const PrayerItemTile({
    required this.prayer,
    required this.isArabic,
    super.key,
  });

  final PrayerItem prayer;
  final bool isArabic;

  IconData _getIcon(PrayerType type, bool isFriday) {
    switch (type) {
      case PrayerType.fajr:
        return Icons.nightlight_round;
      case PrayerType.sunrise:
        return Icons.wb_twilight_rounded;
      case PrayerType.dhuhr:
        return isFriday ? Icons.mosque_rounded : Icons.wb_sunny_rounded;
      case PrayerType.asr:
        return Icons.sunny_snowing;
      case PrayerType.maghrib:
        return Icons.wb_twilight_outlined;
      case PrayerType.isha:
        return Icons.bedtime_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final name = isArabic ? prayer.nameAr() : prayer.nameEn();
    final timeStr = DateFormat('h:mm a', isArabic ? 'ar' : 'en').format(prayer.time);
    final isSunrise = prayer.type == PrayerType.sunrise;
    final isNext = prayer.isNext;
    final isPast = prayer.isPast;

    final icon = _getIcon(prayer.type, prayer.isFriday);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        backgroundColor: isNext
            ? (isDark
                ? AppColors.darkSurfaceHover
                : AppColors.lightSurfaceElevated)
            : null,
        borderColor: isNext ? AppColors.metallicGold : null,
        child: Row(
          children: [
            // Prayer Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: isNext
                    ? AppColors.metallicGold.withValues(alpha: 0.2)
                    : (isDark
                        ? AppColors.darkSurfaceHover
                        : AppColors.lightSurfaceElevated),
                borderRadius: AppRadius.borderSm,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isNext
                    ? AppColors.metallicGold
                    : (isPast
                        ? AppColors.darkTextMuted
                        : (isDark
                            ? AppColors.cyanAccent
                            : AppColors.electricBlue)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Prayer Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight:
                              isNext ? FontWeight.w800 : FontWeight.w600,
                          color: isPast
                              ? (isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted)
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                        ),
                      ),
                      if (isSunrise) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceHover
                                : AppColors.lightSurfaceElevated,
                            borderRadius: AppRadius.borderPill,
                          ),
                          child: Text(
                            isArabic ? 'شروق' : 'Sunrise',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: AppColors.darkTextMuted,
                            ),
                          ),
                        ),
                      ],
                      if (isNext) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.metallicGold,
                            borderRadius: AppRadius.borderPill,
                          ),
                          child: Text(
                            isArabic ? 'القادمة' : 'NEXT',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0B111E),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Time Display
            Text(
              timeStr,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
                color: isNext
                    ? (isDark
                        ? AppColors.metallicGold
                        : const Color(0xFFB8860B))
                    : (isPast
                        ? AppColors.darkTextMuted
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

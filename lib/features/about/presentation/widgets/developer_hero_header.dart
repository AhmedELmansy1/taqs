import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/about/data/developer_profile.dart';

/// Hero header widget displaying developer avatar, name, verified badge, title, location, and summary.
class DeveloperHeroHeader extends StatelessWidget {
  const DeveloperHeroHeader({
    required this.profile,
    required this.isArabic,
    super.key,
  });

  final DeveloperProfile profile;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final name = isArabic ? profile.nameAr : profile.nameEn;
    final title = isArabic ? profile.titleAr : profile.titleEn;
    final location = isArabic ? profile.locationAr : profile.locationEn;
    final summary = isArabic ? profile.summaryAr : profile.summaryEn;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // Avatar: Photo from assets/images/developer.jpg if present, else luxury monogram
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.metallicGold.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricBlue.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/developer.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.electricBlue,
                          AppColors.cyanAccent.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'AE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Name + Verified Badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.verified_rounded,
                size: 20,
                color: AppColors.cyanAccent,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.cyanAccent : AppColors.electricBlue,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Location Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceElevated,
              borderRadius: AppRadius.borderPill,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.metallicGold,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  location,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            summary,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

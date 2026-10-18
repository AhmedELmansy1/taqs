import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/advisor/domain/entities/clothing_advice.dart';

/// Presentation card displaying smart clothing advice tailored to current weather metrics.
class WhatToWearCard extends StatelessWidget {
  const WhatToWearCard({
    required this.advice,
    required this.isArabic,
    super.key,
  });

  final ClothingAdvice advice;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final headline = isArabic ? advice.headlineAr : advice.headlineEn;
    final details = isArabic ? advice.detailsAr : advice.detailsEn;
    final seasonTag = isArabic ? advice.seasonTagAr : advice.seasonTagEn;
    final items = isArabic ? advice.itemsAr : advice.itemsEn;

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
          // Header row with season badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.checkroom_rounded,
                    color: AppColors.cyanAccent,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    isArabic ? 'ماذا أرتدي اليوم؟' : 'What to wear today?',
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
                  color: AppColors.cyanAccent.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderPill,
                  border: Border.all(
                    color: AppColors.cyanAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  seasonTag,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.cyanAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Headline
          Text(
            headline,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),

          // Details
          Text(
            details,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Recommended item tags
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
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
                          Icons.check_circle_outline_rounded,
                          size: 13,
                          color: AppColors.cyanAccent,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          item,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

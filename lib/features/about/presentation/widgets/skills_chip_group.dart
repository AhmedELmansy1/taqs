import 'package:flutter/material.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/about/data/developer_profile.dart';

/// Grouped skill chips categorized sensibly without fake proficiency bars.
class SkillsChipGroup extends StatelessWidget {
  const SkillsChipGroup({
    required this.skills,
    this.categories,
    this.isArabic = true,
    super.key,
  });

  final List<String> skills;
  final List<SkillCategory>? categories;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (categories != null && categories!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories!.map((cat) {
          final catTitle = isArabic ? cat.nameAr : cat.nameEn;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catTitle,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isDark
                        ? AppColors.cyanAccent
                        : AppColors.electricBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: cat.skills.map((skill) {
                    return _SkillChip(skill: skill, isDark: isDark);
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: skills.map((skill) {
        return _SkillChip(skill: skill, isDark: isDark);
      }).toList(),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({
    required this.skill,
    required this.isDark,
  });

  final String skill;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
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
      child: Text(
        skill,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
      ),
    );
  }
}

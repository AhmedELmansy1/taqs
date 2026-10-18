import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/about/data/developer_profile.dart';

/// Clean list displaying developer project cards with verified factual details.
class ProjectsList extends StatelessWidget {
  const ProjectsList({
    required this.projects,
    this.projectItems,
    this.isArabic = true,
    super.key,
  });

  final List<String> projects;
  final List<ProjectItem>? projectItems;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (projectItems != null && projectItems!.isNotEmpty) {
      return Column(
        children: projectItems!.map((item) {
          final tag = isArabic ? item.tagAr : item.tagEn;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs + 2),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withValues(alpha: 0.15),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: const Icon(
                      Icons.code_rounded,
                      color: AppColors.cyanAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        if (tag != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            tag,
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.4,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: projects.map((project) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs + 2),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: const Icon(
                    Icons.terminal_rounded,
                    color: AppColors.cyanAccent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    project,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

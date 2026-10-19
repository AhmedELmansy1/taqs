import 'package:flutter/material.dart';
import 'package:taqs/core/design/branding/taqs_logo.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Card spotlighting Taqs as the developer's actively maintained flagship project.
class CurrentlyBuildingCard extends StatelessWidget {
  const CurrentlyBuildingCard({
    required this.isArabic,
    super.key,
    this.onTap,
  });

  final bool isArabic;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      container: true,
      label: '${l10n.currentlyBuildingTitle}: ${l10n.currentlyBuildingSubtitle}',
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Active Status Badge + Taqs Icon
            Row(
              children: [
                // Live pulsation badge
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: AppRadius.borderPill,
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            l10n.inActiveDevelopment,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const TaqsLogo(size: 32),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Section Tagline
            Text(
              l10n.currentlyBuildingTitle,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? AppColors.cyanAccent : AppColors.electricBlue,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),

            // App Title
            Text(
              l10n.currentlyBuildingSubtitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // App Narrative
            Text(
              l10n.currentlyBuildingDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.55,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Architecture Highlights
            const Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _TechBadge(label: 'Flutter'),
                _TechBadge(label: 'Clean Architecture'),
                _TechBadge(label: 'Riverpod'),
                _TechBadge(label: 'Astronomical Adhan'),
                _TechBadge(label: 'Offline-First'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TechBadge extends StatelessWidget {
  const _TechBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
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
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}

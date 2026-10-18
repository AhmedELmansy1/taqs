import 'package:flutter/material.dart';
import 'package:taqs/core/design/branding/taqs_logo.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';

/// Card explaining the architectural intent and purpose behind Taqs.
class WhyTaqsCard extends StatelessWidget {
  const WhyTaqsCard({
    required this.whyTaqsText,
    required this.isArabic,
    super.key,
  });

  final String whyTaqsText;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TaqsLogo(
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isArabic ? 'لماذا طقس؟' : 'Why Taqs?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            whyTaqsText,
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

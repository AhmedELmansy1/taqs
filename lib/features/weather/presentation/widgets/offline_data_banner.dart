import 'package:flutter/material.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Informative banner shown when presenting cached weather data during offline periods.
class OfflineDataBanner extends StatelessWidget {
  const OfflineDataBanner({
    required this.fetchedAt,
    required this.onRefresh,
    super.key,
  });

  final DateTime? fetchedAt;
  final VoidCallback onRefresh;

  String _formatElapsedTime(BuildContext context, DateTime? time) {
    final l10n = AppLocalizations.of(context);
    if (time == null) return l10n.justNow;

    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) {
      return l10n.justNow;
    } else if (diff.inMinutes < 60) {
      return l10n.minutesAgo(diff.inMinutes);
    } else {
      return l10n.hoursAgo(diff.inHours);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final timeString = _formatElapsedTime(context, fetchedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.metallicGold.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: AppColors.metallicGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 18,
            color: AppColors.metallicGold,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.offlineDataBanner(timeString),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
              color: AppColors.metallicGold,
            ),
            tooltip: l10n.retry,
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}

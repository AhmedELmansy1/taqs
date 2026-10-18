import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/design/branding/taqs_logo.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Footer displaying "Share the app", Open-Source Licenses, and Open-Meteo attribution.
class AboutFooter extends StatelessWidget {
  const AboutFooter({
    this.isArabic = true,
    super.key,
  });

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          // Share the app button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: BorderSide(
                color: isDark ? AppColors.cyanAccent : AppColors.electricBlue,
              ),
              foregroundColor:
                  isDark ? AppColors.cyanAccent : AppColors.electricBlue,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderMd,
              ),
            ),
            icon: const Icon(Icons.share_rounded, size: 18),
            label: Text(
              isArabic ? 'مشاركة تطبيق طقس' : 'Share Taqs App',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              unawaited(HapticFeedback.lightImpact());
              unawaited(
                SharePlus.instance.share(
                  ShareParams(
                    text: isArabic
                        ? 'جرّب تطبيق طقس (Taqs) — التطبيق العربي الأول للطقس بدقة متناهية وتصميم فاخر: https://github.com/AhmedELmansy1/taqs'
                        : 'Experience Taqs — Luxury Arabic-first weather app built with Flutter: https://github.com/AhmedELmansy1/taqs',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          // View Licenses button
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            icon: const Icon(Icons.article_outlined, size: 16),
            label: Text(
              isArabic ? 'تراخيص البرمجيات مفتوحة المصدر' : 'Open Source Licenses',
              style: const TextStyle(fontSize: 13),
            ),
            onPressed: () {
              unawaited(HapticFeedback.lightImpact());
              showLicensePage(
                context: context,
                applicationName: isArabic
                    ? AppConstants.appNameAr
                    : AppConstants.appNameEn,
                applicationVersion: '1.0.0',
                applicationIcon: const Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: TaqsLogo(size: 48),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(size: 16),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.builtWithFlutter,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '1.0.0';
              return Column(
                children: [
                  Text(
                    l10n.appVersion(version),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.openMeteoAttribution,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

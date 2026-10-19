import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Call-to-action card encouraging collaboration and direct contact with the developer.
class WorkTogetherCard extends StatelessWidget {
  const WorkTogetherCard({
    required this.email,
    required this.isArabic,
    super.key,
  });

  final String email;
  final bool isArabic;

  Future<void> _handleEmailLaunch(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final emailUri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent('Inquiry / Opportunity')}');

    try {
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _copyAndNotify(context, l10n);
      }
    } on Object catch (_) {
      if (context.mounted) {
        _copyAndNotify(context, l10n);
      }
    }
  }

  void _copyAndNotify(BuildContext context, AppLocalizations l10n) {
    unawaited(Clipboard.setData(ClipboardData(text: email)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${l10n.cannotLaunchUrl(email)} — ${l10n.copiedToClipboard(email)}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      container: true,
      label: l10n.letsWorkTogetherTitle,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFF0FDF4),
                    const Color(0xFFF8FAFC),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: isDark
                ? AppColors.metallicGold.withValues(alpha: 0.35)
                : AppColors.metallicGold.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.metallicGold.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon Accent
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFDE68A), AppColors.metallicGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.metallicGold.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.handshake_outlined,
                color: Color(0xFF0B132B),
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title
            Text(
              l10n.letsWorkTogetherTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),

            // Subtitle
            Text(
              l10n.letsWorkTogetherSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Action Button with 48dp minimum touch target
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 200),
              child: ElevatedButton.icon(
                onPressed: () => unawaited(_handleEmailLaunch(context)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.borderPill,
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.mail_outline_rounded, size: 20),
                label: Text(
                  l10n.contactMeAction,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

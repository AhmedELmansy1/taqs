import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/about/data/developer_profile.dart';
import 'package:taqs/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contact section providing interactive cards for Email, Phone, GitHub, and LinkedIn.
class ContactSection extends StatelessWidget {
  const ContactSection({
    required this.contact,
    super.key,
  });

  final DeveloperContact contact;

  Future<void> _handleLaunch(
    BuildContext context, {
    required Uri uri,
    required String rawValue,
  }) async {
    final l10n = AppLocalizations.of(context);
    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!success && context.mounted) {
        _showFallback(context, rawValue, l10n);
      }
    } on Exception catch (_) {
      if (context.mounted) {
        _showFallback(context, rawValue, l10n);
      }
    }
  }

  void _showFallback(
    BuildContext context,
    String rawValue,
    AppLocalizations l10n,
  ) {
    unawaited(Clipboard.setData(ClipboardData(text: rawValue)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${l10n.cannotLaunchUrl(rawValue)} — ${l10n.copiedToClipboard(rawValue)}',
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

    return Column(
      children: [
        // Email
        _ContactTile(
          icon: Icons.alternate_email_rounded,
          iconColor: AppColors.cyanAccent,
          label: l10n.email,
          value: contact.email,
          actionLabel: l10n.sendEmail,
          onTap: () => unawaited(
            _handleLaunch(
              context,
              uri: Uri.parse('mailto:${contact.email}'),
              rawValue: contact.email,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Phone
        _ContactTile(
          icon: Icons.phone_outlined,
          iconColor: AppColors.electricBlue,
          label: l10n.phone,
          value: contact.phone,
          actionLabel: l10n.callPhone,
          onTap: () => unawaited(
            _handleLaunch(
              context,
              uri: Uri.parse('tel:${contact.phone.replaceAll(' ', '')}'),
              rawValue: contact.phone,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // GitHub
        _ContactTile(
          icon: Icons.code_rounded,
          iconColor: isDark ? Colors.white : AppColors.darkBackground,
          label: l10n.github,
          value: 'github.com/AhmedELmansy1',
          actionLabel: l10n.openGitHub,
          onTap: () => unawaited(
            _handleLaunch(
              context,
              uri: Uri.parse(contact.githubUrl),
              rawValue: contact.githubUrl,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // LinkedIn
        _ContactTile(
          icon: Icons.business_center_outlined,
          iconColor: const Color(0xFF0077B5),
          label: l10n.linkedin,
          value: 'linkedin.com/in/ahmed-elmansy',
          actionLabel: l10n.openLinkedIn,
          onTap: () => unawaited(
            _handleLaunch(
              context,
              uri: Uri.parse(contact.linkedinUrl),
              rawValue: contact.linkedinUrl,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.darkTextMuted,
          ),
        ],
      ),
    );
  }
}

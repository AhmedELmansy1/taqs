import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_button.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';

/// Reusable error placeholder with retry action.
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.message,
    super.key,
    this.onRetry,
    this.retryLabel,
    this.icon,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ??
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.alertRed,
                  size: 48,
                ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            if (onRetry != null && retryLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: retryLabel!,
                onPressed: onRetry,
                variant: AppButtonVariant.outlined,
                icon: const Icon(Icons.refresh_rounded, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

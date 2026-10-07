import 'package:flutter/material.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outlined }

/// Reusable accessible button conforming to a 48dp minimum touch target.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bg;
    Color fg;
    var borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.electricBlue;
        fg = Colors.white;
      case AppButtonVariant.secondary:
        bg = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        borderSide = BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        );
      case AppButtonVariant.outlined:
        bg = Colors.transparent;
        fg = isDark ? AppColors.cyanAccent : AppColors.electricBlue;
        borderSide = BorderSide(color: fg);
    }

    final childWidget = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      side: borderSide,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
      ),
      minimumSize: Size(
        isFullWidth ? double.infinity : 0,
        AppSpacing.touchTarget,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: childWidget,
    );
  }
}

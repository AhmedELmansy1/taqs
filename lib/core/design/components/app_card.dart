import 'package:flutter/material.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';

/// Reusable container card with calm elevation, rounded corners, and subtle borders.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppRadius.borderLg,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final resolvedBg = backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final resolvedBorder = borderColor ??
        (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: borderRadius,
        border: Border.all(color: resolvedBorder),
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: content,
        ),
      );
    }

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: content,
      );
    }

    return content;
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';

/// Reusable container card with calm elevation, rounded corners, subtle borders,
/// and optional soft luxury gradient layering.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppRadius.borderLg,
    this.gradient,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius borderRadius;
  final Gradient? gradient;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final resolvedBg = backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final resolvedBorder = borderColor ??
        (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    // Subtle luxury gradient for cards when none explicitly provided
    final resolvedGradient = gradient ??
        (isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF131E36),
                  Color(0xFF0D1627),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF8FAFC),
                ],
              ));

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBg,
        gradient: resolvedGradient,
        borderRadius: borderRadius,
        border: Border.all(color: resolvedBorder),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0x33000000)
                : const Color(0x0D0F172A),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: () {
            unawaited(HapticFeedback.lightImpact());
            onTap!();
          },
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

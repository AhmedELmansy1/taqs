import 'package:flutter/material.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';

/// Elegant horizontal divider with feathered transparent edges.
///
/// Replaces heavy opaque borders or solid card separators with a premium,
/// subtle ambient division between sections.
class SubtleGradientDivider extends StatelessWidget {
  const SubtleGradientDivider({
    super.key,
    this.verticalMargin = AppSpacing.lg,
  });

  final double verticalMargin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalMargin),
      child: Center(
        child: Container(
          height: 1,
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      Colors.transparent,
                      AppColors.metallicGold.withValues(alpha: 0.28),
                      AppColors.cyanAccent.withValues(alpha: 0.25),
                      Colors.transparent,
                    ]
                  : [
                      Colors.transparent,
                      AppColors.metallicGold.withValues(alpha: 0.35),
                      AppColors.electricBlue.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
              stops: const [0.0, 0.35, 0.65, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

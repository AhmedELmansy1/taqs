import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/about/data/developer_profile.dart';
import 'package:taqs/features/about/presentation/widgets/cv_download_button.dart';

/// Hero header widget displaying developer avatar with an animated luxury gold ring,
/// verified badge, professional title, location, summary, and CV download action.
class DeveloperHeroHeader extends StatefulWidget {
  const DeveloperHeroHeader({
    required this.profile,
    required this.isArabic,
    super.key,
  });

  final DeveloperProfile profile;
  final bool isArabic;

  @override
  State<DeveloperHeroHeader> createState() => _DeveloperHeroHeaderState();
}

class _DeveloperHeroHeaderState extends State<DeveloperHeroHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _ringController.repeat();
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (disableAnimations && _ringController.isAnimating) {
      _ringController.stop();
    }

    final name = widget.isArabic ? widget.profile.nameAr : widget.profile.nameEn;
    final title = widget.isArabic ? widget.profile.titleAr : widget.profile.titleEn;
    final location = widget.isArabic ? widget.profile.locationAr : widget.profile.locationEn;
    final summary = widget.isArabic ? widget.profile.summaryAr : widget.profile.summaryEn;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          // Avatar surrounded by an isolated RepaintBoundary animated gold ring
          Center(
            child: SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated Gold Ring
                  RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _ringController,
                      builder: (context, child) {
                        final angle = disableAnimations
                            ? 0.0
                            : _ringController.value * 2 * math.pi;
                        return Transform.rotate(
                          angle: angle,
                          child: Container(
                            width: 94,
                            height: 94,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  AppColors.metallicGold,
                                  Color(0xFFFDE68A),
                                  AppColors.electricBlue,
                                  AppColors.metallicGold,
                                ],
                                stops: [0.0, 0.4, 0.7, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Inner padding circle
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF0B132B) : Colors.white,
                    ),
                  ),

                  // Photo / Monogram
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/developer.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.electricBlue,
                                  AppColors.cyanAccent.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'AE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Name + Verified Badge
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.xs,
            children: [
              Text(
                name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const Icon(
                Icons.verified_rounded,
                size: 20,
                color: AppColors.cyanAccent,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Title
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.cyanAccent : AppColors.electricBlue,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Location Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceElevated,
              borderRadius: AppRadius.borderPill,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.metallicGold,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  location,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Summary narrative
          Text(
            summary,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Download CV button (visible only if asset exists)
          CvDownloadButton(isArabic: widget.isArabic),
        ],
      ),
    );
  }
}

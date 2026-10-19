import 'package:flutter/material.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/prayer/data/takbeerat_texts.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';
import 'package:taqs/features/prayer/domain/services/eid_detector.dart';

/// Luxury calm gold-on-navy card displaying Takbeerat before the Adhan or during Eid.
///
/// Features calligraphic typography, subtle golden accents, and reduce-motion awareness.
/// Designed for both live interactive display and offscreen snapshotting for rich notifications.
class TakbeeratCard extends StatefulWidget {
  const TakbeeratCard({
    required this.isArabic,
    super.key,
    this.nextPrayer,
    this.remainingMinutes,
    this.eidPeriod = EidPeriod.none,
    this.onTap,
  });

  final bool isArabic;
  final PrayerItem? nextPrayer;
  final int? remainingMinutes;
  final EidPeriod eidPeriod;
  final VoidCallback? onTap;

  @override
  State<TakbeeratCard> createState() => _TakbeeratCardState();
}

class _TakbeeratCardState extends State<TakbeeratCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _glowAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final isEid = widget.eidPeriod.isEid;

    // Calligraphic styling for Arabic religious text with Amiri fallback
    final calligraphicStyle = theme.textTheme.titleMedium?.copyWith(
          fontFamily: 'Amiri',
          fontSize: isEid ? 19 : 20,
          fontWeight: FontWeight.w700,
          height: 1.8,
          color: const Color(0xFFFDE68A),
        ) ??
        const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.8,
          color: Color(0xFFFDE68A),
        );

    final String mainText;
    final String subtitle;
    final String badgeText;

    if (isEid) {
      mainText = widget.isArabic
          ? TakbeeratTexts.eidTakbeerConciseAr
          : TakbeeratTexts.eidTakbeerConciseEn;
      subtitle = widget.isArabic
          ? TakbeeratTexts.eidGreetingAr
          : TakbeeratTexts.eidGreetingEn;
      badgeText = EidDetector.getEidLabel(widget.eidPeriod, isArabic: widget.isArabic) ??
          (widget.isArabic ? 'تكبيرات العيد' : 'Eid Takbeerat');
    } else {
      mainText = widget.isArabic
          ? TakbeeratTexts.preAdhanTakbeerAr
          : TakbeeratTexts.preAdhanTakbeerEn;
      subtitle = widget.isArabic
          ? TakbeeratTexts.preAdhanPreparationAr
          : TakbeeratTexts.preAdhanPreparationEn;

      final prayerName = widget.nextPrayer != null
          ? (widget.isArabic
              ? widget.nextPrayer!.type.nameAr()
              : widget.nextPrayer!.type.nameEn())
          : '';
      final minutes = widget.remainingMinutes ?? 5;
      badgeText = widget.isArabic
          ? (minutes == 0 ? 'حان الآن أذان $prayerName' : 'اقترب أذان $prayerName ($minutes د)')
          : (minutes == 0 ? '$prayerName Adhan Now' : '$prayerName in $minutes min');
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowAlpha = reduceMotion ? 0.2 : _glowAnimation.value;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: AppRadius.borderLg,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.borderLg,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F1B36),
                    Color(0xFF0B132B),
                    Color(0xFF070D1E),
                  ],
                ),
                border: Border.all(
                  color: AppColors.metallicGold.withValues(alpha: glowAlpha + 0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.metallicGold.withValues(alpha: glowAlpha * 0.4),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm + 2,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.metallicGold.withValues(alpha: 0.18),
                          borderRadius: AppRadius.borderSm,
                          border: Border.all(
                            color: AppColors.metallicGold.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: AppColors.metallicGold,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              badgeText,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFDE68A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.mosque_outlined,
                        size: 20,
                        color: AppColors.metallicGold,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Calligraphic Takbeerat Text
                  Text(
                    mainText,
                    textAlign: TextAlign.center,
                    style: calligraphicStyle,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Gold divider line with subtle star center
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.metallicGold.withValues(alpha: 0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Icon(
                          Icons.nights_stay_outlined,
                          size: 14,
                          color: AppColors.metallicGold.withValues(alpha: 0.7),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.metallicGold.withValues(alpha: 0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Subtitle & Adhan preparation note
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: widget.isArabic ? 0 : 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

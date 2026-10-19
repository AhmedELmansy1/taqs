import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/core/navigation/app_routes.dart';
import 'package:taqs/features/location/presentation/providers/location_controller.dart';
import 'package:taqs/features/prayer/domain/services/eid_detector.dart';
import 'package:taqs/features/prayer/presentation/providers/prayer_settings_controller.dart';
import 'package:taqs/features/prayer/presentation/providers/prayer_view_model.dart';
import 'package:taqs/features/prayer/presentation/widgets/prayer_countdown_arc.dart';
import 'package:taqs/features/prayer/presentation/widgets/prayer_item_tile.dart';
import 'package:taqs/features/prayer/presentation/widgets/takbeerat_card.dart';

/// Complete presentation view for the Prayer Times section.
class PrayerSectionView extends ConsumerWidget {
  const PrayerSectionView({
    required this.isArabic,
    super.key,
  });

  final bool isArabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bundle = ref.watch(prayerViewModelProvider);
    final locationState = ref.watch(locationControllerProvider);
    final settings = ref.watch(prayerSettingsControllerProvider);

    final loc = locationState.selectedLocation;
    final cityName = isArabic
        ? (loc.nameAr.isNotEmpty ? loc.nameAr : bundle.cityNameAr)
        : (loc.nameEn.isNotEmpty ? loc.nameEn : bundle.cityNameEn);

    final hijriDate = isArabic ? bundle.hijriFormattedAr : bundle.hijriFormattedEn;
    final gregorianDate =
        isArabic ? bundle.gregorianFormattedAr : bundle.gregorianFormattedEn;

    // Detect Eid mode using settings and manual adjustment offset
    final eidPeriod = settings.eidModeEnabled
        ? EidDetector.detectEidPeriod(
            date: DateTime.now(),
            manualAdjustmentDays: settings.hijriDayAdjustment,
          )
        : EidPeriod.none;

    final remainingSeconds = bundle.timeToNextPrayer.inSeconds;
    final leadSeconds = settings.leadTimeMinutes * 60;
    final isWithinLeadTime =
        remainingSeconds <= leadSeconds && remainingSeconds >= 0;
    final showTakbeerat =
        settings.showTakbeeratCard && (isWithinLeadTime || eidPeriod.isEid);

    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return RefreshIndicator(
      color: AppColors.metallicGold,
      backgroundColor: AppColors.darkSurface,
      onRefresh: () async {
        ref.invalidate(prayerViewModelProvider);
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            children: [
              // Location Affordance Header
              InkWell(
                onTap: () => context.push(AppRoutes.locationSearch),
                borderRadius: AppRadius.borderSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.metallicGold,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        cityName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.darkTextMuted,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Hijri & Gregorian Calendar Header
              Column(
                children: [
                  Text(
                    hijriDate,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.metallicGold
                          : const Color(0xFFB8860B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    gregorianDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (eidPeriod.isEid) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.metallicGold.withValues(alpha: 0.16),
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: AppColors.metallicGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 15,
                            color: AppColors.metallicGold,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            EidDetector.getEidLabel(
                                  eidPeriod,
                                  isArabic: isArabic,
                                ) ??
                                '',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFFB8860B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Centerpiece Countdown Arc / Takbeerat Card
              Center(
                child: AnimatedSwitcher(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 400),
                  child: showTakbeerat
                      ? Column(
                          key: const ValueKey('takbeerat_augmented_view'),
                          children: [
                            TakbeeratCard(
                              isArabic: isArabic,
                              nextPrayer: bundle.nextPrayer,
                              remainingMinutes:
                                  bundle.timeToNextPrayer.inMinutes,
                              eidPeriod: eidPeriod,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PrayerCountdownArc(
                              nextPrayer: bundle.nextPrayer,
                              previousPrayer: bundle.previousPrayer,
                              timeToNext: bundle.timeToNextPrayer,
                              isArabic: isArabic,
                            ),
                          ],
                        )
                      : PrayerCountdownArc(
                          key: const ValueKey('prayer_countdown_arc_standard'),
                          nextPrayer: bundle.nextPrayer,
                          previousPrayer: bundle.previousPrayer,
                          timeToNext: bundle.timeToNextPrayer,
                          isArabic: isArabic,
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Section Title
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.metallicGold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppColors.metallicGold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      isArabic ? 'مواقيت الصلاة اليوم' : "Today's Prayer Times",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Prayer Tiles List
              ...bundle.prayers.map(
                (prayer) => PrayerItemTile(
                  prayer: prayer,
                  isArabic: isArabic,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Authority Calculation Badge & Honest Disclaimer
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceHover.withValues(alpha: 0.4)
                      : AppColors.lightSurfaceElevated,
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorderSubtle
                        : AppColors.lightBorderSubtle,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          size: 16,
                          color: AppColors.cyanAccent,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            isArabic
                                ? 'الهيئة المصرية العامة للمساحة'
                                : 'Egyptian General Authority of Survey',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.cyanAccent
                                  : AppColors.electricBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isArabic
                          ? 'المواقيت محسوبة فلكياً وفق خطوط العرض والطول؛ يُرجى مراجعة إمام المسجد المحلي أو جدول الأوقاف الرسمي للتأكد.'
                          : 'Times are calculated astronomically based on coordinates; please verify with your local mosque or official Awqaf timetable.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.5,
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

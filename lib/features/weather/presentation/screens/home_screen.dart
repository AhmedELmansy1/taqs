import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/design/branding/taqs_logo.dart';
import 'package:taqs/core/design/components/atmospheric_background.dart';
import 'package:taqs/core/design/components/error_state.dart';
import 'package:taqs/core/design/components/loading_state.dart';
import 'package:taqs/core/design/components/permission_recovery_banner.dart';
import 'package:taqs/core/design/components/section_header.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/core/errors/error_localizer.dart';
import 'package:taqs/core/navigation/app_routes.dart';
import 'package:taqs/features/advisor/domain/services/clothing_advisor.dart';
import 'package:taqs/features/advisor/presentation/widgets/what_to_wear_card.dart';
import 'package:taqs/features/air_quality/presentation/widgets/air_quality_card.dart';
import 'package:taqs/features/alerts/domain/services/egypt_alert_evaluator.dart';
import 'package:taqs/features/alerts/presentation/widgets/severe_weather_alert_card.dart';
import 'package:taqs/features/driving/presentation/widgets/driving_safety_card.dart';
import 'package:taqs/features/farming/presentation/widgets/farming_card.dart';
import 'package:taqs/features/marine/presentation/providers/marine_provider.dart';
import 'package:taqs/features/marine/presentation/widgets/marine_condition_card.dart';
import 'package:taqs/features/prayer/presentation/providers/prayer_view_model.dart';
import 'package:taqs/features/prayer/presentation/screens/prayer_section_view.dart';
import 'package:taqs/features/weather/presentation/controllers/farmer_mode_controller.dart';
import 'package:taqs/features/weather/presentation/controllers/home_tab_controller.dart';
import 'package:taqs/features/weather/presentation/providers/weather_provider.dart';
import 'package:taqs/features/weather/presentation/widgets/current_weather_card.dart';
import 'package:taqs/features/weather/presentation/widgets/daily_forecast_list.dart';
import 'package:taqs/features/weather/presentation/widgets/home_segmented_header.dart';
import 'package:taqs/features/weather/presentation/widgets/hourly_temperature_chart.dart';
import 'package:taqs/features/weather/presentation/widgets/offline_data_banner.dart';
import 'package:taqs/features/weather/presentation/widgets/sunrise_sunset_arc.dart';
import 'package:taqs/features/weather/presentation/widgets/weather_details_grid.dart';
import 'package:taqs/features/weather/presentation/widgets/weather_share_card.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Luxury Home screen combining Weather & Prayer Times via a segmented header switch.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    this.initialTab,
    super.key,
  });

  final HomeTab? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialTab != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          ref.read(homeTabControllerProvider.notifier).setTab(initialTab!),
        );
      });
    }

    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final weatherState = ref.watch(weatherViewModelProvider);
    final selectedTab = ref.watch(homeTabControllerProvider);
    final marineAsync = ref.watch(marineConditionsProvider);
    final isFarmerMode = ref.watch(farmerModeControllerProvider);

    return weatherState.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(
            isArabic ? AppConstants.appNameAr : AppConstants.appNameEn,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: const LoadingState(),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            isArabic ? AppConstants.appNameAr : AppConstants.appNameEn,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: ErrorState(
          message: ErrorLocalizer.localize(context, error),
          retryLabel: l10n.retry,
          onRetry: () => ref.read(weatherViewModelProvider.notifier).refresh(),
        ),
      ),
      data: (bundle) {
        final alerts = EgyptAlertEvaluator.evaluate(bundle);
        final clothingAdvice = ClothingAdvisor.recommend(bundle);
        final gradient = AtmosphericGradients.forCondition(
          bundle.current.condition,
          isDay: bundle.current.isDay,
        );

        return AtmosphericBackground(
          gradient: gradient,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TaqsLogo(
                    size: 28,
                    withBackground: false,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    isArabic ? AppConstants.appNameAr : AppConstants.appNameEn,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.compare_arrows_rounded,
                    color: AppColors.cyanAccent,
                  ),
                  tooltip: isArabic ? 'مقارنة المحافظات' : 'Compare Governorates',
                  onPressed: () => context.push(AppRoutes.compare),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: AppColors.cyanAccent,
                  ),
                  tooltip: isArabic ? 'مشاركة بطاقة الطقس' : 'Share Weather Card',
                  onPressed: () {
                    final prayerState = ref.read(prayerViewModelProvider);
                    unawaited(
                      WeatherShareModal.show(
                        context,
                        weather: bundle,
                        isArabic: isArabic,
                        prayerTimes: prayerState,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.cyanAccent,
                  ),
                  tooltip: l10n.selectLocation,
                  onPressed: () => context.push(AppRoutes.locationSearch),
                ),
              ],
            ),
            body: Column(
              children: [
                // Segmented Switch Header: Weather vs Prayer Times
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: HomeSegmentedHeader(
                        selectedTab: selectedTab,
                        onTabChanged: (tab) =>
                            unawaited(ref.read(homeTabControllerProvider.notifier).setTab(tab)),
                        isArabic: isArabic,
                      ),
                    ),
                  ),
                ),

                // Content View (Weather or Prayer Times)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: selectedTab == HomeTab.weather
                        ? RefreshIndicator(
                            key: const ValueKey('weather_section'),
                            color: AppColors.cyanAccent,
                            backgroundColor: AppColors.darkSurface,
                            onRefresh: () => ref
                                .read(weatherViewModelProvider.notifier)
                                .refresh(),
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
                              // Offline Stale Banner if data is served from local cache
                              if (bundle.isFromCache)
                                OfflineDataBanner(
                                  fetchedAt: bundle.fetchedAt,
                                  onRefresh: () => ref
                                      .read(weatherViewModelProvider.notifier)
                                      .refresh(),
                                ),

                              // Non-intrusive missing permission recovery banner
                              const PermissionRecoveryBanner(),

                              // Severe Weather Alerts if triggered
                              if (alerts.isNotEmpty) ...[
                                ...alerts.map(
                                  (alert) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: SevereWeatherAlertCard(
                                      alert: alert,
                                      isArabic: isArabic,
                                    ),
                                  ),
                                ),
                              ],

                              // 1. Hero Weather Card with Artwork & Tabular Figures
                              CurrentWeatherCard(
                                weather: bundle.current,
                                isArabic: isArabic,
                                onLocationTap: () =>
                                    context.push(AppRoutes.locationSearch),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // 2. Road Driving Safety Card
                              DrivingSafetyCard(
                                weather: bundle.current,
                                isArabic: isArabic,
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // 3. Coastal Marine Conditions (shown ONLY when data available)
                              if (marineAsync.value != null) ...[
                                MarineConditionCard(
                                  marine: marineAsync.value!,
                                  isArabic: isArabic,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                              ],

                              // 4. Agricultural Farmer Mode (if enabled in settings)
                              if (isFarmerMode) ...[
                                FarmingCard(
                                  bundle: bundle,
                                  isArabic: isArabic,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                              ],

                              // 2. Smart Outfit Recommendation Card
                              WhatToWearCard(
                                advice: clothingAdvice,
                                isArabic: isArabic,
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // 3. Air Quality Index Card
                              if (bundle.airQuality != null) ...[
                                AirQualityCard(
                                  airQuality: bundle.airQuality!,
                                  isArabic: isArabic,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                              ],

                              // 4. Continuous 24-Hour Temperature Curve Chart
                              HourlyTemperatureChart(hourly: bundle.hourly),
                              const SizedBox(height: AppSpacing.lg),

                              // 5. 7-Day Forecast with Horizontal Range Bars
                              SectionHeader(
                                title: l10n.weeklyForecastTitle,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              DailyForecastList(
                                daily: bundle.daily,
                                isArabic: isArabic,
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // 6. Six-Tile Meteorological Details Grid
                              SectionHeader(
                                title: isArabic ? 'تفاصيل الطقس' : 'Weather Details',
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              WeatherDetailsGrid(
                                weather: bundle.current,
                                isArabic: isArabic,
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // 7. Celestial Solar Arc
                              SunriseSunsetArc(
                                sunriseTime: bundle.current.sunriseTime,
                                sunsetTime: bundle.current.sunsetTime,
                                isArabic: isArabic,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                          ),
                        ),
                      ),
                    )
                  : PrayerSectionView(
                      key: const ValueKey('prayer_section'),
                      isArabic: isArabic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

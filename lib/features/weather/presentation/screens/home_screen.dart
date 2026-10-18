import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/design/components/error_state.dart';
import 'package:taqs/core/design/components/loading_state.dart';
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
import 'package:taqs/features/weather/presentation/providers/weather_provider.dart';
import 'package:taqs/features/weather/presentation/widgets/current_weather_card.dart';
import 'package:taqs/features/weather/presentation/widgets/daily_forecast_list.dart';
import 'package:taqs/features/weather/presentation/widgets/hourly_forecast_strip.dart';
import 'package:taqs/features/weather/presentation/widgets/offline_data_banner.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Home screen containing real weather data, location switcher and offline cached status.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final weatherState = ref.watch(weatherViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? AppConstants.appNameAr : AppConstants.appNameEn,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
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
      body: weatherState.when(
        loading: () => const LoadingState(),
        error: (error, _) => ErrorState(
          message: ErrorLocalizer.localize(context, error),
          retryLabel: l10n.retry,
          onRetry: () => ref.read(weatherViewModelProvider.notifier).refresh(),
        ),
        data: (bundle) {
          final alerts = EgyptAlertEvaluator.evaluate(bundle);
          final clothingAdvice = ClothingAdvisor.recommend(bundle);

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(weatherViewModelProvider.notifier).refresh(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
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

                    // Severe Weather Alerts if triggered
                    if (alerts.isNotEmpty) ...[
                      ...alerts.map(
                        (alert) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: SevereWeatherAlertCard(
                            alert: alert,
                            isArabic: isArabic,
                          ),
                        ),
                      ),
                    ],

                    // Current Temperature Card
                    CurrentWeatherCard(
                      weather: bundle.current,
                      isArabic: isArabic,
                      onLocationTap: () =>
                          context.push(AppRoutes.locationSearch),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // What To Wear Today Smart Advice
                    WhatToWearCard(
                      advice: clothingAdvice,
                      isArabic: isArabic,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Air Quality Index (if available from Open-Meteo Air Quality API)
                    if (bundle.airQuality != null) ...[
                      AirQualityCard(
                        airQuality: bundle.airQuality!,
                        isArabic: isArabic,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ] else
                      const SizedBox(height: AppSpacing.md),

                    // Hourly Forecast Section
                    SectionHeader(
                      title: l10n.hourlyForecastTitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    HourlyForecastStrip(hourly: bundle.hourly),
                    const SizedBox(height: AppSpacing.xl),

                    // 7-Day Forecast Section
                    SectionHeader(
                      title: l10n.weeklyForecastTitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DailyForecastList(
                      daily: bundle.daily,
                      isArabic: isArabic,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

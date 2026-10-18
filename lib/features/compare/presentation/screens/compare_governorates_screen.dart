import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/core/design/typography/app_typography.dart';
import 'package:taqs/core/localization/locale_controller.dart';
import 'package:taqs/features/compare/presentation/providers/compare_provider.dart';
import 'package:taqs/features/location/data/repositories/egyptian_governorates.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/presentation/widgets/weather_condition_helper.dart';

/// Screen enabling side-by-side weather and atmospheric comparison between two Egyptian governorates.
class CompareGovernoratesScreen extends ConsumerWidget {
  const CompareGovernoratesScreen({super.key});

  void _showGovernoratePicker(
    BuildContext context,
    WidgetRef ref, {
    required bool isFirst,
    required bool isArabic,
  }) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                isArabic
                    ? (isFirst ? 'اختر المحافظة الأولى' : 'اختر المحافظة الثانية')
                    : (isFirst ? 'Select First Governorate' : 'Select Second Governorate'),
                style: const TextStyle(
                  fontFamily: AppTypography.primaryFontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: EgyptianGovernorates.all.length,
                  separatorBuilder: (_, _) => const Divider(
                    color: AppColors.darkBorderSubtle,
                    height: 1,
                  ),
                  itemBuilder: (_, index) {
                    final gov = EgyptianGovernorates.all[index];
                    return ListTile(
                      title: Text(
                        isArabic ? gov.nameAr : gov.nameEn,
                        style: const TextStyle(
                          fontFamily: AppTypography.primaryFontFamily,
                          color: AppColors.darkTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.cyanAccent,
                      ),
                      onTap: () {
                        if (isFirst) {
                          ref.read(compareSelectionProvider.notifier).setLocation1(gov);
                        } else {
                          ref.read(compareSelectionProvider.notifier).setLocation2(gov);
                        }
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final isArabic = locale.languageCode == 'ar';
    final selection = ref.watch(compareSelectionProvider);
    final weather1Async = ref.watch(compareLocation1WeatherProvider);
    final weather2Async = ref.watch(compareLocation2WeatherProvider);
    final w1 = weather1Async.asData?.value;
    final w2 = weather2Async.asData?.value;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isArabic ? 'مقارنة المحافظات' : 'Compare Governorates',
          style: const TextStyle(
            fontFamily: AppTypography.primaryFontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: AppColors.cyanAccent),
            tooltip: isArabic ? 'تبديل المحافظتين' : 'Swap Locations',
            onPressed: () =>
                ref.read(compareSelectionProvider.notifier).swapLocations(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          children: [
            // Top Location Pickers Bar
            Row(
              children: [
                Expanded(
                  child: _locationChip(
                    context,
                    name: isArabic ? selection.location1.nameAr : selection.location1.nameEn,
                    isArabic: isArabic,
                    onTap: () => _showGovernoratePicker(
                      context,
                      ref,
                      isFirst: true,
                      isArabic: isArabic,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.darkSurfaceElevated,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.compare_arrows,
                      size: 20,
                      color: AppColors.cyanAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: _locationChip(
                    context,
                    name: isArabic ? selection.location2.nameAr : selection.location2.nameEn,
                    isArabic: isArabic,
                    onTap: () => _showGovernoratePicker(
                      context,
                      ref,
                      isFirst: false,
                      isArabic: isArabic,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Difference Banner (if both data sets are ready)
            if (w1 != null && w2 != null)
              _differenceBanner(
                w1,
                w2,
                isArabic: isArabic,
              ),

            const SizedBox(height: 16),

            // Side-by-side Hero Comparison Card
            AppCard(
              borderRadius: AppRadius.borderXl,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _locationColumn(
                      context,
                      weatherAsync: weather1Async,
                      locationName: isArabic ? selection.location1.nameAr : selection.location1.nameEn,
                      isArabic: isArabic,
                      onRetry: () => ref.invalidate(compareLocation1WeatherProvider),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 220,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: AppColors.darkBorderSubtle,
                  ),
                  Expanded(
                    child: _locationColumn(
                      context,
                      weatherAsync: weather2Async,
                      locationName: isArabic ? selection.location2.nameAr : selection.location2.nameEn,
                      isArabic: isArabic,
                      onRetry: () => ref.invalidate(compareLocation2WeatherProvider),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Comparative Metrics Table (if both loaded)
            if (w1 != null && w2 != null)
              _metricsTable(
                weather1: w1,
                weather2: w2,
                isArabic: isArabic,
              ),

            const SizedBox(height: 20),

            // 3-Day Forecast Comparison
            if (w1 != null && w2 != null)
              _threeDayForecastComparison(
                weather1: w1,
                weather2: w2,
                isArabic: isArabic,
              ),
          ],
        ),
      ),
    );
  }

  Widget _locationChip(
    BuildContext context, {
    required String name,
    required bool isArabic,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cyanAccent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, size: 18, color: AppColors.cyanAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTypography.primaryFontFamily,
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.darkTextSecondary),
          ],
        ),
      ),
    );
  }

  Widget _differenceBanner(
    WeatherBundle w1,
    WeatherBundle w2, {
    required bool isArabic,
  }) {
    final diff = w1.current.temperature - w2.current.temperature;
    final city1 = isArabic ? w1.current.cityNameAr : w1.current.cityNameEn;
    final city2 = isArabic ? w2.current.cityNameAr : w2.current.cityNameEn;

    final String text;
    if (diff > 0) {
      text = isArabic
          ? '$city1 أدفأ بـ $diff°م من $city2'
          : '$city1 is $diff°C warmer than $city2';
    } else if (diff < 0) {
      text = isArabic
          ? '$city1 أبرد بـ ${diff.abs()}°م من $city2'
          : '$city1 is ${diff.abs()}°C cooler than $city2';
    } else {
      text = isArabic
          ? 'درجة الحرارة متطابقة تماماً بين المدينتين ($city1 و $city2)'
          : 'Identical temperature between $city1 and $city2';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.metallicGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.metallicGold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.metallicGold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: AppTypography.primaryFontFamily,
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationColumn(
    BuildContext context, {
    required AsyncValue<WeatherBundle> weatherAsync,
    required String locationName,
    required bool isArabic,
    required VoidCallback onRetry,
  }) {
    return weatherAsync.when(
      data: (bundle) {
        final current = bundle.current;
        return Column(
          children: [
            Text(
              locationName,
              style: const TextStyle(
                fontFamily: AppTypography.primaryFontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              WeatherConditionHelper.getIcon(current.condition),
              size: 40,
              color: AppColors.cyanAccent,
            ),
            const SizedBox(height: 6),
            Text(
              '${current.temperature}°',
              style: const TextStyle(
                fontFamily: AppTypography.primaryFontFamily,
                fontSize: 48,
                fontWeight: FontWeight.w300,
                color: AppColors.darkTextPrimary,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isArabic
                  ? WeatherConditionHelper.getLocalizedName(context, current.condition)
                  : current.condition.name,
              style: const TextStyle(
                fontFamily: AppTypography.primaryFontFamily,
                color: AppColors.cyanAccent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              isArabic ? 'الإحساس ${current.feelsLike}°' : 'Feels ${current.feelsLike}°',
              style: const TextStyle(
                fontFamily: AppTypography.primaryFontFamily,
                color: AppColors.darkTextSecondary,
                fontSize: 11,
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.cyanAccent),
        ),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppColors.alertRed, size: 32),
            const SizedBox(height: 8),
            Text(
              isArabic ? 'تعذر تحميل البيانات' : 'Failed to load',
              style: const TextStyle(
                fontFamily: AppTypography.primaryFontFamily,
                color: AppColors.darkTextSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: onRetry,
              child: Text(
                isArabic ? 'إعادة المحاولة' : 'Retry',
                style: const TextStyle(color: AppColors.cyanAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricsTable({
    required WeatherBundle weather1,
    required WeatherBundle weather2,
    required bool isArabic,
  }) {
    final c1 = weather1.current;
    final c2 = weather2.current;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          _metricRow(
            label: isArabic ? 'احتمال الأمطار' : 'Rain Chance',
            val1: '${c1.precipitationProbability}%',
            val2: '${c2.precipitationProbability}%',
            icon: Icons.water_drop_outlined,
            highlight1: c1.precipitationProbability > c2.precipitationProbability,
            highlight2: c2.precipitationProbability > c1.precipitationProbability,
          ),
          const Divider(color: AppColors.darkBorderSubtle),
          _metricRow(
            label: isArabic ? 'سرعة الرياح' : 'Wind Speed',
            val1: '${c1.windSpeedKmh} كم/س',
            val2: '${c2.windSpeedKmh} كم/س',
            icon: Icons.air,
            highlight1: c1.windSpeedKmh > c2.windSpeedKmh,
            highlight2: c2.windSpeedKmh > c1.windSpeedKmh,
          ),
          const Divider(color: AppColors.darkBorderSubtle),
          _metricRow(
            label: isArabic ? 'الرطوبة النسبية' : 'Humidity',
            val1: '${c1.humidityPercentage}%',
            val2: '${c2.humidityPercentage}%',
            icon: Icons.opacity,
          ),
          if (weather1.airQuality != null || weather2.airQuality != null) ...[
            const Divider(color: AppColors.darkBorderSubtle),
            _metricRow(
              label: isArabic ? 'مؤشر جودة الهواء (AQI)' : 'Air Quality (AQI)',
              val1: '${weather1.airQuality?.europeanAqi ?? "-"}',
              val2: '${weather2.airQuality?.europeanAqi ?? "-"}',
              icon: Icons.eco_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricRow({
    required String label,
    required String val1,
    required String val2,
    required IconData icon,
    bool highlight1 = false,
    bool highlight2 = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              val1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.primaryFontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: highlight1 ? AppColors.cyanAccent : AppColors.darkTextPrimary,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.darkTextSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTypography.primaryFontFamily,
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Expanded(
            child: Text(
              val2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.primaryFontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: highlight2 ? AppColors.cyanAccent : AppColors.darkTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _threeDayForecastComparison({
    required WeatherBundle weather1,
    required WeatherBundle weather2,
    required bool isArabic,
  }) {
    final count = weather1.daily.length < weather2.daily.length
        ? weather1.daily.length
        : weather2.daily.length;
    final displayCount = count < 3 ? count : 3;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              isArabic ? 'مقارنة توقعات 3 أيام قادمة' : '3-Day Forecast Comparison',
              style: const TextStyle(
                fontFamily: AppTypography.primaryFontFamily,
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          for (var i = 0; i < displayCount; i++) ...[
            if (i > 0) const Divider(color: AppColors.darkBorderSubtle),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${weather1.daily[i].minTemp}° / ${weather1.daily[i].maxTemp}°',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTypography.primaryFontFamily,
                        color: AppColors.darkTextPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    isArabic ? weather1.daily[i].dayNameAr : weather1.daily[i].dayNameEn,
                    style: const TextStyle(
                      fontFamily: AppTypography.primaryFontFamily,
                      color: AppColors.cyanAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${weather2.daily[i].minTemp}° / ${weather2.daily[i].maxTemp}°',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTypography.primaryFontFamily,
                        color: AppColors.darkTextPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

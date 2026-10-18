import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/core/design/typography/app_typography.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// Comprehensive 6-tile meteorological details grid:
/// Humidity, Wind, UV, Pressure, Visibility, and Precipitation chance.
class WeatherDetailsGrid extends StatelessWidget {
  const WeatherDetailsGrid({
    required this.weather,
    required this.isArabic,
    super.key,
  });

  final CurrentWeather weather;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    // UV interpretation
    final String uvLabel;
    final Color uvColor;
    if (weather.uvIndex <= 2) {
      uvLabel = isArabic ? 'منخفض' : 'Low';
      uvColor = AppColors.cyanAccent;
    } else if (weather.uvIndex <= 5) {
      uvLabel = isArabic ? 'معتدل' : 'Moderate';
      uvColor = AppColors.metallicGold;
    } else if (weather.uvIndex <= 7) {
      uvLabel = isArabic ? 'مرتفع' : 'High';
      uvColor = const Color(0xFFF97316);
    } else {
      uvLabel = isArabic ? 'شديد جداً' : 'Very High';
      uvColor = AppColors.alertRed;
    }

    final tiles = [
      _GridTileData(
        icon: Icons.water_drop_rounded,
        iconColor: AppColors.cyanAccent,
        title: isArabic ? 'الرطوبة النسبية' : 'Humidity',
        value: '${weather.humidityPercentage}%',
        subtitle: isArabic ? 'نسبة بخار الماء في الجو' : 'Relative humidity',
      ),
      _GridTileData(
        icon: Icons.air_rounded,
        iconColor: AppColors.electricBlue,
        title: isArabic ? 'سرعة الرياح' : 'Wind Speed',
        value: '${weather.windSpeedKmh} ${isArabic ? "كم/س" : "km/h"}',
        subtitle: isArabic ? 'رياح معتدلة الاتجاه' : 'Moderate surface wind',
      ),
      _GridTileData(
        icon: Icons.wb_sunny_rounded,
        iconColor: uvColor,
        title: isArabic ? 'مؤشر UV' : 'UV Index',
        value: '${weather.uvIndex}',
        subtitle: uvLabel,
        badgeColor: uvColor,
      ),
      _GridTileData(
        icon: Icons.compress_rounded,
        iconColor: const Color(0xFF38BDF8),
        title: isArabic ? 'الضغط الجوي' : 'Pressure',
        value: '${weather.pressureHpa} ${isArabic ? "هكـ" : "hPa"}',
        subtitle: isArabic ? 'مستوى سطح البحر' : 'Sea-level pressure',
      ),
      _GridTileData(
        icon: Icons.visibility_rounded,
        iconColor: AppColors.cyanAccent,
        title: isArabic ? 'مدى الرؤية' : 'Visibility',
        value: '${weather.visibilityKm.toStringAsFixed(0)} ${isArabic ? "كم" : "km"}',
        subtitle: isArabic ? 'رؤية أفقية واضحة' : 'Clear horizontal sight',
      ),
      _GridTileData(
        icon: Icons.umbrella_rounded,
        iconColor: AppColors.cyanAccent,
        title: isArabic ? 'فرصة الأمطار' : 'Precipitation',
        value: '${weather.precipitationProbability}%',
        subtitle: weather.precipitationProbability > 40
            ? (isArabic ? 'أمطار متوقعة' : 'Rain expected')
            : (isArabic ? 'احتمالية ضعيفة' : 'Low probability'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 520 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.35,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, index) {
            final tile = tiles[index];
            return _DetailTile(data: tile);
          },
        );
      },
    );
  }
}

class _GridTileData {
  const _GridTileData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    this.badgeColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final Color? badgeColor;
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.data});

  final _GridTileData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.borderMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(data.icon, size: 16, color: data.iconColor),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (data.badgeColor != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: data.badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          Text(
            data.value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFeatures: AppTypography.tabularFigures,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

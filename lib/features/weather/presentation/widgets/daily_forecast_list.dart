import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/core/design/typography/app_typography.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/presentation/widgets/weather_condition_helper.dart';

/// 7-day weather forecast list widget with proportional horizontal
/// temperature range bars across the weekly span.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    required this.daily,
    required this.isArabic,
    super.key,
  });

  final List<DailyForecast> daily;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    // Compute global min and max for the week to scale all range bars uniformly
    var weekMin = daily.first.minTemp;
    var weekMax = daily.first.maxTemp;
    for (final day in daily) {
      if (day.minTemp < weekMin) weekMin = day.minTemp;
      if (day.maxTemp > weekMax) weekMax = day.maxTemp;
    }
    final weekSpan = (weekMax - weekMin).clamp(1, 40);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: List.generate(daily.length, (index) {
          final isLast = index == daily.length - 1;
          final item = daily[index];

          return Column(
            children: [
              _DailyForecastRow(
                item: item,
                isArabic: isArabic,
                weekMin: weekMin,
                weekSpan: weekSpan,
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorderSubtle
                      : AppColors.lightBorderSubtle,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _DailyForecastRow extends StatelessWidget {
  const _DailyForecastRow({
    required this.item,
    required this.isArabic,
    required this.weekMin,
    required this.weekSpan,
  });

  final DailyForecast item;
  final bool isArabic;
  final int weekMin;
  final int weekSpan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dayName = isArabic ? item.dayNameAr : item.dayNameEn;
    final icon = WeatherConditionHelper.getIcon(item.condition);
    final iconColor = WeatherConditionHelper.getIconColor(item.condition);

    // Calculate proportional left and right offsets for the temperature range bar
    final startRatio = ((item.minTemp - weekMin) / weekSpan).clamp(0.0, 1.0);
    final endRatio = ((item.maxTemp - weekMin) / weekSpan).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          // Day Name
          SizedBox(
            width: 72,
            child: Text(
              dayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),

          // Weather Icon
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: AppSpacing.md),

          // Min Temperature
          SizedBox(
            width: 28,
            child: Text(
              '${item.minTemp}°',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFeatures: AppTypography.tabularFigures,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Temperature Range Bar
          Expanded(
            child: SizedBox(
              height: 5,
              child: CustomPaint(
                painter: _TemperatureRangeBarPainter(
                  startRatio: startRatio,
                  endRatio: endRatio,
                  isDark: isDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Max Temperature
          SizedBox(
            width: 28,
            child: Text(
              '${item.maxTemp}°',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFeatures: AppTypography.tabularFigures,
                color: isDark
                    ? AppColors.cyanAccent
                    : AppColors.electricBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemperatureRangeBarPainter extends CustomPainter {
  const _TemperatureRangeBarPainter({
    required this.startRatio,
    required this.endRatio,
    required this.isDark,
  });

  final double startRatio;
  final double endRatio;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final trackRadius = Radius.circular(size.height / 2);

    // 1. Background Track
    final trackPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1E293B)
          : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        trackRadius,
      ),
      trackPaint,
    );

    // 2. Active Temperature Range Bar
    final left = size.width * startRatio;
    final right = (size.width * endRatio).clamp(left + size.height, size.width);

    final rangePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.cyanAccent,
          AppColors.metallicGold,
        ],
      ).createShader(Rect.fromLTWH(left, 0, right - left, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left, 0, right, size.height),
        trackRadius,
      ),
      rangePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TemperatureRangeBarPainter oldDelegate) {
    return oldDelegate.startRatio != startRatio ||
        oldDelegate.endRatio != endRatio ||
        oldDelegate.isDark != isDark;
  }
}

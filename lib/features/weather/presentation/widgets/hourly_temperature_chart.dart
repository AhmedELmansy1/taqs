import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/presentation/widgets/weather_condition_helper.dart';

/// Hourly forecast presentation with custom-painted smooth continuous
/// temperature curve, bezier gradient area, and tabular readings.
class HourlyTemperatureChart extends StatelessWidget {
  const HourlyTemperatureChart({
    required this.hourly,
    super.key,
  });

  final List<HourlyForecast> hourly;

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    const slotWidth = 62.0;
    const chartHeight = 155.0;
    final totalWidth = slotWidth * hourly.length;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                const Icon(
                  Icons.show_chart_rounded,
                  size: 16,
                  color: AppColors.cyanAccent,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'التسلسل الحراري خلال 24 ساعة',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.cyanAccent,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: chartHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: totalWidth,
                height: chartHeight,
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: Size(totalWidth, chartHeight),
                    painter: _HourlyCurvePainter(
                      hourly: hourly,
                      slotWidth: slotWidth,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyCurvePainter extends CustomPainter {
  const _HourlyCurvePainter({
    required this.hourly,
    required this.slotWidth,
    required this.isDark,
  });

  final List<HourlyForecast> hourly;
  final double slotWidth;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (hourly.isEmpty) return;

    // 1. Calculate min and max temperatures to normalize curve heights
    var minTemp = hourly.first.temperature;
    var maxTemp = hourly.first.temperature;
    for (final item in hourly) {
      if (item.temperature < minTemp) minTemp = item.temperature;
      if (item.temperature > maxTemp) maxTemp = item.temperature;
    }

    final tempRange = (maxTemp - minTemp).clamp(4, 40).toDouble();

    // Chart Y boundaries: curve lives between y = 30 and y = 85
    const curveTop = 32.0;
    const curveBottom = 82.0;
    const curveHeight = curveBottom - curveTop;

    final points = <Offset>[];
    for (var i = 0; i < hourly.length; i++) {
      final x = (i * slotWidth) + (slotWidth / 2);
      final normalized = (hourly[i].temperature - minTemp) / tempRange;
      final y = curveBottom - (normalized * curveHeight);
      points.add(Offset(x, y));
    }

    // 2. Draw gradient area under the curve
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY1 = p0.dy;
      final controlX2 = controlX1;
      final controlY2 = p1.dy;
      path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, curveBottom + 16)
      ..lineTo(points.first.dx, curveBottom + 16)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.cyanAccent.withValues(alpha: 0.28),
          AppColors.electricBlue.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, curveTop, size.width, curveHeight + 16));

    canvas.drawPath(fillPath, fillPaint);

    // 3. Draw curve line
    final strokePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.cyanAccent,
          AppColors.electricBlueLight,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // 4. Draw points, temperature labels, weather icons, and timestamps
    final pointPaint = Paint()
      ..color = AppColors.cyanAccent
      ..style = PaintingStyle.fill;

    final pointInnerPaint = Paint()
      ..color = isDark ? AppColors.darkSurface : Colors.white
      ..style = PaintingStyle.fill;

    final tempStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );

    final timeStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    );

    for (var i = 0; i < hourly.length; i++) {
      final p = points[i];
      final item = hourly[i];

      // Draw point circle
      canvas
        ..drawCircle(p, 4.5, pointPaint)
        ..drawCircle(p, 2.5, pointInnerPaint);

      // Temperature text above point
      final tempPainter = TextPainter(
        text: TextSpan(
          text: '${item.temperature}°',
          style: tempStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tempPainter.paint(
        canvas,
        Offset(p.dx - (tempPainter.width / 2), p.dy - 20),
      );

      // Time text below
      final timePainter = TextPainter(
        text: TextSpan(
          text: item.time,
          style: timeStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      timePainter.paint(
        canvas,
        Offset(p.dx - (timePainter.width / 2), size.height - 22),
      );

      // Condition icon
      final icon = WeatherConditionHelper.getIcon(item.condition);
      final iconColor = WeatherConditionHelper.getIconColor(item.condition);
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: 16,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            color: iconColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      iconPainter.paint(
        canvas,
        Offset(p.dx - (iconPainter.width / 2), size.height - 46),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HourlyCurvePainter oldDelegate) {
    return oldDelegate.hourly != hourly || oldDelegate.isDark != isDark;
  }
}

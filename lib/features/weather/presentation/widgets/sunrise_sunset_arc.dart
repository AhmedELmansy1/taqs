import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';

/// Celestial sunrise and sunset arc visualization showing sun's solar progress.
class SunriseSunsetArc extends StatelessWidget {
  const SunriseSunsetArc({
    required this.sunriseTime,
    required this.sunsetTime,
    required this.isArabic,
    super.key,
    this.currentTime,
  });

  /// Sunrise time formatted as 'HH:mm'.
  final String sunriseTime;

  /// Sunset time formatted as 'HH:mm'.
  final String sunsetTime;

  final bool isArabic;

  /// Optional override for current time (used in testing).
  final DateTime? currentTime;

  @override
  Widget build(BuildContext context) {
    final now = currentTime ?? DateTime.now();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate progress between sunrise and sunset
    final sunriseParts = sunriseTime.split(':');
    final sunsetParts = sunsetTime.split(':');

    final sunriseMinutes = (int.tryParse(sunriseParts[0]) ?? 6) * 60 +
        (int.tryParse(sunriseParts.length > 1 ? sunriseParts[1] : '0') ?? 0);
    final sunsetMinutes = (int.tryParse(sunsetParts[0]) ?? 18) * 60 +
        (int.tryParse(sunsetParts.length > 1 ? sunsetParts[1] : '0') ?? 0);

    final currentMinutes = now.hour * 60 + now.minute;
    final totalSpan = (sunsetMinutes - sunriseMinutes).clamp(60, 1440);

    final double solarProgress;
    final bool isDay;

    if (currentMinutes < sunriseMinutes) {
      solarProgress = 0;
      isDay = false;
    } else if (currentMinutes > sunsetMinutes) {
      solarProgress = 1;
      isDay = false;
    } else {
      solarProgress = ((currentMinutes - sunriseMinutes) / totalSpan).clamp(0.0, 1.0);
      isDay = true;
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wb_twilight_rounded,
                size: 16,
                color: AppColors.metallicGold,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                isArabic ? 'الشروق والغروب' : 'Sunrise & Sunset',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.metallicGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 90,
            width: double.infinity,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _SunArcPainter(
                  solarProgress: solarProgress,
                  isDay: isDay,
                  isDark: isDark,
                  isRtl: isArabic,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.wb_sunny_outlined,
                        size: 14,
                        color: AppColors.metallicGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isArabic ? 'الشروق' : 'Sunrise',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sunriseTime,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        isArabic ? 'الغروب' : 'Sunset',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.nights_stay_outlined,
                        size: 14,
                        color: AppColors.cyanAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sunsetTime,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  const _SunArcPainter({
    required this.solarProgress,
    required this.isDay,
    required this.isDark,
    required this.isRtl,
  });

  final double solarProgress;
  final bool isDay;
  final bool isDark;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Horizon line
    final horizonPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2D4A) : const Color(0xFFCBD5E1)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, h - 8), Offset(w, h - 8), horizonPaint);

    // Arc path (parabola / semi-ellipse)
    const startX = 16.0;
    final endX = w - 16.0;
    final baseY = h - 8;
    const peakY = 16.0;

    final arcPath = Path()
      ..moveTo(startX, baseY)
      ..quadraticBezierTo(w / 2, peakY - 14, endX, baseY);

    // Draw background dashed/solid arc
    final arcPaint = Paint()
      ..color = isDark ? const Color(0xFF223254) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(arcPath, arcPaint);

    // Effective horizontal progress (considering RTL direction)
    final effectiveProgress = isRtl ? (1.0 - solarProgress) : solarProgress;

    // Quadratic bezier point formula: B(t) = (1-t)^2 P0 + 2(1-t)t P1 + t^2 P2
    final t = effectiveProgress;
    final invT = 1.0 - t;
    final controlX = w / 2;
    const controlY = peakY - 14;

    final sunX = (invT * invT * startX) + (2 * invT * t * controlX) + (t * t * endX);
    final sunY = (invT * invT * baseY) + (2 * invT * t * controlY) + (t * t * baseY);

    // Draw Sun / Moon indicator on arc
    if (isDay) {
      // Sun glow
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.metallicGold.withValues(alpha: 0.4),
            AppColors.metallicGold.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: 18));
      canvas.drawCircle(Offset(sunX, sunY), 18, glowPaint);

      // Sun disc
      final sunPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
        ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: 7));
      canvas.drawCircle(Offset(sunX, sunY), 7, sunPaint);
    } else {
      // Night Moon indicator
      final moonPaint = Paint()
        ..color = AppColors.cyanAccent
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(sunX, sunY), 6, moonPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) {
    return oldDelegate.solarProgress != solarProgress ||
        oldDelegate.isDay != isDay ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isRtl != isRtl;
  }
}

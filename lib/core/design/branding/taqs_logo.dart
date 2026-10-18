import 'package:flutter/material.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';

/// Style variants for the official Taqs logo mark.
enum TaqsLogoVariant {
  /// Full brand colors: Electric Blue to Cyan gradient with Metallic Gold horizon ray.
  fullColor,

  /// Single solid color (configured via the logo's monochromeColor parameter).
  monochrome,
}

/// Official brand logo mark for Taqs (طقس).
///
/// Merges the Arabic letter "ط" with an ascending sun horizon arc,
/// custom-painted for crisp rasterization at any resolution (from 24dp to 1024dp).
class TaqsLogo extends StatelessWidget {
  const TaqsLogo({
    super.key,
    this.size = 64,
    this.variant = TaqsLogoVariant.fullColor,
    this.withBackground = true,
    this.monochromeColor,
    this.borderRadius,
  });

  /// The width and height of the square logo.
  final double size;

  /// Whether to render in full gradient colors or monochrome.
  final TaqsLogoVariant variant;

  /// Whether to render on a deep navy rounded squircle background.
  final bool withBackground;

  /// Tint color for [TaqsLogoVariant.monochrome]. Defaults to white.
  final Color? monochromeColor;

  /// Custom border radius when [withBackground] is true.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(size * 0.22);

    Widget content = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _TaqsLogoPainter(
          variant: variant,
          monochromeColor: monochromeColor ?? Colors.white,
        ),
      ),
    );

    if (withBackground) {
      content = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF0B132B),
              Color(0xFF070D1E),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyanAccent.withValues(alpha: 0.12),
              blurRadius: size * 0.25,
              offset: Offset(0, size * 0.08),
            ),
          ],
          border: Border.all(
            color: AppColors.cyanAccent.withValues(alpha: 0.15),
            width: size * 0.015 > 1 ? size * 0.015 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }

    return Semantics(
      label: 'شعار طقس • Taqs Logo',
      image: true,
      child: content,
    );
  }
}

/// Logo lockup combining the [TaqsLogo] with typographic branding.
class TaqsLogoLockup extends StatelessWidget {
  const TaqsLogoLockup({
    super.key,
    this.logoSize = 48,
    this.isArabic = true,
    this.showTagline = true,
  });

  final double logoSize;
  final bool isArabic;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TaqsLogo(
          size: logoSize,
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? AppConstants.appNameAr : AppConstants.appNameEn,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: isArabic ? 0 : 1.2,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            if (showTagline) ...[
              const SizedBox(height: 2),
              Text(
                isArabic
                    ? 'طقس جمهورية مصر العربية'
                    : 'Egypt Smart Weather',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.cyanAccent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: isArabic ? 0 : 0.5,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _TaqsLogoPainter extends CustomPainter {
  const _TaqsLogoPainter({
    required this.variant,
    required this.monochromeColor,
  });

  final TaqsLogoVariant variant;
  final Color monochromeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final scale = w / 512.0;

    canvas
      ..save()
      ..scale(scale, scale);

    final isFullColor = variant == TaqsLogoVariant.fullColor;

    // Paints
    final Paint sunPaint;
    final Paint primaryPaint;
    final Paint goldStrokePaint;

    if (isFullColor) {
      sunPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
        ).createShader(const Rect.fromLTWH(238, 158, 104, 104));

      primaryPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFF1D4ED8),
            Color(0xFF0284C7),
            Color(0xFF06B6D4),
          ],
        ).createShader(const Rect.fromLTWH(96, 90, 360, 300))
        ..style = PaintingStyle.fill;

      goldStrokePaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
        ).createShader(const Rect.fromLTWH(130, 290, 260, 60))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
    } else {
      sunPaint = Paint()..color = monochromeColor;
      primaryPaint = Paint()
        ..color = monochromeColor
        ..style = PaintingStyle.fill;
      goldStrokePaint = Paint()
        ..color = monochromeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
    }

    // 1. Sun disc
    canvas.drawCircle(const Offset(290, 210), 52, sunPaint);

    // 2. Ascending Mast (ألف الطاء)
    final mastPath = Path()
      ..moveTo(284, 104)
      ..cubicTo(284, 96, 292, 90, 300, 90)
      ..cubicTo(308, 90, 314, 96, 314, 104)
      ..lineTo(314, 260)
      ..cubicTo(314, 268, 308, 274, 300, 274)
      ..cubicTo(292, 274, 284, 268, 284, 260)
      ..close();
    canvas.drawPath(mastPath, primaryPaint);

    // 3. Sweeping Loop of "ط"
    final loopPath = Path()
      ..moveTo(120, 340)
      ..cubicTo(150, 240, 250, 220, 350, 250)
      ..cubicTo(400, 265, 430, 300, 440, 340)
      ..cubicTo(420, 346, 380, 348, 340, 344)
      ..cubicTo(260, 336, 210, 270, 170, 310)
      ..cubicTo(150, 330, 135, 340, 120, 340)
      ..close();
    canvas.drawPath(loopPath, primaryPaint);

    // 4. Horizon Wave Base
    final wavePath = Path()
      ..moveTo(104, 350)
      ..cubicTo(170, 350, 220, 320, 300, 320)
      ..cubicTo(370, 320, 420, 348, 448, 350)
      ..cubicTo(448, 368, 436, 382, 416, 382)
      ..cubicTo(340, 382, 270, 358, 190, 366)
      ..cubicTo(150, 370, 120, 380, 104, 380)
      ..cubicTo(96, 380, 92, 370, 96, 360)
      ..cubicTo(98, 354, 100, 350, 104, 350)
      ..close();
    canvas.drawPath(wavePath, primaryPaint);

    // 5. Horizon Accent Ray
    final accentPath = Path()
      ..moveTo(130, 348)
      ..cubicTo(220, 340, 280, 290, 380, 310);
    canvas.drawPath(accentPath, goldStrokePaint);

    // 6. Subtle celestial stars (fullColor only)
    if (isFullColor) {
      final starPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.7);
      canvas
        ..drawCircle(const Offset(168, 180), 4, starPaint)
        ..drawCircle(const Offset(396, 160), 3, starPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TaqsLogoPainter oldDelegate) {
    return oldDelegate.variant != variant ||
        oldDelegate.monochromeColor != monochromeColor;
  }
}

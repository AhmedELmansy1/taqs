import 'package:flutter/material.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';

/// Style variants for the official Taqs logo mark.
enum TaqsLogoVariant {
  /// Full brand colors: Electric Blue to Cyan with Metallic Gold crescent & accent.
  fullColor,

  /// Single solid color (configured via the logo's monochromeColor parameter).
  monochrome,
}

/// Official brand logo mark for Taqs (طقس).
///
/// Merges the Arabic letter "ط" with an ascending sun horizon arc and golden crescent,
/// representing both weather and prayer times. Custom-painted for crisp rasterization
/// at any resolution (from 24dp to 1024dp).
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
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(size, size),
          painter: _TaqsLogoPainter(
            variant: variant,
            monochromeColor: monochromeColor ?? Colors.white,
          ),
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
              color: AppColors.cyanAccent.withValues(alpha: 0.14),
              blurRadius: size * 0.25,
              offset: Offset(0, size * 0.08),
            ),
          ],
          border: Border.all(
            color: AppColors.cyanAccent.withValues(alpha: 0.18),
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
                    ? 'طقس ومواقيت الصلاة • مصر'
                    : 'Egypt Weather & Prayer Times',
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

    final Paint sunPaint;
    final Paint goldPaint;
    final Paint skyPaint;
    final Paint goldStrokePaint;

    if (isFullColor) {
      sunPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFF1D4ED8),
            Color(0xFF0284C7),
            Color(0xFF06B6D4),
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(const Rect.fromLTWH(226, 174, 108, 108));

      goldPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFDE68A),
            Color(0xFFF59E0B),
            Color(0xFFD97706),
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(const Rect.fromLTWH(220, 176, 60, 140));

      skyPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFF1D4ED8),
            Color(0xFF0284C7),
            Color(0xFF06B6D4),
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(const Rect.fromLTWH(96, 86, 360, 300))
        ..style = PaintingStyle.fill;

      goldStrokePaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
        ).createShader(const Rect.fromLTWH(134, 304, 244, 46))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;
    } else {
      sunPaint = Paint()..color = monochromeColor;
      goldPaint = Paint()..color = monochromeColor;
      skyPaint = Paint()
        ..color = monochromeColor
        ..style = PaintingStyle.fill;
      goldStrokePaint = Paint()
        ..color = monochromeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;
    }

    // 1. Sun disc: Weather solar cycle / Fajr dawn (Electric Blue to Cyan)
    canvas.drawCircle(const Offset(280, 228), 54, sunPaint);

    // 2. Golden Crescent: Islamic Prayer Times & Lunar Hijri cycle
    final crescentPath = Path()
      ..moveTo(276, 176)
      ..cubicTo(242, 184, 218, 214, 220, 250)
      ..cubicTo(222, 284, 246, 312, 280, 316)
      ..cubicTo(252, 308, 234, 282, 236, 252)
      ..cubicTo(238, 220, 258, 190, 276, 176)
      ..close();
    canvas.drawPath(crescentPath, goldPaint);

    // 3. Upright Mast (ألف الطاء) – Minaret finial and vertical dawn ray
    final mastPath = Path()
      ..moveTo(314, 100)
      ..cubicTo(314, 92, 322, 86, 330, 86)
      ..cubicTo(338, 86, 344, 92, 344, 100)
      ..lineTo(344, 266)
      ..cubicTo(344, 274, 338, 280, 330, 280)
      ..cubicTo(322, 280, 314, 274, 314, 266)
      ..close();
    canvas.drawPath(mastPath, skyPaint);

    // 4. Sweeping loop of Arabic letter "ط" & Weather Horizon Wave
    final loopPath = Path()
      ..moveTo(124, 344)
      ..cubicTo(154, 244, 260, 216, 364, 248)
      ..cubicTo(404, 260, 428, 288, 438, 328)
      ..cubicTo(420, 336, 384, 340, 348, 338)
      ..cubicTo(266, 332, 216, 268, 174, 308)
      ..cubicTo(152, 330, 138, 342, 124, 344)
      ..close();
    canvas.drawPath(loopPath, skyPaint);

    // 5. Horizon Wave Base (Egypt Nile / Sea / Desert Horizon)
    final wavePath = Path()
      ..moveTo(104, 354)
      ..cubicTo(180, 354, 236, 328, 320, 328)
      ..cubicTo(386, 328, 430, 350, 448, 354)
      ..cubicTo(448, 370, 436, 382, 416, 382)
      ..cubicTo(340, 382, 274, 360, 196, 368)
      ..cubicTo(154, 372, 124, 382, 106, 382)
      ..cubicTo(98, 382, 94, 372, 98, 362)
      ..cubicTo(100, 357, 102, 354, 104, 354)
      ..close();
    canvas.drawPath(wavePath, skyPaint);

    // 6. Refined Metallic Gold Horizon Accent Line
    final accentPath = Path()
      ..moveTo(134, 350)
      ..cubicTo(220, 344, 286, 304, 378, 320);
    canvas.drawPath(accentPath, goldStrokePaint);

    // 7. Subtle Celestial Stars (fullColor only)
    if (isFullColor) {
      final starPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.65);
      canvas
        ..drawCircle(const Offset(164, 184), 4, starPaint)
        ..drawCircle(const Offset(410, 164), 3.5, starPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TaqsLogoPainter oldDelegate) {
    return oldDelegate.variant != variant ||
        oldDelegate.monochromeColor != monochromeColor;
  }
}

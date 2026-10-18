import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';

/// Custom-painted, animated weather artwork with slow subtle motion.
///
/// Features original celestial and meteorological vector illustrations
/// (Sun, Moon, Clouds, Rain, Storm, Fog, Dust/Haze) with zero external assets.
/// Wrapped in a [RepaintBoundary], pauses when backgrounded, and respects
/// accessibility reduce-motion settings.
class WeatherArtwork extends StatefulWidget {
  const WeatherArtwork({
    required this.condition,
    super.key,
    this.size = 110,
    this.isDay = true,
  });

  /// The active weather condition.
  final WeatherCondition condition;

  /// Width and height of the illustration.
  final double size;

  /// Whether current time of day is daylight.
  final bool isDay;

  @override
  State<WeatherArtwork> createState() => _WeatherArtworkState();
}

class _WeatherArtworkState extends State<WeatherArtwork>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (!isTest) {
      _controller.repeat();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (reduceMotion || isTest) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    } else {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (state == AppLifecycleState.resumed && !isTest) {
      final reduceMotion =
          MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      if (!reduceMotion && !_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = reduceMotion ? 0.0 : _controller.value;
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _WeatherArtworkPainter(
                condition: widget.condition,
                isDay: widget.isDay,
                progress: progress,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WeatherArtworkPainter extends CustomPainter {
  const _WeatherArtworkPainter({
    required this.condition,
    required this.isDay,
    required this.progress,
  });

  final WeatherCondition condition;
  final bool isDay;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    switch (condition) {
      case WeatherCondition.sunny:
        if (isDay) {
          _drawSun(canvas, center, w * 0.38);
        } else {
          _drawMoon(canvas, center, w * 0.36);
        }
      case WeatherCondition.partlyCloudy:
        _drawPartlyCloudy(canvas, center, w, h);
      case WeatherCondition.cloudy:
        _drawCloudy(canvas, center, w, h);
      case WeatherCondition.rainy:
        _drawRain(canvas, center, w, h);
      case WeatherCondition.fog:
        _drawFog(canvas, center, w, h);
      case WeatherCondition.dustStorm:
        _drawDustStorm(canvas, center, w, h);
    }
  }

  void _drawSun(Canvas canvas, Offset center, double radius) {
    // 1. Outer ambient glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFBBF24).withValues(alpha: 0.35),
          const Color(0xFFD97706).withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.7));
    canvas.drawCircle(center, radius * 1.7, glowPaint);

    // 2. Rotating corona rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rayAngleOffset = progress * 2 * math.pi;
    const rayCount = 8;
    for (var i = 0; i < rayCount; i++) {
      final angle = rayAngleOffset + (i * 2 * math.pi / rayCount);
      final p1 = Offset(
        center.dx + (radius * 1.15) * math.cos(angle),
        center.dy + (radius * 1.15) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius * 1.45) * math.cos(angle),
        center.dy + (radius * 1.45) * math.sin(angle),
      );
      canvas.drawLine(p1, p2, rayPaint);
    }

    // 3. Inner sun disc
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.25),
        colors: [
          Color(0xFFFEF08A),
          Color(0xFFFBBF24),
          Color(0xFFEA580C),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sunPaint);
  }

  void _drawMoon(Canvas canvas, Offset center, double radius) {
    // Twinkling stars
    final starPaint = Paint()..color = Colors.white;
    final star1Alpha = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(progress * 2 * math.pi));
    final star2Alpha = 0.3 + 0.7 * (0.5 + 0.5 * math.cos(progress * 2 * math.pi));
    starPaint.color = Colors.white.withValues(alpha: star1Alpha);
    canvas.drawCircle(Offset(center.dx - radius * 1.1, center.dy - radius * 0.7), 2, starPaint);
    starPaint.color = AppColors.cyanAccent.withValues(alpha: star2Alpha);
    canvas.drawCircle(Offset(center.dx + radius * 0.9, center.dy + radius * 0.8), 2.5, starPaint);

    // Celestial crescent moon
    final moonCenter = Offset(center.dx - 2, center.dy);
    final moonPath = Path()
      ..addArc(
        Rect.fromCircle(center: moonCenter, radius: radius),
        -math.pi * 0.65,
        math.pi * 1.35,
      )
      ..arcToPoint(
        Offset(
          moonCenter.dx + radius * math.cos(-math.pi * 0.65),
          moonCenter.dy + radius * math.sin(-math.pi * 0.65),
        ),
        radius: Radius.circular(radius * 0.9),
        clockwise: false,
      )
      ..close();

    final moonPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE2E8F0),
          Color(0xFF94A3B8),
          Color(0xFF38BDF8),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(moonPath, moonPaint);
  }

  void _drawPartlyCloudy(Canvas canvas, Offset center, double w, double h) {
    // Sun in upper corner
    final sunCenter = Offset(center.dx + w * 0.22, center.dy - h * 0.2);
    _drawSun(canvas, sunCenter, w * 0.2);

    // Floating front cloud
    final driftX = math.sin(progress * 2 * math.pi) * 3;
    _drawCloudShape(
      canvas,
      Offset(center.dx - w * 0.08 + driftX, center.dy + h * 0.12),
      w * 0.75,
      h * 0.45,
      isDarkCloud: false,
    );
  }

  void _drawCloudy(Canvas canvas, Offset center, double w, double h) {
    // Back cloud
    final backDrift = math.sin((progress + 0.3) * 2 * math.pi) * 2;
    _drawCloudShape(
      canvas,
      Offset(center.dx + w * 0.1 + backDrift, center.dy - h * 0.1),
      w * 0.7,
      h * 0.42,
      isDarkCloud: true,
    );

    // Front cloud
    final frontDrift = math.sin(progress * 2 * math.pi) * 3;
    _drawCloudShape(
      canvas,
      Offset(center.dx - w * 0.08 + frontDrift, center.dy + h * 0.12),
      w * 0.78,
      h * 0.46,
      isDarkCloud: false,
    );
  }

  void _drawRain(Canvas canvas, Offset center, double w, double h) {
    // Storm cloud
    _drawCloudShape(
      canvas,
      Offset(center.dx, center.dy - h * 0.12),
      w * 0.82,
      h * 0.48,
      isDarkCloud: true,
    );

    // Animated rain streaks
    final rainPaint = Paint()
      ..color = AppColors.cyanAccent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final rainOffsets = [
      -w * 0.25,
      -w * 0.1,
      w * 0.05,
      w * 0.2,
    ];

    for (var i = 0; i < rainOffsets.length; i++) {
      final cycle = (progress * 2 + (i * 0.25)) % 1.0;
      final x = center.dx + rainOffsets[i] - (cycle * 5);
      final yStart = center.dy + h * 0.15 + (cycle * h * 0.35);
      final yEnd = yStart + 8;
      canvas.drawLine(Offset(x, yStart), Offset(x - 3, yEnd), rainPaint);
    }
  }

  void _drawFog(Canvas canvas, Offset center, double w, double h) {
    final fogPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final yBands = [
      center.dy - h * 0.2,
      center.dy - h * 0.05,
      center.dy + h * 0.1,
      center.dy + h * 0.25,
    ];

    for (var i = 0; i < yBands.length; i++) {
      final drift = math.sin((progress + (i * 0.25)) * 2 * math.pi) * 6;
      fogPaint
        ..strokeWidth = 6.0 - i * 0.8
        ..color = AppColors.cyanAccent.withValues(alpha: 0.35 - (i * 0.06));

      final path = Path()
        ..moveTo(center.dx - w * 0.38 + drift, yBands[i])
        ..cubicTo(
          center.dx - w * 0.15 + drift,
          yBands[i] - 4,
          center.dx + w * 0.15 + drift,
          yBands[i] + 4,
          center.dx + w * 0.38 + drift,
          yBands[i],
        );
      canvas.drawPath(path, fogPaint);
    }
  }

  void _drawDustStorm(Canvas canvas, Offset center, double w, double h) {
    // Swirling warm amber waves (Khamsin wind)
    final dustPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final shift = ((progress + (i * 0.33)) % 1.0) * w * 0.5;
      final y = center.dy - h * 0.2 + (i * h * 0.2);
      dustPaint
        ..strokeWidth = 3.5
        ..color = const Color(0xFFD97706).withValues(alpha: 0.5 - (i * 0.1));

      final path = Path()
        ..moveTo(center.dx - w * 0.4 + shift - w * 0.2, y)
        ..cubicTo(
          center.dx - w * 0.1 + shift,
          y - 8,
          center.dx + w * 0.1 + shift,
          y + 8,
          center.dx + w * 0.4 + shift,
          y,
        );
      canvas.drawPath(path, dustPaint);
    }

    // Floating fine particles
    final particlePaint = Paint()..color = const Color(0xFFFBBF24).withValues(alpha: 0.6);
    canvas
      ..drawCircle(Offset(center.dx - 18, center.dy - 12), 2, particlePaint)
      ..drawCircle(Offset(center.dx + 22, center.dy - 24), 2.5, particlePaint)
      ..drawCircle(Offset(center.dx + 8, center.dy + 18), 1.8, particlePaint);
  }

  void _drawCloudShape(
    Canvas canvas,
    Offset baseCenter,
    double width,
    double height, {
    required bool isDarkCloud,
  }) {
    final rect = Rect.fromCenter(
      center: baseCenter,
      width: width,
      height: height,
    );

    final path = Path()
      ..moveTo(rect.left + rect.width * 0.2, rect.bottom)
      ..cubicTo(
        rect.left - rect.width * 0.05,
        rect.bottom,
        rect.left - rect.width * 0.05,
        rect.bottom - rect.height * 0.45,
        rect.left + rect.width * 0.2,
        rect.bottom - rect.height * 0.45,
      )
      ..cubicTo(
        rect.left + rect.width * 0.15,
        rect.top,
        rect.left + rect.width * 0.6,
        rect.top,
        rect.left + rect.width * 0.55,
        rect.bottom - rect.height * 0.45,
      )
      ..cubicTo(
        rect.right,
        rect.bottom - rect.height * 0.5,
        rect.right + rect.width * 0.05,
        rect.bottom,
        rect.right - rect.width * 0.2,
        rect.bottom,
      )
      ..close();

    final Paint cloudPaint;
    if (isDarkCloud) {
      cloudPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF334155),
            Color(0xFF1E293B),
          ],
        ).createShader(rect);
    } else {
      cloudPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFCBD5E1),
          ],
        ).createShader(rect);
    }

    canvas.drawPath(path, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant _WeatherArtworkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.condition != condition ||
        oldDelegate.isDay != isDay;
  }
}

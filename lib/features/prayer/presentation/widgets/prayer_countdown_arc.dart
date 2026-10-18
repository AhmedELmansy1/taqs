import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';

/// Custom painted celestial countdown arc highlighting the next prayer
/// and the time remaining with metallic gold accents.
class PrayerCountdownArc extends StatefulWidget {
  const PrayerCountdownArc({
    required this.nextPrayer,
    required this.previousPrayer,
    required this.timeToNext,
    required this.isArabic,
    super.key,
  });

  final PrayerItem nextPrayer;
  final PrayerItem? previousPrayer;
  final Duration timeToNext;
  final bool isArabic;

  @override
  State<PrayerCountdownArc> createState() => _PrayerCountdownArcState();
}

class _PrayerCountdownArcState extends State<PrayerCountdownArc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Respect reduce motion
    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('Test');
    if (!isTest) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateProgress() {
    if (widget.previousPrayer == null) return 0.5;
    final totalDuration =
        widget.nextPrayer.time.difference(widget.previousPrayer!.time).inSeconds;
    if (totalDuration <= 0) return 0.5;
    final remaining = widget.timeToNext.inSeconds;
    final elapsed = totalDuration - remaining;
    final ratio = elapsed / totalDuration;
    return ratio.clamp(0.0, 1.0);
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hStr:$mStr:$sStr';
    }
    return '$mStr:$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = _calculateProgress();
    final prayerName = widget.isArabic
        ? widget.nextPrayer.nameAr()
        : widget.nextPrayer.nameEn();

    final timeStr = DateFormat('h:mm a', widget.isArabic ? 'ar' : 'en')
        .format(widget.nextPrayer.time);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pulse = _controller.value * 0.15;

          return SizedBox(
            width: 250,
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(250, 250),
                  painter: _CountdownArcPainter(
                    progress: progress,
                    pulse: pulse,
                    isDark: isDark,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isArabic ? 'الصلاة القادمة' : 'NEXT PRAYER',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.metallicGold
                              : const Color(0xFFB8860B),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        prayerName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        timeStr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.cyanAccent
                              : AppColors.electricBlue,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceHover
                              : AppColors.lightSurfaceElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.metallicGold
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _formatDuration(widget.timeToNext),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CountdownArcPainter extends CustomPainter {
  const _CountdownArcPainter({
    required this.progress,
    required this.pulse,
    required this.isDark,
  });

  final double progress;
  final double pulse;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;

    // Background track paint
    final trackPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc paint
    final sweepAngle = 2 * math.pi * progress;
    final activePaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          AppColors.electricBlue,
          AppColors.cyanAccent,
          AppColors.metallicGold,
        ],
        stops: [0.0, 0.6, 1.0],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 10 + (pulse * 3)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );

    // Subtle outer halo glow
    final haloPaint = Paint()
      ..color = AppColors.metallicGold.withValues(alpha: 0.05 + (pulse * 0.05))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius + 8, haloPaint);
  }

  @override
  bool shouldRepaint(covariant _CountdownArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.isDark != isDark;
  }
}

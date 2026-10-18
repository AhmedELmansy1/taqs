import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/design/branding/taqs_logo.dart';

void main() {
  test('generates branding PNG assets from TaqsLogo painter', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // 1. Full 1024x1024 App Icon (for iOS and standard launcher)
    await _renderAndSave(
      size: 1024,
      withBackground: true,
      variant: TaqsLogoVariant.fullColor,
      outputPath: 'assets/branding/app_icon.png',
    );

    // 2. Android Adaptive Icon Foreground (1024x1024 with safe zone)
    await _renderAndSave(
      size: 1024,
      withBackground: false,
      variant: TaqsLogoVariant.fullColor,
      contentScale: 0.65,
      outputPath: 'assets/branding/app_icon_foreground.png',
    );

    // 3. Android Adaptive Icon Background (1024x1024 Deep Navy)
    await _renderBackground(
      size: 1024,
      outputPath: 'assets/branding/app_icon_background.png',
    );

    // 4. Android 13+ Themed Monochrome Icon (1024x1024)
    await _renderAndSave(
      size: 1024,
      withBackground: false,
      variant: TaqsLogoVariant.monochrome,
      contentScale: 0.65,
      outputPath: 'assets/branding/app_icon_monochrome.png',
    );

    // 5. Native Splash Logo (512x512 with transparent background)
    await _renderAndSave(
      size: 512,
      withBackground: false,
      variant: TaqsLogoVariant.fullColor,
      contentScale: 0.85,
      outputPath: 'assets/branding/splash_logo.png',
    );

    // Verify all files exist
    expect(File('assets/branding/app_icon.png').existsSync(), isTrue);
    expect(File('assets/branding/app_icon_foreground.png').existsSync(), isTrue);
    expect(File('assets/branding/app_icon_background.png').existsSync(), isTrue);
    expect(File('assets/branding/app_icon_monochrome.png').existsSync(), isTrue);
    expect(File('assets/branding/splash_logo.png').existsSync(), isTrue);
  });
}

Future<void> _renderAndSave({
  required int size,
  required bool withBackground,
  required TaqsLogoVariant variant,
  required String outputPath,
  double contentScale = 1.0,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
  );

  if (withBackground) {
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        const Offset(1024, 1024),
        [
          const Color(0xFF0F172A),
          const Color(0xFF0B132B),
          const Color(0xFF070D1E),
        ],
        const [0.0, 0.5, 1.0],
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      bgPaint,
    );
  }

  // Draw content scaled
  canvas.save();
  if (contentScale != 1.0) {
    final offset = (size * (1.0 - contentScale)) / 2;
    canvas
      ..translate(offset, offset)
      ..scale(contentScale, contentScale);
  }

  final logoSize = size.toDouble();
  _TaqsLogoPainterTestBridge(variant: variant)
      .paint(canvas, Size(logoSize, logoSize));
  canvas.restore();

  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  final file = File(outputPath);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
}

Future<void> _renderBackground({
  required int size,
  required String outputPath,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
  );

  final bgPaint = Paint()
    ..shader = ui.Gradient.linear(
      Offset.zero,
      const Offset(1024, 1024),
      [
        const Color(0xFF0F172A),
        const Color(0xFF0B132B),
        const Color(0xFF070D1E),
      ],
      const [0.0, 0.5, 1.0],
    );
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    bgPaint,
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  final file = File(outputPath);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
}

class _TaqsLogoPainterTestBridge {
  _TaqsLogoPainterTestBridge({required this.variant});
  final TaqsLogoVariant variant;

  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final scale = w / 512.0;

    canvas
      ..save()
      ..scale(scale, scale);

    final isFullColor = variant == TaqsLogoVariant.fullColor;

    final Paint sunPaint;
    final Paint primaryPaint;
    final Paint goldStrokePaint;

    if (isFullColor) {
      sunPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(290, 158),
          const Offset(290, 262),
          [const Color(0xFFFBBF24), const Color(0xFFD97706)],
        );

      primaryPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(96, 390),
          const Offset(456, 90),
          [
            const Color(0xFF1D4ED8),
            const Color(0xFF0284C7),
            const Color(0xFF06B6D4),
          ],
          const [0.0, 0.5, 1.0],
        )
        ..style = PaintingStyle.fill;

      goldStrokePaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(130, 320),
          const Offset(390, 320),
          const [Color(0xFFFBBF24), Color(0xFFD97706)],
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
    } else {
      sunPaint = Paint()..color = Colors.white;
      primaryPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      goldStrokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
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

    // 3. Loop of the "ط" and atmospheric horizon wave
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
}

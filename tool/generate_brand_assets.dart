import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taqs/core/design/branding/taqs_logo.dart';

void main() {
  test('generates all brand and notification assets from vector logo', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // 1. Full 1024x1024 App Icon (for iOS and standard launcher)
    await _renderAndSave(
      size: 1024,
      withBackground: true,
      variant: TaqsLogoVariant.fullColor,
      outputPath: 'assets/branding/app_icon.png',
    );

    // 2. Android Adaptive Icon Foreground (1024x1024 with 65% safe zone)
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

    // 4. Android 13+ Themed Monochrome Icon (1024x1024 with 65% safe zone)
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

    // 6. Notification Small Icon (Monochrome white silhouette on transparent)
    final notificationDensities = {
      'drawable': 96,
      'drawable-mdpi': 24,
      'drawable-hdpi': 36,
      'drawable-xhdpi': 48,
      'drawable-xxhdpi': 72,
      'drawable-xxxhdpi': 96,
    };

    for (final entry in notificationDensities.entries) {
      await _renderAndSave(
        size: entry.value,
        withBackground: false,
        variant: TaqsLogoVariant.monochrome,
        contentScale: 0.88,
        outputPath: 'android/app/src/main/res/${entry.key}/ic_notification.png',
      );
    }

    // Verify all generated files exist
    expect(File('assets/branding/app_icon.png').existsSync(), isTrue);
    expect(File('assets/branding/app_icon_foreground.png').existsSync(), isTrue);
    expect(File('assets/branding/app_icon_background.png').existsSync(), isTrue);
    expect(File('assets/branding/app_icon_monochrome.png').existsSync(), isTrue);
    expect(File('assets/branding/splash_logo.png').existsSync(), isTrue);
    expect(File('android/app/src/main/res/drawable/ic_notification.png').existsSync(), isTrue);
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
        Offset(size.toDouble(), size.toDouble()),
        [
          const Color(0xFF0F172A),
          const Color(0xFF0B132B),
          const Color(0xFF070D1E),
        ],
        [0.0, 0.5, 1.0],
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
  _paintTaqsLogo(canvas, Size(logoSize, logoSize), variant);
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
      Offset(size.toDouble(), size.toDouble()),
      [
        const Color(0xFF0F172A),
        const Color(0xFF0B132B),
        const Color(0xFF070D1E),
      ],
      [0.0, 0.5, 1.0],
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

void _paintTaqsLogo(Canvas canvas, Size size, TaqsLogoVariant variant) {
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
      ..shader = ui.Gradient.linear(
        const Offset(226, 282),
        const Offset(334, 174),
        [
          const Color(0xFF1D4ED8),
          const Color(0xFF0284C7),
          const Color(0xFF06B6D4),
        ],
        [0.0, 0.5, 1.0],
      );

    goldPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(220, 176),
        const Offset(280, 316),
        [
          const Color(0xFFFDE68A),
          const Color(0xFFF59E0B),
          const Color(0xFFD97706),
        ],
        [0.0, 0.5, 1.0],
      );

    skyPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(96, 386),
        const Offset(456, 86),
        [
          const Color(0xFF1D4ED8),
          const Color(0xFF0284C7),
          const Color(0xFF06B6D4),
        ],
        [0.0, 0.5, 1.0],
      )
      ..style = PaintingStyle.fill;

    goldStrokePaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(134, 350),
        const Offset(378, 320),
        [
          const Color(0xFFFDE68A),
          const Color(0xFFD97706),
        ],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
  } else {
    sunPaint = Paint()..color = Colors.white;
    goldPaint = Paint()..color = Colors.white;
    skyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    goldStrokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
  }

  // 1. Sun disc
  canvas.drawCircle(const Offset(280, 228), 54, sunPaint);

  // 2. Golden Crescent
  final crescentPath = Path()
    ..moveTo(276, 176)
    ..cubicTo(242, 184, 218, 214, 220, 250)
    ..cubicTo(222, 284, 246, 312, 280, 316)
    ..cubicTo(252, 308, 234, 282, 236, 252)
    ..cubicTo(238, 220, 258, 190, 276, 176)
    ..close();
  canvas.drawPath(crescentPath, goldPaint);

  // 3. Upright Mast (ألف الطاء)
  final mastPath = Path()
    ..moveTo(314, 100)
    ..cubicTo(314, 92, 322, 86, 330, 86)
    ..cubicTo(338, 86, 344, 92, 344, 100)
    ..lineTo(344, 266)
    ..cubicTo(344, 274, 338, 280, 330, 280)
    ..cubicTo(322, 280, 314, 274, 314, 266)
    ..close();
  canvas.drawPath(mastPath, skyPaint);

  // 4. Sweeping loop of 'ط'
  final loopPath = Path()
    ..moveTo(124, 344)
    ..cubicTo(154, 244, 260, 216, 364, 248)
    ..cubicTo(404, 260, 428, 288, 438, 328)
    ..cubicTo(420, 336, 384, 340, 348, 338)
    ..cubicTo(266, 332, 216, 268, 174, 308)
    ..cubicTo(152, 330, 138, 342, 124, 344)
    ..close();
  canvas.drawPath(loopPath, skyPaint);

  // 5. Horizon Wave Base
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

  // 7. Subtle Celestial Stars
  if (isFullColor) {
    final starPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.65);
    canvas
      ..drawCircle(const Offset(164, 184), 4, starPaint)
      ..drawCircle(const Offset(410, 164), 3.5, starPaint);
  }

  canvas.restore();
}

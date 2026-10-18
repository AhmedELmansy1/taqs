import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('renders candidate marks at 48px, 96px, and 1024px', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final sizes = [48, 96, 1024];

    for (final size in sizes) {
      await _renderCandidate(
        size: size,
        drawFunc: _drawCandidateA,
        outputPath: 'assets/branding/candidates/candidate_a_${size}px.png',
      );
      await _renderCandidate(
        size: size,
        drawFunc: _drawCandidateB,
        outputPath: 'assets/branding/candidates/candidate_b_${size}px.png',
      );
      await _renderCandidate(
        size: size,
        drawFunc: _drawCandidateC,
        outputPath: 'assets/branding/candidates/candidate_c_${size}px.png',
      );
    }

    for (final size in sizes) {
      expect(
        File('assets/branding/candidates/candidate_a_${size}px.png').existsSync(),
        isTrue,
      );
      expect(
        File('assets/branding/candidates/candidate_b_${size}px.png').existsSync(),
        isTrue,
      );
      expect(
        File('assets/branding/candidates/candidate_c_${size}px.png').existsSync(),
        isTrue,
      );
    }
  });
}

Future<void> _renderCandidate({
  required int size,
  required void Function(Canvas canvas, Size size) drawFunc,
  required String outputPath,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
  );

  drawFunc(canvas, Size(size.toDouble(), size.toDouble()));

  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  final file = File(outputPath);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
}

void _drawCandidateA(Canvas canvas, Size size) {
  final s = size.width / 512.0;
  canvas.save();
  canvas.scale(s, s);

  // Background
  final bg = Paint()..color = const Color(0xFF0B132B);
  canvas.drawRRect(
    RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 512, 512), const Radius.circular(112)),
    bg,
  );

  // Sun
  final sun = Paint()
    ..shader = ui.Gradient.linear(
      const Offset(256, 164),
      const Offset(256, 316),
      [const Color(0xFF0284C7), const Color(0xFF38BDF8)],
    );
  canvas.drawCircle(const Offset(256, 240), 76, sun);

  // Crescent
  final crescent = Paint()
    ..shader = ui.Gradient.linear(
      Offset.zero,
      const Offset(512, 512),
      [const Color(0xFFFCD34D), const Color(0xFFD97706)],
    );
  final cPath = Path()
    ..moveTo(230, 148)
    ..cubicTo(300, 156, 348, 214, 344, 286)
    ..cubicTo(340, 346, 294, 394, 228, 402)
    ..cubicTo(298, 388, 344, 326, 332, 254)
    ..cubicTo(322, 198, 280, 156, 230, 148)
    ..close();
  canvas.drawPath(cPath, crescent);

  // Horizon
  final hPaint = Paint()..color = const Color(0xFF38BDF8);
  canvas.drawRRect(
    RRect.fromRectAndRadius(const Rect.fromLTWH(112, 336, 288, 22), const Radius.circular(11)),
    hPaint,
  );

  canvas.restore();
}

void _drawCandidateB(Canvas canvas, Size size) {
  final s = size.width / 512.0;
  canvas.save();
  canvas.scale(s, s);

  // Background
  final bg = Paint()..color = const Color(0xFF0B132B);
  canvas.drawRRect(
    RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 512, 512), const Radius.circular(112)),
    bg,
  );

  final sky = Paint()
    ..shader = ui.Gradient.linear(
      const Offset(0, 512),
      const Offset(512, 0),
      [const Color(0xFF1D4ED8), const Color(0xFF0284C7), const Color(0xFF06B6D4)],
      [0.0, 0.5, 1.0],
    );

  final gold = Paint()
    ..shader = ui.Gradient.linear(
      Offset.zero,
      const Offset(512, 512),
      [const Color(0xFFFDE68A), const Color(0xFFF59E0B), const Color(0xFFD97706)],
      [0.0, 0.5, 1.0],
    );

  // Sun
  canvas.drawCircle(const Offset(280, 228), 54, sky);

  // Crescent
  final cPath = Path()
    ..moveTo(276, 176)
    ..cubicTo(242, 184, 218, 214, 220, 250)
    ..cubicTo(222, 284, 246, 312, 280, 316)
    ..cubicTo(252, 308, 234, 282, 236, 252)
    ..cubicTo(238, 220, 258, 190, 276, 176)
    ..close();
  canvas.drawPath(cPath, gold);

  // Mast of 'ط'
  final mast = Path()
    ..moveTo(314, 100)
    ..cubicTo(314, 92, 322, 86, 330, 86)
    ..cubicTo(338, 86, 344, 92, 344, 100)
    ..lineTo(344, 266)
    ..cubicTo(344, 274, 338, 280, 330, 280)
    ..cubicTo(322, 280, 314, 274, 314, 266)
    ..close();
  canvas.drawPath(mast, sky);

  // Loop of 'ط'
  final loop = Path()
    ..moveTo(124, 344)
    ..cubicTo(154, 244, 260, 216, 364, 248)
    ..cubicTo(404, 260, 428, 288, 438, 328)
    ..cubicTo(420, 336, 384, 340, 348, 338)
    ..cubicTo(266, 332, 216, 268, 174, 308)
    ..cubicTo(152, 330, 138, 342, 124, 344)
    ..close();
  canvas.drawPath(loop, sky);

  // Base wave
  final wave = Path()
    ..moveTo(104, 354)
    ..cubicTo(180, 354, 236, 328, 320, 328)
    ..cubicTo(386, 328, 430, 350, 448, 354)
    ..cubicTo(448, 370, 436, 382, 416, 382)
    ..cubicTo(340, 382, 274, 360, 196, 368)
    ..cubicTo(154, 372, 124, 382, 106, 382)
    ..cubicTo(98, 382, 94, 372, 98, 362)
    ..cubicTo(100, 357, 102, 354, 104, 354)
    ..close();
  canvas.drawPath(wave, sky);

  // Gold accent ray
  final goldStroke = Paint()
    ..shader = ui.Gradient.linear(
      const Offset(134, 350),
      const Offset(378, 320),
      [const Color(0xFFFDE68A), const Color(0xFFD97706)],
    )
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6
    ..strokeCap = StrokeCap.round;
  final accent = Path()
    ..moveTo(134, 350)
    ..cubicTo(220, 344, 286, 304, 378, 320);
  canvas.drawPath(accent, goldStroke);

  canvas.restore();
}

void _drawCandidateC(Canvas canvas, Size size) {
  final s = size.width / 512.0;
  canvas.save();
  canvas.scale(s, s);

  // Background
  final bg = Paint()..color = const Color(0xFF0B132B);
  canvas.drawRRect(
    RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 512, 512), const Radius.circular(112)),
    bg,
  );

  final gold = Paint()
    ..shader = ui.Gradient.linear(
      Offset.zero,
      const Offset(512, 512),
      [const Color(0xFFFDE68A), const Color(0xFFF59E0B), const Color(0xFFD97706)],
      [0.0, 0.5, 1.0],
    );

  final sky = Paint()
    ..shader = ui.Gradient.linear(
      Offset.zero,
      const Offset(0, 512),
      [const Color(0xFF38BDF8), const Color(0xFF1D4ED8)],
    );

  // Arch
  final arch = Path()
    ..moveTo(256, 96)
    ..cubicTo(262, 108, 300, 162, 344, 196)
    ..cubicTo(368, 214, 380, 240, 380, 272)
    ..lineTo(380, 392)
    ..cubicTo(380, 402, 372, 410, 362, 410)
    ..lineTo(334, 410)
    ..cubicTo(324, 410, 316, 402, 316, 392)
    ..lineTo(316, 288)
    ..cubicTo(316, 268, 304, 246, 286, 234)
    ..cubicTo(268, 222, 256, 208, 256, 208)
    ..cubicTo(256, 208, 244, 222, 226, 234)
    ..cubicTo(208, 246, 196, 268, 196, 288)
    ..lineTo(196, 392)
    ..cubicTo(196, 402, 188, 410, 178, 410)
    ..lineTo(150, 410)
    ..cubicTo(140, 410, 132, 402, 132, 392)
    ..lineTo(132, 272)
    ..cubicTo(132, 214, 144, 214, 168, 196)
    ..cubicTo(212, 162, 250, 108, 256, 96)
    ..close();
  canvas.drawPath(arch, gold);

  // Sun
  canvas.drawCircle(const Offset(256, 276), 64, sky);

  canvas.restore();
}

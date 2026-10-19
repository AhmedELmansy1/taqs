import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taqs/features/prayer/data/takbeerat_texts.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';
import 'package:taqs/features/prayer/domain/services/eid_detector.dart';

/// Service responsible for rendering and caching rich notification card images
/// using headless Canvas and PictureRecorder.
class TakbeeratCardImageService {
  const TakbeeratCardImageService._();

  static const String _folderName = 'takbeerat_cards';

  /// Renders a rich notification card image and returns its absolute file path.
  ///
  /// Cleans up previously cached cards to prevent disk growth.
  /// Falls back gracefully to `null` if file I/O or rendering fails.
  static Future<String?> generateCardImage({
    required PrayerType prayerType,
    required bool isArabic,
    required int leadTimeMinutes,
    EidPeriod eidPeriod = EidPeriod.none,
  }) async {
    try {
      final dir = await _getCacheDirectory();
      await _cleanOldImages(dir);

      final isEid = eidPeriod.isEid;
      final fileName =
          'card_${prayerType.name}_${isEid ? 'eid' : 'preadhan'}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$fileName');

      const width = 800.0;
      const height = 400.0;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        const Rect.fromLTWH(0, 0, width, height),
      );

      // 1. Navy Background Gradient
      final bgPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          const Offset(width, height),
          [
            const Color(0xFF0F1B36),
            const Color(0xFF0B132B),
            const Color(0xFF070D1E),
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, width, height),
        bgPaint,
      );

      // 2. Subtle Golden Frame
      final framePaint = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(16, 16, width - 32, height - 32),
          const Radius.circular(24),
        ),
        framePaint,
      );

      // 3. Golden Crescent Accent in upper corner
      final crescentPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(680, 40),
          const Offset(760, 120),
          [const Color(0xFFFDE68A), const Color(0xFFD97706)],
        );
      final crescent = Path()
        ..moveTo(740, 50)
        ..cubicTo(710, 56, 690, 80, 692, 110)
        ..cubicTo(694, 138, 714, 160, 742, 164)
        ..cubicTo(720, 156, 706, 136, 708, 112)
        ..cubicTo(710, 86, 726, 62, 740, 50)
        ..close();
      canvas.drawPath(crescent, crescentPaint);

      // Star next to crescent
      final starPaint = Paint()..color = const Color(0xFFFDE68A);
      canvas.drawCircle(const Offset(680, 60), 4, starPaint);

      // 4. Header Badge / Title
      final prayerName = isArabic ? prayerType.nameAr() : prayerType.nameEn();
      final headerText = isEid
          ? (EidDetector.getEidLabel(eidPeriod, isArabic: isArabic) ?? 'Eid Takbeerat')
          : (isArabic
              ? (leadTimeMinutes == 0
                  ? 'حان الآن أذان $prayerName'
                  : 'اقترب أذان $prayerName • متبقي $leadTimeMinutes دقائق')
              : (leadTimeMinutes == 0
                  ? '$prayerName Adhan Now'
                  : '$prayerName in $leadTimeMinutes minutes'));

      TextPainter(
        text: TextSpan(
          text: headerText,
          style: const TextStyle(
            color: Color(0xFFFDE68A),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
      )
        ..layout(maxWidth: 620)
        ..paint(canvas, const Offset(40, 42));

      // 5. Takbeerat Main Text
      final mainTakbeer = isEid
          ? (isArabic
              ? TakbeeratTexts.eidTakbeerConciseAr
              : TakbeeratTexts.eidTakbeerConciseEn)
          : (isArabic
              ? TakbeeratTexts.preAdhanTakbeerAr
              : TakbeeratTexts.preAdhanTakbeerEn);

      final takbeerPainter = TextPainter(
        text: TextSpan(
          text: mainTakbeer,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 1.6,
          ),
        ),
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 720);
      takbeerPainter.paint(
        canvas,
        Offset((width - takbeerPainter.width) / 2, 130),
      );

      // 6. Subtitle / Guidance
      final subtitle = isEid
          ? (isArabic
              ? TakbeeratTexts.eidGreetingAr
              : TakbeeratTexts.eidGreetingEn)
          : (isArabic
              ? TakbeeratTexts.preAdhanPreparationAr
              : TakbeeratTexts.preAdhanPreparationEn);

      final subPainter = TextPainter(
        text: TextSpan(
          text: subtitle,
          style: TextStyle(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.9),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 720);
      subPainter.paint(
        canvas,
        Offset((width - subPainter.width) / 2, 330),
      );

      // Save to PNG file
      final picture = recorder.endRecording();
      final image = await picture.toImage(width.toInt(), height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      return file.path;
    } on Object catch (e) {
      debugPrint('TakbeeratCardImageService error: $e');
      return null;
    }
  }

  static Future<Directory> _getCacheDirectory() async {
    Directory baseDir;
    try {
      baseDir = await getApplicationSupportDirectory();
    } on Object catch (_) {
      baseDir = Directory.systemTemp;
    }
    final folder = Directory('${baseDir.path}/$_folderName');
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }
    return folder;
  }

  static Future<void> _cleanOldImages(Directory dir) async {
    try {
      if (!dir.existsSync()) return;
      final entities = dir.listSync();
      final now = DateTime.now();
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.png')) {
          final stat = entity.statSync();
          // Remove files older than 24 hours
          if (now.difference(stat.modified) > const Duration(hours: 24)) {
            try {
              entity.deleteSync();
            } on Object catch (_) {}
          }
        }
      }
    } on Object catch (_) {}
  }
}

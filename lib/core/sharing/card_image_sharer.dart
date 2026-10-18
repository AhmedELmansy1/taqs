import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Utility service to render a [RepaintBoundary] widget into a crisp PNG image and share it.
class CardImageSharer {
  const CardImageSharer._();

  /// Captures widget under [repaintBoundaryKey] and opens system share sheet.
  static Future<bool> captureAndShare({
    required GlobalKey repaintBoundaryKey,
    required String fileName,
    String? shareText,
  }) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return false;

      // 3x pixel ratio for high DPI crispness on WhatsApp/Telegram/Facebook
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes, flush: true);

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: shareText,
        ),
      );

      return result.status == ShareResultStatus.success;
    } on Object catch (e) {
      debugPrint('CardImageSharer error: $e');
      return false;
    }
  }
}

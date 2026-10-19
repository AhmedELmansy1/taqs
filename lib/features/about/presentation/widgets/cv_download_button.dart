import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Button that displays "Download CV" ONLY if Ahmed_Elmansy_CV.pdf is bundled.
///
/// Safely probes the asset bundle and hides itself completely if not present.
/// When tapped, extracts the PDF to the app's cache directory and invokes
/// the native share/view sheet with a minimum 48dp accessible tap target.
class CvDownloadButton extends StatefulWidget {
  const CvDownloadButton({
    super.key,
    this.isArabic = true,
  });

  final bool isArabic;

  static const String cvAssetPath = 'assets/docs/Ahmed_Elmansy_CV.pdf';

  @override
  State<CvDownloadButton> createState() => _CvDownloadButtonState();
}

class _CvDownloadButtonState extends State<CvDownloadButton> {
  bool _isAvailable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    unawaited(_checkAssetExistence());
  }

  Future<void> _checkAssetExistence() async {
    try {
      final data = await rootBundle.load(CvDownloadButton.cvAssetPath);
      if (data.lengthInBytes > 0 && mounted) {
        setState(() => _isAvailable = true);
      }
    } on Object catch (_) {
      if (mounted) {
        setState(() => _isAvailable = false);
      }
    }
  }

  Future<void> _handleDownload(BuildContext context) async {
    if (_isLoading) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isLoading = true);

    try {
      final byteData = await rootBundle.load(CvDownloadButton.cvAssetPath);
      final tempDir = await getTemporaryDirectory();
      final targetFile = File('${tempDir.path}/Ahmed_Elmansy_CV.pdf');

      await targetFile.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
        flush: true,
      );

      final xFile = XFile(
        targetFile.path,
        mimeType: 'application/pdf',
        name: 'Ahmed_Elmansy_CV.pdf',
      );

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: widget.isArabic
              ? 'السيرة الذاتية - م. أحمد المنسي'
              : 'Ahmed Elmansy - Software Engineer CV',
        ),
      );

      if (mounted && result.status == ShareResultStatus.success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.cvDownloaded),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on Object catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.cvDownloadError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: l10n.downloadCv,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : () => unawaited(_handleDownload(context)),
            borderRadius: AppRadius.borderPill,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFFF59E0B).withValues(alpha: 0.18),
                          const Color(0xFF0F1B36),
                        ]
                      : [
                          const Color(0xFFFFFBEB),
                          const Color(0xFFFEF3C7),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.borderPill,
                border: Border.all(
                  color: AppColors.metallicGold.withValues(alpha: 0.7),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.metallicGold.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.metallicGold,
                        ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: AppColors.metallicGold,
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      l10n.downloadCv,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isDark
                            ? AppColors.metallicGold
                            : const Color(0xFF92400E),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

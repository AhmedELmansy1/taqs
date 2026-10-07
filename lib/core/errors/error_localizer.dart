import 'package:flutter/material.dart';
import 'package:taqs/core/errors/app_failure.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Helper to map domain failures into human-friendly localized messages.
abstract final class ErrorLocalizer {
  static String localize(BuildContext context, Object? error) {
    final l10n = AppLocalizations.of(context);

    if (error is NoConnectionFailure) {
      return l10n.localeName == 'ar'
          ? 'لا يوجد اتصال بالإنترنت. يُرجى التحقق من شبكتك والمحاولة مجدداً.'
          : 'No internet connection. Please check your network and try again.';
    }

    if (error is TimeoutFailure) {
      return l10n.localeName == 'ar'
          ? 'استغرقت الاستجابة وقتاً أطول من المتوقع. يُرجى إعادة المحاولة.'
          : 'The server took too long to respond. Please try again.';
    }

    if (error is ServerFailure) {
      return l10n.localeName == 'ar'
          ? 'حدث خطأ في خادم بيانات الطقس (${error.statusCode}). يُرجى المحاولة لاحقاً.'
          : 'Weather server error (${error.statusCode}). Please try again later.';
    }

    if (error is LocationPermissionDeniedFailure ||
        error is LocationPermissionPermanentlyDeniedFailure) {
      return l10n.locationPermissionRationale;
    }

    return l10n.errorStateMessage;
  }
}

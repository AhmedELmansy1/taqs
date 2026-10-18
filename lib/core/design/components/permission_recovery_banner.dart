import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/core/permissions/location_service.dart';
import 'package:taqs/features/location/presentation/providers/location_controller.dart';

/// Non-intrusive, dismissible permission recovery banner shown when
/// critical permissions (location or notifications) are missing.
class PermissionRecoveryBanner extends ConsumerStatefulWidget {
  const PermissionRecoveryBanner({super.key});

  @override
  ConsumerState<PermissionRecoveryBanner> createState() =>
      _PermissionRecoveryBannerState();
}

class _PermissionRecoveryBannerState
    extends ConsumerState<PermissionRecoveryBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final locationState = ref.watch(locationControllerProvider);
    final status = locationState.permissionStatus;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Only surface if location is missing or denied
    final isMissing = status == LocationPermissionStatus.denied ||
        status == LocationPermissionStatus.deniedForever ||
        status == LocationPermissionStatus.serviceDisabled;

    if (!isMissing) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        backgroundColor: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderColor: AppColors.cyanAccent.withValues(alpha: 0.3),
        borderRadius: AppRadius.borderMd,
        child: Row(
          children: [
            const Icon(
              Icons.location_off_rounded,
              size: 20,
              color: AppColors.cyanAccent,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                isArabic
                    ? 'فعل إذن الموقع للحصول على طقس حقيقي لمكانك'
                    : 'Enable location for accurate local weather',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            TextButton(
              onPressed: () async {
                unawaited(HapticFeedback.lightImpact());
                if (status == LocationPermissionStatus.deniedForever) {
                  await ref.read(locationServiceProvider).openAppSettings();
                } else if (status == LocationPermissionStatus.serviceDisabled) {
                  await ref
                      .read(locationServiceProvider)
                      .openLocationSettings();
                } else {
                  await ref
                      .read(locationControllerProvider.notifier)
                      .requestCurrentGpsLocation();
                }
              },
              child: Text(
                isArabic ? 'تفعيل' : 'Enable',
                style: const TextStyle(
                  color: AppColors.cyanAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 16),
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => setState(() => _dismissed = true),
            ),
          ],
        ),
      ),
    );
  }
}

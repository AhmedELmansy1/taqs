import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/weather/presentation/controllers/farmer_mode_controller.dart';

/// Settings toggle card for activating agricultural Farmer Mode.
class FarmerModeCard extends ConsumerWidget {
  const FarmerModeCard({
    required this.isArabic,
    super.key,
  });

  final bool isArabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFarmerMode = ref.watch(farmerModeControllerProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                  borderRadius: AppRadius.borderMd,
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  isArabic ? 'الوضع الزراعي' : 'Farmer Mode',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: const Color(0xFF4CAF50),
            title: Text(
              isArabic ? 'تفعيل بطاقة المزارع' : 'Enable Agricultural Card',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              isArabic
                  ? 'عرض مؤشرات الصقيع، البخر اليومي (ET0)، رطوبة وحرارة التربة في الشاشة الرئيسية'
                  : 'Display frost risk, daily ET0 evapotranspiration, and soil metrics on Home',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            value: isFarmerMode,
            onChanged: (val) {
              unawaited(HapticFeedback.selectionClick());
              unawaited(
                ref
                    .read(farmerModeControllerProvider.notifier)
                    .setFarmerMode(enabled: val),
              );
            },
          ),
        ],
      ),
    );
  }
}

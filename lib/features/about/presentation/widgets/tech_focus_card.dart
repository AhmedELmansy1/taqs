import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';

/// Interactive card visualizing the developer's core tri-pillar technical intersection:
/// Flutter × AI × Cybersecurity.
class TechFocusCard extends StatelessWidget {
  const TechFocusCard({
    required this.isArabic,
    super.key,
  });

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = [
      (
        icon: Icons.flutter_dash,
        color: AppColors.electricBlue,
        title: isArabic ? 'تطوير فلاتر' : 'Flutter Mobile',
        desc: isArabic
            ? 'معمارية نظيفة، إدارة حالة احترافية، وأداء عالي'
            : 'Clean Architecture, Riverpod, high 60fps performance',
      ),
      (
        icon: Icons.auto_awesome,
        color: AppColors.cyanAccent,
        title: isArabic ? 'الذكاء الاصطناعي' : 'Artificial Intelligence',
        desc: isArabic
            ? 'نماذج الذكاء الاصطناعي، الرؤية الحاسوبية، وتطبيقات Gemini'
            : 'AI/ML models, Computer Vision, Gemini APIs',
      ),
      (
        icon: Icons.security_rounded,
        color: AppColors.metallicGold,
        title: isArabic ? 'الأمن والأدلة الرقمية' : 'Cybersecurity',
        desc: isArabic
            ? 'أمن المعلومات، الأدلة الجنائية الرقمية، واختبار الأمان'
            : 'Information Security, Digital Forensics, OWASP standards',
      ),
    ];

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.cyanAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  size: 18,
                  color: AppColors.cyanAccent,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isArabic ? 'التركيز التقني والهندسي' : 'Technical Focus Areas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((item) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: _PillarTile(
                          icon: item.icon,
                          color: item.color,
                          title: item.title,
                          desc: item.desc,
                          isDark: isDark,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }

              return Column(
                children: items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _PillarTile(
                      icon: item.icon,
                      color: item.color,
                      title: item.title,
                      desc: item.desc,
                      isDark: isDark,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PillarTile extends StatelessWidget {
  const _PillarTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceHover.withValues(alpha: 0.4)
            : AppColors.lightSurfaceElevated,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/weather/presentation/controllers/home_tab_controller.dart';

/// Premium segmented switch allowing instantaneous switching between
/// Weather and Prayer Times with a sliding animated indicator.
class HomeSegmentedHeader extends StatelessWidget {
  const HomeSegmentedHeader({
    required this.selectedTab,
    required this.onTabChanged,
    required this.isArabic,
    super.key,
  });

  final HomeTab selectedTab;
  final ValueChanged<HomeTab> onTabChanged;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWeather = selectedTab == HomeTab.weather;

    return Semantics(
      label: isArabic
          ? 'التبديل بين الطقس ومواقيت الصلاة'
          : 'Switch between Weather and Prayer Times',
      child: Container(
        height: 52,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceElevated.withValues(alpha: 0.8)
              : AppColors.lightSurfaceElevated,
          borderRadius: AppRadius.borderPill,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = (constraints.maxWidth - 4) / 2;

            return Stack(
              children: [
                // Animated sliding indicator
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  alignment: isWeather
                      ? (isArabic ? Alignment.centerRight : Alignment.centerLeft)
                      : (isArabic ? Alignment.centerLeft : Alignment.centerRight),
                  child: Container(
                    width: tabWidth,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: isWeather
                          ? LinearGradient(
                              colors: [
                                AppColors.electricBlue,
                                AppColors.cyanAccent.withValues(alpha: 0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [
                                AppColors.metallicGold,
                                Color(0xFFD4AF37),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: AppRadius.borderPill,
                      boxShadow: [
                        BoxShadow(
                          color: (isWeather
                                  ? AppColors.cyanAccent
                                  : AppColors.metallicGold)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // Button options
                Row(
                  children: [
                    // Weather Option
                    Expanded(
                      child: _TabButton(
                        label: isArabic ? 'الطقس' : 'Weather',
                        icon: Icons.wb_cloudy_outlined,
                        isSelected: isWeather,
                        activeTextColor: Colors.white,
                        inactiveTextColor: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        onTap: () {
                          if (!isWeather) {
                            unawaited(HapticFeedback.selectionClick());
                            onTabChanged(HomeTab.weather);
                          }
                        },
                      ),
                    ),

                    // Prayer Times Option
                    Expanded(
                      child: _TabButton(
                        label: isArabic ? 'مواقيت الصلاة' : 'Prayer Times',
                        icon: Icons.mosque_outlined,
                        isSelected: !isWeather,
                        activeTextColor: const Color(0xFF0B111E),
                        inactiveTextColor: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        onTap: () {
                          if (isWeather) {
                            unawaited(HapticFeedback.selectionClick());
                            onTabChanged(HomeTab.prayer);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeTextColor,
    required this.inactiveTextColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderPill,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? activeTextColor : inactiveTextColor,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? activeTextColor : inactiveTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

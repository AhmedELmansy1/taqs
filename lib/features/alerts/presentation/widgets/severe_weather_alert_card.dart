import 'package:flutter/material.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/features/alerts/domain/entities/weather_alert.dart';

/// Presentation card displaying active severe weather warnings and safety instructions.
class SevereWeatherAlertCard extends StatefulWidget {
  const SevereWeatherAlertCard({
    required this.alert,
    required this.isArabic,
    super.key,
  });

  final WeatherAlert alert;
  final bool isArabic;

  @override
  State<SevereWeatherAlertCard> createState() => _SevereWeatherAlertCardState();
}

class _SevereWeatherAlertCardState extends State<SevereWeatherAlertCard> {
  bool _isExpanded = false;

  Color get _accentColor {
    return widget.alert.severity == AlertSeverity.severe
        ? AppColors.alertRed
        : AppColors.metallicGold;
  }

  IconData get _alertIcon {
    switch (widget.alert.type) {
      case AlertType.khamsinDust:
        return Icons.air_rounded;
      case AlertType.morningFog:
        return Icons.foggy;
      case AlertType.heatWave:
        return Icons.local_fire_department_rounded;
      case AlertType.heavyRain:
      case AlertType.extremeWind:
        return Icons.thunderstorm_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title =
        widget.isArabic ? widget.alert.titleAr : widget.alert.titleEn;
    final description =
        widget.isArabic ? widget.alert.descriptionAr : widget.alert.descriptionEn;
    final tips =
        widget.isArabic ? widget.alert.safetyTipsAr : widget.alert.safetyTipsEn;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: _accentColor.withValues(alpha: 0.1),
      borderColor: _accentColor.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs + 2),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_alertIcon, size: 20, color: _accentColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _accentColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _accentColor,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ],
          ),
          if (_isExpanded && tips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.isArabic ? 'إرشادات السلامة الوقائية:' : 'Safety Guidance:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: _accentColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: _accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

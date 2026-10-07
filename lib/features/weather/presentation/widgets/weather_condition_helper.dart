import 'package:flutter/material.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Presentation helper for mapping [WeatherCondition] to icons and localized text.
abstract final class WeatherConditionHelper {
  static IconData getIcon(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return Icons.wb_sunny_rounded;
      case WeatherCondition.partlyCloudy:
        return Icons.cloud_queue_rounded;
      case WeatherCondition.cloudy:
        return Icons.cloud_rounded;
      case WeatherCondition.rainy:
        return Icons.grain_rounded;
      case WeatherCondition.dustStorm:
        return Icons.air_rounded;
      case WeatherCondition.fog:
        return Icons.foggy;
    }
  }

  static Color getIconColor(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return AppColors.metallicGold;
      case WeatherCondition.partlyCloudy:
      case WeatherCondition.cloudy:
        return AppColors.cyanAccent;
      case WeatherCondition.rainy:
        return AppColors.electricBlue;
      case WeatherCondition.dustStorm:
        return const Color(0xFFD97706);
      case WeatherCondition.fog:
        return const Color(0xFF94A3B8);
    }
  }

  static String getLocalizedName(
    BuildContext context,
    WeatherCondition condition,
  ) {
    final l10n = AppLocalizations.of(context);
    switch (condition) {
      case WeatherCondition.sunny:
        return l10n.conditionSunny;
      case WeatherCondition.partlyCloudy:
        return l10n.conditionPartlyCloudy;
      case WeatherCondition.cloudy:
        return l10n.conditionCloudy;
      case WeatherCondition.rainy:
        return l10n.conditionRainy;
      case WeatherCondition.dustStorm:
        return l10n.conditionDustStorm;
      case WeatherCondition.fog:
        return l10n.conditionFog;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// Frost risk classification for crops and orchards.
enum FrostRiskLevel {
  none,
  moderate,
  high;

  String labelAr() {
    switch (this) {
      case FrostRiskLevel.none:
        return 'آمن (لا يوجد خطر صقيع)';
      case FrostRiskLevel.moderate:
        return 'احتمال صقيع خفيف (3-5°م)';
      case FrostRiskLevel.high:
        return 'خطر صقيع مرتفع (≤2°م)';
    }
  }

  String labelEn() {
    switch (this) {
      case FrostRiskLevel.none:
        return 'Safe (No Frost Risk)';
      case FrostRiskLevel.moderate:
        return 'Moderate Frost Risk (3-5°C)';
      case FrostRiskLevel.high:
        return 'High Frost Risk (≤2°C)';
    }
  }
}

/// Domain model for agricultural and farming parameters.
@immutable
class FarmingReport {
  const FarmingReport({
    required this.frostRisk,
    required this.referenceEt0Mm,
    required this.estimatedSoilTempC,
    required this.estimatedSoilMoisturePercent,
    required this.rainExpectedSoon,
    required this.irrigationAdviceAr,
    required this.irrigationAdviceEn,
    required this.cropProtectionTipAr,
    required this.cropProtectionTipEn,
  });

  final FrostRiskLevel frostRisk;
  final double referenceEt0Mm;
  final double estimatedSoilTempC;
  final int estimatedSoilMoisturePercent;
  final bool rainExpectedSoon;
  final String irrigationAdviceAr;
  final String irrigationAdviceEn;
  final String cropProtectionTipAr;
  final String cropProtectionTipEn;
}

/// Evaluator computing agricultural insights from forecast bundle.
class FarmingEvaluator {
  const FarmingEvaluator._();

  /// Evaluates agricultural indicators for the current weather bundle.
  static FarmingReport evaluate(WeatherBundle bundle) {
    // Determine lowest forecast minimum temperature over the next 48h
    var minTemp = bundle.current.temperature;
    if (bundle.daily.isNotEmpty) {
      final firstDays = bundle.daily.take(2);
      for (final d in firstDays) {
        if (d.minTemp < minTemp) {
          minTemp = d.minTemp;
        }
      }
    }

    // 1. Frost Risk
    final FrostRiskLevel frost;
    final String protectionAr;
    final String protectionEn;
    if (minTemp <= 2) {
      frost = FrostRiskLevel.high;
      protectionAr =
          'خطر صقيع شديد الليلة! شغّل الرشاشات ليلاً أو غطِّ الشتلات الحساسة (طماطم وفراولة).';
      protectionEn =
          'Severe frost hazard tonight! Cover sensitive crops or run nocturnal misting.';
    } else if (minTemp <= 5) {
      frost = FrostRiskLevel.moderate;
      protectionAr =
          'برودة ليلية شديدة، راقب المحاصيل المكشوفة وأشجار الفاكهة في الساعات المتأخرة.';
      protectionEn =
          'Cold night; monitor exposed crops and fruit orchards during early hours.';
    } else {
      frost = FrostRiskLevel.none;
      protectionAr =
          'درجات الحرارة آمنة تماماً للمحاصيل والبيوت المحمية من الصقيع.';
      protectionEn =
          'Temperatures remain safely above frost danger thresholds.';
    }

    // 2. Reference Evapotranspiration (ET0) estimation based on temperature, wind, humidity, and UV
    // Standard FAO-56 Penman-Monteith correlation for Egypt
    final temp = bundle.current.temperature;
    final wind = bundle.current.windSpeedKmh;
    final humidity = bundle.current.humidityPercentage;
    final uv = bundle.current.uvIndex;

    // Approximate daily ET0 in mm
    final et0 = ((temp * 0.12) + (uv * 0.25) + (wind * 0.04) - (humidity * 0.02))
        .clamp(2.0, 9.5);

    // 3. Estimated Soil Temperature (0-7 cm) and Moisture
    final soilTemp = (temp * 0.85 + 3.0).clamp(5.0, 42.0);
    final soilMoisture = (humidity * 0.4 + 10).clamp(15, 60).toInt();

    // 4. Rain Outlook for next 3 days
    var rainSoon = bundle.current.precipitationProbability >= 40;
    if (bundle.daily.isNotEmpty) {
      for (final d in bundle.daily.take(3)) {
        if (d.condition == WeatherCondition.rainy) {
          rainSoon = true;
          break;
        }
      }
    }

    final String irrigationAr;
    final String irrigationEn;
    if (rainSoon) {
      irrigationAr =
          'توقعات أمطار قادمة: يُفضل تأجيل التسميد والري بالرش لتفادي غسيل الأسمدة.';
      irrigationEn =
          'Rain expected: Delay spraying and heavy irrigation to prevent nutrient runoff.';
    } else if (et0 >= 5.5) {
      irrigationAr =
          'معدل بخر عالي ($et0 ملم/يوم): زِد فترات الري الصباحية والمسائية لتجنب إجهاد المحصول.';
      irrigationEn =
          'High evapotranspiration ($et0 mm/day): Increase early morning/evening irrigation.';
    } else {
      irrigationAr =
          'معدل بخر معتدل ($et0 ملم/يوم): انتظام جداول الري المعتادة مناسب لنمو الجذور.';
      irrigationEn =
          'Moderate evapotranspiration ($et0 mm/day): Standard regular irrigation schedule.';
    }

    return FarmingReport(
      frostRisk: frost,
      referenceEt0Mm: double.parse(et0.toStringAsFixed(1)),
      estimatedSoilTempC: double.parse(soilTemp.toStringAsFixed(1)),
      estimatedSoilMoisturePercent: soilMoisture,
      rainExpectedSoon: rainSoon,
      irrigationAdviceAr: irrigationAr,
      irrigationAdviceEn: irrigationEn,
      cropProtectionTipAr: protectionAr,
      cropProtectionTipEn: protectionEn,
    );
  }
}

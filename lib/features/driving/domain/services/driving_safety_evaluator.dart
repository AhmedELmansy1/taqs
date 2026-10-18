import 'package:flutter/foundation.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// 4-Level Road Safety Rating.
enum RoadSafetyLevel {
  good,
  caution,
  hazardous,
  extremeRisk;

  String labelAr() {
    switch (this) {
      case RoadSafetyLevel.good:
        return 'طرق آمنة وممتازة';
      case RoadSafetyLevel.caution:
        return 'توخي الحذر';
      case RoadSafetyLevel.hazardous:
        return 'طرق خطرة وصعبة';
      case RoadSafetyLevel.extremeRisk:
        return 'شديدة الخطورة';
    }
  }

  String labelEn() {
    switch (this) {
      case RoadSafetyLevel.good:
        return 'Safe & Optimal';
      case RoadSafetyLevel.caution:
        return 'Exercise Caution';
      case RoadSafetyLevel.hazardous:
        return 'Hazardous Conditions';
      case RoadSafetyLevel.extremeRisk:
        return 'Extreme Hazard';
    }
  }
}

/// Comprehensive road safety evaluation report.
@immutable
class DrivingSafetyReport {
  const DrivingSafetyReport({
    required this.level,
    required this.headlineAr,
    required this.headlineEn,
    required this.tipAr,
    required this.tipEn,
    required this.primaryHazardAr,
    required this.primaryHazardEn,
  });

  final RoadSafetyLevel level;
  final String headlineAr;
  final String headlineEn;
  final String tipAr;
  final String tipEn;
  final String primaryHazardAr;
  final String primaryHazardEn;
}

/// Deterministic domain engine assessing road and highway safety conditions in Egypt.
class DrivingSafetyEvaluator {
  const DrivingSafetyEvaluator._();

  /// Evaluates driving safety deterministically based on real meteorological parameters.
  static DrivingSafetyReport evaluate(CurrentWeather current) {
    // 1. Extreme Risk: Severe Dust Storm (Khamsin) with gale winds OR near-zero visibility
    if (current.condition == WeatherCondition.dustStorm &&
        current.windSpeedKmh >= 50) {
      return const DrivingSafetyReport(
        level: RoadSafetyLevel.extremeRisk,
        headlineAr: 'عاصفة ترابية شديدة وانعدام رؤية',
        headlineEn: 'Severe Dust Storm & Near-Zero Visibility',
        tipAr:
            'يُنصح بتأجيل السفر على الطرق الصحراوية والمفتوحة حتى هدوء العاصفة.',
        tipEn:
            'Avoid highway and desert driving until blowing sand subsides.',
        primaryHazardAr: 'عواصف رملية',
        primaryHazardEn: 'Dust Storm',
      );
    }

    if (current.visibilityKm <= 0.6) {
      return const DrivingSafetyReport(
        level: RoadSafetyLevel.extremeRisk,
        headlineAr: 'شبورة مائية كثيفة جداً (شبه معدومة)',
        headlineEn: 'Dense Fog & Critical Low Visibility',
        tipAr:
            'التزم بالحارة اليمنى، هدئ السرعة لأقصى درجة، وشغل مصابيح الضباب والانتظار.',
        tipEn:
            'Use extreme caution, follow road studs, and keep hazard lights engaged.',
        primaryHazardAr: 'شبورة كثيفة',
        primaryHazardEn: 'Dense Fog',
      );
    }

    // 2. Hazardous: Torrential Rain (rainy with high probability)
    if (current.condition == WeatherCondition.rainy &&
        current.precipitationProbability >= 70) {
      return const DrivingSafetyReport(
        level: RoadSafetyLevel.hazardous,
        headlineAr: 'أمطار غزيرة ومخاطر انزلاق مائي',
        headlineEn: 'Heavy Rain & Aquaplaning Hazard',
        tipAr:
            'احذر تجمعات المياه والانزلاق عند الفرملة، وضاعف مسافة الأمان بين المركبات.',
        tipEn:
            'Maintain double following distance and avoid hard braking through puddles.',
        primaryHazardAr: 'انزلاق مائي',
        primaryHazardEn: 'Aquaplaning',
      );
    }

    if (current.visibilityKm <= 2.0) {
      return const DrivingSafetyReport(
        level: RoadSafetyLevel.hazardous,
        headlineAr: 'شبورة مائية صباحية على الطرق الزراعية والسريعة',
        headlineEn: 'Morning Fog on Highways & Agricultural Roads',
        tipAr:
            'افتح مصابيح الضباب والتزم بالمسار وتجنب التجاوز والسرعات العالية.',
        tipEn:
            'Keep low beams on, avoid overtaking, and decrease driving speed.',
        primaryHazardAr: 'تدني الرؤية',
        primaryHazardEn: 'Low Visibility',
      );
    }

    if (current.condition == WeatherCondition.dustStorm) {
      return const DrivingSafetyReport(
        level: RoadSafetyLevel.hazardous,
        headlineAr: 'رمال مثارة ورياح نشطة',
        headlineEn: 'Blowing Dust & Active Wind',
        tipAr:
            'أحكم إغلاق النوافذ، وانتبه للرياح الجانبية على الطرق الصحراوية.',
        tipEn:
            'Close windows firmly and prepare for sudden crosswinds on open roads.',
        primaryHazardAr: 'أتربة مثارة',
        primaryHazardEn: 'Blowing Sand',
      );
    }

    // 3. Caution: Wet Roads, Moderate Wind (>35 km/h), or Light Fog
    if (current.precipitationProbability >= 40 ||
        current.condition == WeatherCondition.rainy) {
      return const DrivingSafetyReport(
        level: RoadSafetyLevel.caution,
        headlineAr: 'طرق مبللة مع احتمال تساقط أمطار',
        headlineEn: 'Wet Surfaces & Rain Expected',
        tipAr:
            'الطرق قد تكون زلقة، تجنب المناورات المفاجئة والسرعة الزائدة عند المنحنيات.',
        tipEn:
            'Surface may be slick; take extra care when turning or braking.',
        primaryHazardAr: 'طرق مبللة',
        primaryHazardEn: 'Wet Road',
      );
    }

    if (current.windSpeedKmh >= 38) {
      return const DrivingSafetyReport(
        level: RoadSafetyLevel.caution,
        headlineAr: 'رياح نشطة قد تؤثر على اتزان المركبة',
        headlineEn: 'Breezy Crosswinds Impacting Handling',
        tipAr:
            'أمسك عجلة القيادة بكلتا يديك بحذر عند المرور على الجسور والمناطق المكشوفة.',
        tipEn:
            'Firm grip on wheel recommended when passing open bridges and valleys.',
        primaryHazardAr: 'رياح نشطة',
        primaryHazardEn: 'Gusty Wind',
      );
    }

    // 4. Good: Optimal Standard Driving
    if (!current.isDay) {
      return const DrivingSafetyReport(
        level: RoadSafetyLevel.good,
        headlineAr: 'الرؤية جيدة (قيادة ليلية)',
        headlineEn: 'Good Visibility (Night Driving)',
        tipAr:
            'الرؤية طبيعية، تأكد من نظافة الزجاج وخفض الضوء العالي أمام السيارات المقابلة.',
        tipEn:
            'Conditions are clear; dip high beams for oncoming vehicles.',
        primaryHazardAr: 'قيادة ليلية',
        primaryHazardEn: 'Night Driving',
      );
    }

    return const DrivingSafetyReport(
      level: RoadSafetyLevel.good,
      headlineAr: 'ظروف القيادة ممتازة وآمنة',
      headlineEn: 'Excellent Road & Driving Conditions',
      tipAr:
          'الرؤية ممتازة وحالة الطقس مستقرة تماماً ومناسبة للرحلات والسفر.',
      tipEn:
          'Clear visibility and calm atmospheric conditions across all routes.',
      primaryHazardAr: 'لا توجد مخاطر',
      primaryHazardEn: 'None',
    );
  }
}

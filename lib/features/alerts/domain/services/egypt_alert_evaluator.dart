import 'package:taqs/features/alerts/domain/entities/weather_alert.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// Contextual evaluator for Egyptian meteorological alerts.
abstract final class EgyptAlertEvaluator {
  /// Evaluates weather bundle against Egypt's severe weather thresholds.
  static List<WeatherAlert> evaluate(
    WeatherBundle bundle, {
    DateTime? currentTime,
  }) {
    final alerts = <WeatherAlert>[];
    final current = bundle.current;
    final airQuality = bundle.airQuality;
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;

    // 1. Dust Storm / Khamsin (عواصف ترابية / الخماسين)
    final isKhamsinDust = current.condition == WeatherCondition.dustStorm ||
        (current.windSpeedKmh >= 32 && current.humidityPercentage <= 25) ||
        (airQuality != null && airQuality.dust >= 28.0);

    if (isKhamsinDust) {
      final isSevere = current.windSpeedKmh >= 45 ||
          (airQuality != null && airQuality.dust >= 50.0);

      alerts.add(
        WeatherAlert(
          id: 'alert_khamsin_dust',
          type: AlertType.khamsinDust,
          severity: isSevere ? AlertSeverity.severe : AlertSeverity.warning,
          titleAr: 'تحذير: رياح مثيرة للأتربة والرمال (الخماسين)',
          titleEn: 'Alert: Dust Storm & High Winds (Khamsin)',
          descriptionAr:
              'نشاط ملحوظ للرياح الهابطة والمحملة بالأتربة، مما يؤدي إلى تراجع مستوى الرؤية الأفقية على الطرق المفتوحة والصحراوية.',
          descriptionEn:
              'Elevated winds and airborne dust reducing visibility across open and desert highway corridors.',
          safetyTipsAr: const [
            'يُنصح بارتداء الكمامات والنظارات الواقية لمرضى حساسية الصدر والجيوب الأنفية.',
            'إحكام إغلاق النوافذ والأبواب بالمنازل.',
            'توخي أقصى درجات الحيطة أثناء القيادة على الطرق الصحراوية والسريعة.',
          ],
          safetyTipsEn: const [
            'Wear a face mask and glasses if prone to respiratory allergies.',
            'Keep home windows and vents securely closed.',
            'Drive with reduced speed on desert and peripheral highways.',
          ],
        ),
      );
    }

    // 2. Dense Morning Fog / Mist (شبورة مائية كثيفة)
    // Critical for Egypt's Agricultural (الزراعي) & Desert (الصحراوي) highways
    final isEarlyMorning = hour >= 4 && hour <= 9;
    final isFogLikely = isEarlyMorning &&
        current.humidityPercentage >= 85 &&
        current.windSpeedKmh <= 12 &&
        (current.condition == WeatherCondition.fog ||
            current.condition == WeatherCondition.partlyCloudy ||
            current.condition == WeatherCondition.cloudy);

    if (isFogLikely) {
      alerts.add(
        const WeatherAlert(
          id: 'alert_morning_fog',
          type: AlertType.morningFog,
          severity: AlertSeverity.warning,
          titleAr: 'تنبيه: شبورة مائية كثيفة على الطرق السريعة',
          titleEn: 'Caution: Dense Morning Highway Fog',
          descriptionAr:
              'انخفاض حاد في مستوى الرؤية الأفقية في الصباح الباكر، لا سيما على طريقي القاهرة-الإسكندرية الزراعي والصحراوي ومحاور الدلتا والقناة.',
          descriptionEn:
              'Sharply reduced horizontal visibility early morning on Delta and desert arterial roads.',
          safetyTipsAr: [
            'الالتزام بالحارات المرورية وتشغيل مصابيح الضباب ومضاعفة مسافة الأمان.',
            'تجنب السرعات الزائدة والتوقف المفاجئ على الطرق السريعة.',
            'تأجيل السفر المبكر إن أمكن حتى انقشاع الشبورة وظهور أشعة الشمس.',
          ],
          safetyTipsEn: [
            'Use low-beam fog lights and maintain double safety following distance.',
            'Avoid speeding or abrupt braking on damp road surfaces.',
            'Postpone early highway travel until morning mist clears.',
          ],
        ),
      );
    }

    // 3. Extreme Heatwave (موجة حارة شديدة)
    if (current.temperature >= 38 || current.feelsLike >= 40) {
      final isSevere = current.temperature >= 42 || current.feelsLike >= 44;
      alerts.add(
        WeatherAlert(
          id: 'alert_heat_wave',
          type: AlertType.heatWave,
          severity: isSevere ? AlertSeverity.severe : AlertSeverity.warning,
          titleAr: isSevere ? 'تحذير شديد: موجة شديدة الحرارة' : 'تنبيه: طقس حار جداً',
          titleEn: isSevere ? 'Severe Warning: Extreme Heatwave' : 'Notice: Intense Heat',
          descriptionAr:
              'درجات حرارة مرتفعة تسود الأجواء، مع زيادة ملحوظة في الشعور الفعلي بالحرارة.',
          descriptionEn:
              'Elevated temperature and heat index across regional governorates.',
          safetyTipsAr: const [
            'تجنب التعرض المباشر لأشعة الشمس الحارقة خاصة في فترة الظهيرة (12-4 عصراً).',
            'الإكثار من شرب المياه والسوائل الباردة على مدار اليوم.',
            'ارتداء الملابس القطنية الفضفاضة وفاتحة اللون وغطاء للرأس عند الخروج.',
          ],
          safetyTipsEn: const [
            'Avoid direct peak sun exposure between 12:00 PM and 4:00 PM.',
            'Drink plenty of cold fluids and water throughout the day.',
            'Wear loose light-colored cotton attire and protective headwear.',
          ],
        ),
      );
    }

    // 4. Heavy Rain & Showers (أمطار غزيرة ورياح نشطة)
    if (current.condition == WeatherCondition.rainy &&
        current.humidityPercentage >= 70 &&
        current.windSpeedKmh >= 18) {
      alerts.add(
        const WeatherAlert(
          id: 'alert_heavy_rain',
          type: AlertType.heavyRain,
          severity: AlertSeverity.warning,
          titleAr: 'تنبيه: أمطار ورياح نشطة',
          titleEn: 'Caution: Rain Showers & Gusty Winds',
          descriptionAr:
              'فرص لتجمعات مياه الأمطار وتباطؤ في حركة المرور على الطرق الداخلية والسريعة.',
          descriptionEn:
              'Potential surface water pooling and slippery road conditions.',
          safetyTipsAr: [
            'الابتعاد تماماً عن أعمدة الإنارة ولوحات الإعلانات المعدنية بالشوارع.',
            'تهدئة السرعة أثناء القيادة لتجنب انزلاق الإطارات.',
            'الابتعاد عن مجاري السيول بالمحافظات الساحلية والجبلية.',
          ],
          safetyTipsEn: [
            'Stay clear of street lampposts and exposed electric fixtures.',
            'Drive at reduced speeds on wet pavement to prevent skidding.',
            'Avoid low-lying wadi floodways in coastal or desert hills.',
          ],
        ),
      );
    }

    return alerts;
  }
}

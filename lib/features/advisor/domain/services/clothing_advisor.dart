import 'package:taqs/features/advisor/domain/entities/clothing_advice.dart';
import 'package:taqs/features/weather/domain/entities/weather_condition.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';

/// Contextual engine determining clothing recommendations based on weather parameters.
abstract final class ClothingAdvisor {
  static ClothingAdvice recommend(WeatherBundle bundle) {
    final current = bundle.current;
    final temp = current.temperature;
    final feelsLike = current.feelsLike;
    final condition = current.condition;
    final dust = bundle.airQuality?.dust ?? 0.0;

    String headlineAr;
    String headlineEn;
    String detailsAr;
    String detailsEn;
    String seasonAr;
    String seasonEn;
    final itemsAr = <String>[];
    final itemsEn = <String>[];

    if (temp >= 32 || feelsLike >= 35) {
      headlineAr = 'ملابس صيفية خفيفة وقبعة شمسية';
      headlineEn = 'Ultra-light summer attire & sun protection';
      detailsAr =
          'أجواء حارة جداً؛ يُنصح بارتداء أقمشة قطنية فضفاضة بيضاء أو فاتحة لحجب حرارة الشمس.';
      detailsEn =
          'Intense heat; loose, light-colored breathable cotton fabrics are ideal today.';
      seasonAr = 'صيفي حار';
      seasonEn = 'Hot Summer';
      itemsAr.addAll(['قميص قطني خفيف', 'نظارة شمسية', 'قبعة واقية']);
      itemsEn.addAll(['Light cotton shirt', 'Sunglasses', 'Sun cap']);
    } else if (temp >= 24) {
      headlineAr = 'ملابس صيفية مريحة ومعتدلة';
      headlineEn = 'Comfortable summer everyday wear';
      detailsAr =
          'أجواء دافئة وممتعة؛ الملابس القطنية اليومية المعتادة مناسبة لجميع الأوقات.';
      detailsEn =
          'Warm and pleasant; standard casual cotton clothing is well suited for today.';
      seasonAr = 'صيفي معتدل';
      seasonEn = 'Pleasant Summer';
      itemsAr.addAll(['ملابس خفيفة', 'حذاء مريح', 'نظارة شمسية']);
      itemsEn.addAll(['T-shirt / Polo', 'Comfortable sneakers', 'Sunglasses']);
    } else if (temp >= 18) {
      headlineAr = 'ملابس ربيعية / خريفية بأكمام طويلة';
      headlineEn = 'Mild transitional layers & long sleeves';
      detailsAr =
          'أجواء معتدلة نهاراً ومائلة للبرودة ليلاً؛ احتفظ بجاكيت خفيف إذا كنت ستعود متأخراً.';
      detailsEn =
          'Mild daytime with cooler evenings; carry a light jacket or layer if out late.';
      seasonAr = 'ربيعي / خريفي';
      seasonEn = 'Transitional';
      itemsAr.addAll(['قميص بأكمام طويلة', 'جاكيت خفيف للمساء']);
      itemsEn.addAll(['Long sleeves', 'Light evening jacket']);
    } else if (temp >= 13) {
      headlineAr = 'جاكيت دافئ وملابس خريفية سميكة';
      headlineEn = 'Warm jacket & mid-weight winter layers';
      detailsAr =
          'الطقس مائل للبرودة؛ يُنصح بارتداء جاكيت أو سترة صوفية لحمايتك من تيارات الهواء.';
      detailsEn =
          'Chilly breeze; wear a warm sweater or light winter coat to stay comfortable.';
      seasonAr = 'خريفي مائل للبرودة';
      seasonEn = 'Chilly Autumn';
      itemsAr.addAll(['جاكيت دافئ', 'بلوفر / سترة صوفية']);
      itemsEn.addAll(['Warm jacket', 'Knit sweater']);
    } else {
      headlineAr = 'ملابس شتوية ثقيلة ومعطف واقٍ';
      headlineEn = 'Heavy winter coat & thermal layers';
      detailsAr =
          'أجواء باردة وشديدة البرودة ليلاً؛ ارتدِ معطفاً شتوياً سميكاً وطبقات دافئة.';
      detailsEn =
          'Cold conditions; bundle up in a thick winter coat, layers, and a warm scarf.';
      seasonAr = 'شتوي بارد';
      seasonEn = 'Cold Winter';
      itemsAr.addAll(['معطف شتوي سميك', 'وشاح دافئ']);
      itemsEn.addAll(['Heavy winter coat', 'Warm scarf']);
    }

    // Weather condition modifiers
    if (condition == WeatherCondition.rainy ||
        bundle.hourly.any((h) => h.condition == WeatherCondition.rainy)) {
      itemsAr.add('مظلة أو جاكيت مقاوم للماء');
      itemsEn.add('Umbrella or rain shell');
    }

    if (condition == WeatherCondition.dustStorm || dust >= 25.0) {
      itemsAr.add('كمامة ونظارة واقية للأتربة');
      itemsEn.add('Dust mask & protective glasses');
    }

    return ClothingAdvice(
      headlineAr: headlineAr,
      headlineEn: headlineEn,
      detailsAr: detailsAr,
      detailsEn: detailsEn,
      itemsAr: itemsAr,
      itemsEn: itemsEn,
      seasonTagAr: seasonAr,
      seasonTagEn: seasonEn,
    );
  }
}

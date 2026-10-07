// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'طقس';

  @override
  String get appTagline => 'تطبيق الطقس الذكي لجمهورية مصر العربية';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get homeTitle => 'طقس اليوم';

  @override
  String get defaultCity => 'القاهرة، مصر';

  @override
  String feelsLike(int temp) {
    return 'الشعور الفعلي $temp°';
  }

  @override
  String get humidity => 'الرطوبة';

  @override
  String get windSpeed => 'سرعة الرياح';

  @override
  String windSpeedUnit(int speed) {
    return '$speed كم/س';
  }

  @override
  String get uvIndex => 'مؤشر الأشعة فوق البنفسجية';

  @override
  String get airQuality => 'جودة الهواء';

  @override
  String get airQualityGood => 'جيدة';

  @override
  String get hourlyForecastTitle => 'التوقعات بالساعات';

  @override
  String get weeklyForecastTitle => 'توقعات 7 أيام';

  @override
  String get conditionSunny => 'مشمس';

  @override
  String get conditionPartlyCloudy => 'غائم جزئياً';

  @override
  String get conditionCloudy => 'غائم';

  @override
  String get conditionRainy => 'ممطر';

  @override
  String get conditionDustStorm => 'عاصفة ترابية';

  @override
  String get conditionFog => 'ضباب';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get appearanceSection => 'المظهر والعرض';

  @override
  String get themeMode => 'نمط السمة';

  @override
  String get themeSystem => 'تلقائي (حسب النظام)';

  @override
  String get themeLight => 'الوضع الفاتح';

  @override
  String get themeDark => 'الوضع الليلي (الداكن)';

  @override
  String get languageSection => 'اللغة والمنطقة';

  @override
  String get language => 'لغة التطبيق';

  @override
  String get languageArabic => 'العربية (Arabic)';

  @override
  String get languageEnglish => 'الإنجليزية (English)';

  @override
  String get aboutSection => 'عن التطبيق';

  @override
  String get aboutDeveloper => 'عن المطور';

  @override
  String get aboutDeveloperSubtitle => 'أحمد المنسي • نبذة وتفاصيل التواصل';

  @override
  String get developerName => 'أحمد المنسي';

  @override
  String get developerTitle =>
      'مطور تطبيقات فلاتر • أمن سيبراني • ذكاء اصطناعي';

  @override
  String get developerLocation => 'الشرقية، مصر';

  @override
  String get developerSummary =>
      'مطور تطبيقات فلاتر، وشغوف بالذكاء الاصطناعي والأمن السيبراني، خريج علوم الحاسب.';

  @override
  String get educationSectionTitle => 'التعليم والشهادات';

  @override
  String get educationDegree => 'بكالوريوس الحاسبات والمعلومات، جامعة بنها';

  @override
  String get educationSpecialization =>
      'التخصص: أمن المعلومات والأدلة الجنائية الرقمية (تقدير: جيد جداً)';

  @override
  String get educationGraduationProject =>
      'مشروع التخرج: كشف التزييف الرقمي (كشف تزييف الصور والصوتيات بالذكاء الاصطناعي) — امتياز';

  @override
  String get skillsSectionTitle => 'المهارات والتقنيات';

  @override
  String get projectsSectionTitle => 'المشاريع';

  @override
  String get contactSectionTitle => 'معلومات التواصل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phone => 'الهاتف';

  @override
  String get github => 'حساب GitHub';

  @override
  String get linkedin => 'حساب LinkedIn';

  @override
  String get sendEmail => 'إرسال رسالة';

  @override
  String get callPhone => 'اتصال هاتفي';

  @override
  String get openGitHub => 'زيارة البروفايل';

  @override
  String get openLinkedIn => 'زيارة البروفايل';

  @override
  String cannotLaunchUrl(String target) {
    return 'تعذر فتح الرابط المطلوب: $target';
  }

  @override
  String copiedToClipboard(String text) {
    return 'تم النسخ بنجاح: $text';
  }

  @override
  String get builtWithFlutter => 'صُنع بكل فخر باستخدام Flutter';

  @override
  String appVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get emptyStateMessage => 'لا توجد بيانات متاحة حالياً';

  @override
  String get errorStateMessage => 'حدث خطأ غير متوقع أثناء تحميل البيانات';

  @override
  String get splashLoading => 'جاري تهيئة طقس مصر...';
}

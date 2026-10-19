import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// اسم التطبيق
  ///
  /// In ar, this message translates to:
  /// **'طقس'**
  String get appName;

  /// الوصف المختصر للتطبيق
  ///
  /// In ar, this message translates to:
  /// **'تطبيق الطقس الذكي لجمهورية مصر العربية'**
  String get appTagline;

  /// عنوان تبويب الرئيسية
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// عنوان تبويب الإعدادات
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// عنوان الصفحة الرئيسية
  ///
  /// In ar, this message translates to:
  /// **'طقس اليوم'**
  String get homeTitle;

  /// المدينة الافتراضية للطقس
  ///
  /// In ar, this message translates to:
  /// **'القاهرة، مصر'**
  String get defaultCity;

  /// درجة الحرارة المحسوسة
  ///
  /// In ar, this message translates to:
  /// **'الشعور الفعلي {temp}°'**
  String feelsLike(int temp);

  /// تسمية نسبة الرطوبة
  ///
  /// In ar, this message translates to:
  /// **'الرطوبة'**
  String get humidity;

  /// تسمية سرعة الرياح
  ///
  /// In ar, this message translates to:
  /// **'سرعة الرياح'**
  String get windSpeed;

  /// قيمة سرعة الرياح بوحدة كم/س
  ///
  /// In ar, this message translates to:
  /// **'{speed} كم/س'**
  String windSpeedUnit(int speed);

  /// مؤشر الأشعة فوق البنفسجية
  ///
  /// In ar, this message translates to:
  /// **'مؤشر الأشعة فوق البنفسجية'**
  String get uvIndex;

  /// تسمية جودة الهواء
  ///
  /// In ar, this message translates to:
  /// **'جودة الهواء'**
  String get airQuality;

  /// حالة جودة الهواء جيدة
  ///
  /// In ar, this message translates to:
  /// **'جيدة'**
  String get airQualityGood;

  /// عنوان قسم التوقعات الساعية
  ///
  /// In ar, this message translates to:
  /// **'التوقعات بالساعات'**
  String get hourlyForecastTitle;

  /// عنوان قسم التوقعات الأسبوعية
  ///
  /// In ar, this message translates to:
  /// **'توقعات 7 أيام'**
  String get weeklyForecastTitle;

  /// حالة الطقس: مشمس
  ///
  /// In ar, this message translates to:
  /// **'مشمس'**
  String get conditionSunny;

  /// حالة الطقس: غائم جزئياً
  ///
  /// In ar, this message translates to:
  /// **'غائم جزئياً'**
  String get conditionPartlyCloudy;

  /// حالة الطقس: غائم
  ///
  /// In ar, this message translates to:
  /// **'غائم'**
  String get conditionCloudy;

  /// حالة الطقس: ممطر
  ///
  /// In ar, this message translates to:
  /// **'ممطر'**
  String get conditionRainy;

  /// حالة الطقس: عاصفة ترابية
  ///
  /// In ar, this message translates to:
  /// **'عاصفة ترابية'**
  String get conditionDustStorm;

  /// حالة الطقس: ضباب
  ///
  /// In ar, this message translates to:
  /// **'ضباب'**
  String get conditionFog;

  /// عنوان صفحة الإعدادات
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// قسم إعدادات المظهر
  ///
  /// In ar, this message translates to:
  /// **'المظهر والعرض'**
  String get appearanceSection;

  /// خيار نمط السمة
  ///
  /// In ar, this message translates to:
  /// **'نمط السمة'**
  String get themeMode;

  /// نمط النظام التلقائي
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (حسب النظام)'**
  String get themeSystem;

  /// الوضع النهاري الفاتح
  ///
  /// In ar, this message translates to:
  /// **'الوضع الفاتح'**
  String get themeLight;

  /// الوضع الليلي الداكن
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي (الداكن)'**
  String get themeDark;

  /// قسم خيارات اللغة
  ///
  /// In ar, this message translates to:
  /// **'اللغة والمنطقة'**
  String get languageSection;

  /// خيار لغة التطبيق
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get language;

  /// اللغة العربية
  ///
  /// In ar, this message translates to:
  /// **'العربية (Arabic)'**
  String get languageArabic;

  /// اللغة الإنجليزية
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية (English)'**
  String get languageEnglish;

  /// قسم المعلومات عن التطبيق
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutSection;

  /// زر الانتقال لصفحة المطور
  ///
  /// In ar, this message translates to:
  /// **'عن المطور'**
  String get aboutDeveloper;

  /// وصف فرعي لصفحة المطور
  ///
  /// In ar, this message translates to:
  /// **'أحمد المنسي • نبذة وتفاصيل التواصل'**
  String get aboutDeveloperSubtitle;

  /// اسم مطور التطبيق
  ///
  /// In ar, this message translates to:
  /// **'أحمد المنسي'**
  String get developerName;

  /// المسمى المهني للمطور
  ///
  /// In ar, this message translates to:
  /// **'مطور تطبيقات فلاتر • أمن سيبراني • ذكاء اصطناعي'**
  String get developerTitle;

  /// موقع المطور
  ///
  /// In ar, this message translates to:
  /// **'الشرقية، مصر'**
  String get developerLocation;

  /// ملخص السيرة الذاتية للمطور
  ///
  /// In ar, this message translates to:
  /// **'مطور تطبيقات فلاتر، وشغوف بالذكاء الاصطناعي والأمن السيبراني، خريج علوم الحاسب.'**
  String get developerSummary;

  /// عنوان قسم التعليم
  ///
  /// In ar, this message translates to:
  /// **'التعليم والشهادات'**
  String get educationSectionTitle;

  /// المؤهل الجامعي
  ///
  /// In ar, this message translates to:
  /// **'بكالوريوس الحاسبات والمعلومات، جامعة بنها'**
  String get educationDegree;

  /// تخصص الكلية والتقدير
  ///
  /// In ar, this message translates to:
  /// **'التخصص: أمن المعلومات والأدلة الجنائية الرقمية (تقدير: جيد جداً)'**
  String get educationSpecialization;

  /// مشروع التخرج وتقديره
  ///
  /// In ar, this message translates to:
  /// **'مشروع التخرج: كشف التزييف الرقمي (كشف تزييف الصور والصوتيات بالذكاء الاصطناعي) — امتياز'**
  String get educationGraduationProject;

  /// عنوان قسم المهارات
  ///
  /// In ar, this message translates to:
  /// **'المهارات والتقنيات'**
  String get skillsSectionTitle;

  /// عنوان قسم المشاريع
  ///
  /// In ar, this message translates to:
  /// **'المشاريع'**
  String get projectsSectionTitle;

  /// عنوان قسم التواصل
  ///
  /// In ar, this message translates to:
  /// **'معلومات التواصل'**
  String get contactSectionTitle;

  /// تسمية البريد الإلكتروني
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// تسمية رقم الهاتف
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get phone;

  /// تسمية حساب جيت هب
  ///
  /// In ar, this message translates to:
  /// **'حساب GitHub'**
  String get github;

  /// تسمية حساب لينكد إن
  ///
  /// In ar, this message translates to:
  /// **'حساب LinkedIn'**
  String get linkedin;

  /// إجراء إرسال بريد
  ///
  /// In ar, this message translates to:
  /// **'إرسال رسالة'**
  String get sendEmail;

  /// إجراء الاتصال الهاتفي
  ///
  /// In ar, this message translates to:
  /// **'اتصال هاتفي'**
  String get callPhone;

  /// إجراء فتح جيت هب
  ///
  /// In ar, this message translates to:
  /// **'زيارة البروفايل'**
  String get openGitHub;

  /// إجراء فتح لينكد إن
  ///
  /// In ar, this message translates to:
  /// **'زيارة البروفايل'**
  String get openLinkedIn;

  /// رسالة خطأ عند فشل فتح رابط
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح الرابط المطلوب: {target}'**
  String cannotLaunchUrl(String target);

  /// رسالة النسخ للحافظة
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ بنجاح: {text}'**
  String copiedToClipboard(String text);

  /// عبارة الفوتر
  ///
  /// In ar, this message translates to:
  /// **'صُنع بكل فخر باستخدام Flutter'**
  String get builtWithFlutter;

  /// عرض رقم إصدار التطبيق
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String appVersion(String version);

  /// زر إعادة المحاولة
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// رسالة الحالة الفارغة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات متاحة حالياً'**
  String get emptyStateMessage;

  /// رسالة حالة الخطأ
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع أثناء تحميل البيانات'**
  String get errorStateMessage;

  /// نص تحميل شاشة البداية
  ///
  /// In ar, this message translates to:
  /// **'جاري تهيئة طقس مصر...'**
  String get splashLoading;

  /// حقوق مزود بيانات الطقس Open-Meteo
  ///
  /// In ar, this message translates to:
  /// **'بيانات الطقس مقدمة من Open-Meteo.com'**
  String get openMeteoAttribution;

  /// عنوان شاشة اختيار الموقع
  ///
  /// In ar, this message translates to:
  /// **'اختيار الموقع'**
  String get selectLocation;

  /// تلميح البحث عن المواقع
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن محافظة أو مدينة...'**
  String get searchLocationHint;

  /// تسمية الموقع الحالي بواسطة GPS
  ///
  /// In ar, this message translates to:
  /// **'موقعي الحالي'**
  String get currentLocation;

  /// زر استخدام الموقع الحالي
  ///
  /// In ar, this message translates to:
  /// **'استخدام موقعي الحالي'**
  String get useCurrentLocation;

  /// عنوان قائمة محافظات مصر
  ///
  /// In ar, this message translates to:
  /// **'محافظات مصر'**
  String get egyptianGovernorates;

  /// عنوان قسم المواقع المحفوظة
  ///
  /// In ar, this message translates to:
  /// **'المواقع المحفوظة'**
  String get savedLocations;

  /// رسالة عدم وجود مواقع محفوظة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواقع محفوظة بعد'**
  String get noSavedLocations;

  /// عنوان طلب إذن الموقع
  ///
  /// In ar, this message translates to:
  /// **'إذن تحديد الموقع'**
  String get locationPermissionTitle;

  /// شرح سبب طلب إذن الموقع
  ///
  /// In ar, this message translates to:
  /// **'يحتاج تطبيق طقس إذن الوصول إلى موقعك لعرض التوقعات الجوية الدقيقة لمكانك الحالي.'**
  String get locationPermissionRationale;

  /// زر فتح إعدادات الهاتف
  ///
  /// In ar, this message translates to:
  /// **'فتح الإعدادات'**
  String get openSettings;

  /// شريط التنبيه عند عرض بيانات من الذاكرة المؤقتة بدون إنترنت
  ///
  /// In ar, this message translates to:
  /// **'بيانات محفوظة • آخر تحديث: {time}'**
  String offlineDataBanner(String time);

  /// وقت التحديث الآن
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get justNow;

  /// مضى عدة دقائق
  ///
  /// In ar, this message translates to:
  /// **'منذ {minutes} دقيقة'**
  String minutesAgo(int minutes);

  /// مضى عدة ساعات
  ///
  /// In ar, this message translates to:
  /// **'منذ {hours} ساعة'**
  String hoursAgo(int hours);

  /// خيار وحدة سرعة الرياح
  ///
  /// In ar, this message translates to:
  /// **'وحدة سرعة الرياح'**
  String get windUnit;

  /// وحدة كم/س
  ///
  /// In ar, this message translates to:
  /// **'كم/س (Kilometers per hour)'**
  String get windUnitKmh;

  /// وحدة م/ث
  ///
  /// In ar, this message translates to:
  /// **'م/ث (Meters per second)'**
  String get windUnitMs;

  /// عنوان قسم الإشعارات في الإعدادات
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsSection;

  /// خيار تنبيهات الطقس الحرج
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الطقس الحرج (الخماسين والشبورة)'**
  String get severeAlertsToggle;

  /// وصف خيار تنبيهات الطقس الحرج
  ///
  /// In ar, this message translates to:
  /// **'إشعارات استباقية بالتقلبات الجوية الشديدة والعواصف'**
  String get severeAlertsSubtitle;

  /// خيار الملخص اليومي الصباحي
  ///
  /// In ar, this message translates to:
  /// **'الملخص اليومي الصباحي'**
  String get dailyBriefingToggle;

  /// وصف خيار الملخص اليومي الصباحي
  ///
  /// In ar, this message translates to:
  /// **'إشعار يومي بدرجات الحرارة ونصائح الملابس المناسبة'**
  String get dailyBriefingSubtitle;

  /// عنوان بطاقة نصائح الملابس
  ///
  /// In ar, this message translates to:
  /// **'ماذا أرتدي اليوم؟'**
  String get whatToWearTitle;

  /// عنوان إرشادات السلامة في بطاقة التنبيهات
  ///
  /// In ar, this message translates to:
  /// **'إرشادات السلامة الوقائية:'**
  String get safetyTipsTitle;

  /// تسمية نسبة الغبار المحمولة جوا
  ///
  /// In ar, this message translates to:
  /// **'الغبار'**
  String get dustMetric;

  /// عنوان قسم يعمل حاليا على
  ///
  /// In ar, this message translates to:
  /// **'يعمل حالياً على'**
  String get currentlyBuildingTitle;

  /// العنوان الفرعي لتطبيق طقس
  ///
  /// In ar, this message translates to:
  /// **'تطبيق طقس ومواقيت الصلاة (Taqs)'**
  String get currentlyBuildingSubtitle;

  /// وصف تطبيق طقس
  ///
  /// In ar, this message translates to:
  /// **'تطبيق عربي متكامل لحساب المواقيت والطقس بدقة، مبني وفق هندسة برمجية نظيفة (Clean Architecture) وإدارة حالة معتمدة على Riverpod وتصميم بصري عصري فائق الجودة.'**
  String get currentlyBuildingDesc;

  /// شارة الحالة للمشروع النشط
  ///
  /// In ar, this message translates to:
  /// **'قيد التطوير المستمر'**
  String get inActiveDevelopment;

  /// عنوان بطاقة دعوة العمل المشترك
  ///
  /// In ar, this message translates to:
  /// **'لنعمل معاً'**
  String get letsWorkTogetherTitle;

  /// الوصف الفرعي لبطاقة دعوة العمل
  ///
  /// In ar, this message translates to:
  /// **'متاح لفرص تطوير تطبيقات فلاتر، وهندسة البرمجيات، وتطبيقات الذكاء الاصطناعي.'**
  String get letsWorkTogetherSubtitle;

  /// زر الإجراء للتواصل
  ///
  /// In ar, this message translates to:
  /// **'تواصل معي'**
  String get contactMeAction;

  /// نص زر تحميل السيرة الذاتية
  ///
  /// In ar, this message translates to:
  /// **'تحميل السيرة الذاتية (PDF)'**
  String get downloadCv;

  /// رسالة نجاح فتح السيرة الذاتية
  ///
  /// In ar, this message translates to:
  /// **'تم فتح السيرة الذاتية بنجاح'**
  String get cvDownloaded;

  /// رسالة تعذر فتح السيرة الذاتية
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح السيرة الذاتية حالياً'**
  String get cvDownloadError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

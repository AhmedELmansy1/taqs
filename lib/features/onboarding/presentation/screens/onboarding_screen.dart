import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taqs/core/design/branding/taqs_logo.dart';
import 'package:taqs/core/design/components/app_button.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/core/navigation/app_routes.dart';
import 'package:taqs/core/notifications/notification_service.dart';
import 'package:taqs/core/notifications/notification_settings_controller.dart';
import 'package:taqs/core/permissions/location_service.dart';
import 'package:taqs/features/location/presentation/providers/location_controller.dart';
import 'package:taqs/features/onboarding/presentation/providers/onboarding_controller.dart';

/// First-launch onboarding flow with transparent privacy pitch,
/// interactive location & notification permission onboarding, and manual fallbacks.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  LocationPermissionStatus? _locationStatus;
  bool _notificationGranted = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    unawaited(HapticFeedback.mediumImpact());
    await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  void _nextPage() {
    unawaited(HapticFeedback.selectionClick());
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      unawaited(_finishOnboarding());
    }
  }

  Future<void> _requestLocation() async {
    unawaited(HapticFeedback.lightImpact());
    final locationService = ref.read(locationServiceProvider);
    final status = await locationService.requestPermission();
    setState(() => _locationStatus = status);

    if (status == LocationPermissionStatus.granted) {
      await ref
          .read(locationControllerProvider.notifier)
          .requestCurrentGpsLocation();
    }
  }

  Future<void> _requestNotifications() async {
    unawaited(HapticFeedback.lightImpact());
    final notificationService = ref.read(notificationServiceProvider);
    final granted = await notificationService.requestPermission();
    setState(() => _notificationGranted = granted);

    if (granted) {
      await ref
          .read(notificationSettingsControllerProvider.notifier)
          .setDailyBriefingEnabled(enabled: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              isArabic ? 'تخطي' : 'Skip',
              style: const TextStyle(
                color: AppColors.cyanAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  // Step 1: Welcome
                  _WelcomeStep(isArabic: isArabic),

                  // Step 2: Location
                  _LocationStep(
                    isArabic: isArabic,
                    status: _locationStatus,
                    onRequestLocation: _requestLocation,
                    onOpenSettings: () =>
                        ref.read(locationServiceProvider).openAppSettings(),
                    onOpenLocationSettings: () => ref
                        .read(locationServiceProvider)
                        .openLocationSettings(),
                    onChooseGovernorate: () =>
                        context.push(AppRoutes.locationSearch),
                  ),

                  // Step 3: Notifications
                  _NotificationsStep(
                    isArabic: isArabic,
                    granted: _notificationGranted,
                    onRequestNotification: _requestNotifications,
                    onOpenSettings: () =>
                        ref.read(locationServiceProvider).openAppSettings(),
                  ),
                ],
              ),
            ),

            // Bottom controls: Indicators and Action button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Step indicators
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.cyanAccent
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Next / Get Started button
                  AppButton(
                    label: _currentPage == 2
                        ? (isArabic ? 'ابدأ الآن' : 'Get Started')
                        : (isArabic ? 'التالي' : 'Next'),
                    icon: Icon(
                      _currentPage == 2
                          ? Icons.check_circle_rounded
                          : (isArabic
                              ? Icons.arrow_back_rounded
                              : Icons.arrow_forward_rounded),
                    ),
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.isArabic});
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TaqsLogo(
            size: 96,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isArabic ? 'أهلاً بك في طقس' : 'Welcome to Taqs',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isArabic
                ? 'تطبيق الطقس الذكي الأول لجمهورية مصر العربية، المصمم بأحدث المعايير المعمارية ودقة الأرصاد الجوية الفائقة.'
                : 'Egypt’s premier smart weather app, beautifully engineered with modern architecture and atmospheric precision.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _FeaturePill(
                  icon: Icons.map_outlined,
                  text: isArabic
                      ? 'تغطية شاملة لكافة محافظات ومدن مصر'
                      : 'Complete coverage for all Egypt governorates',
                ),
                const SizedBox(height: AppSpacing.sm),
                _FeaturePill(
                  icon: Icons.security_rounded,
                  text: isArabic
                      ? 'خصوصية تامة واستخدام محلي على جهازك فقط'
                      : '100% on-device processing and strict privacy',
                ),
                const SizedBox(height: AppSpacing.sm),
                _FeaturePill(
                  icon: Icons.offline_bolt_outlined,
                  text: isArabic
                      ? 'دعم كامل للعمل بدون اتصال بالإنترنت'
                      : 'Robust offline caching support',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep({
    required this.isArabic,
    required this.status,
    required this.onRequestLocation,
    required this.onOpenSettings,
    required this.onOpenLocationSettings,
    required this.onChooseGovernorate,
  });

  final bool isArabic;
  final LocationPermissionStatus? status;
  final VoidCallback onRequestLocation;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenLocationSettings;
  final VoidCallback onChooseGovernorate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isGranted = status == LocationPermissionStatus.granted;
    final isDeniedForever = status == LocationPermissionStatus.deniedForever;
    final isServiceDisabled = status == LocationPermissionStatus.serviceDisabled;
    final isDenied = status == LocationPermissionStatus.denied;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isGranted
                  ? AppColors.cyanAccent.withValues(alpha: 0.15)
                  : AppColors.electricBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGranted ? Icons.check_circle_rounded : Icons.location_on_rounded,
              size: 40,
              color: isGranted ? AppColors.cyanAccent : AppColors.electricBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isArabic ? 'تحديد الموقع الجغرافي' : 'Current Location Weather',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isArabic
                ? 'يستخدم طقس موقعك لتزويدك بدرجات الحرارة الحقيقية لمحافظتك بدقة فائقة. موقعك يُعالج محلياً على جهازك فقط ولا تتم مشاركته إطلاقاً.'
                : 'Taqs uses your device location to provide accurate local forecasts. Your location is processed solely on-device and never stored or shared.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          if (isGranted) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cyanAccent.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderMd,
                border: Border.all(
                  color: AppColors.cyanAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.cyanAccent,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'تم تفعيل إذن الموقع بنجاح!'
                          : 'Location permission enabled successfully!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.cyanAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isDeniedForever) ...[
            Text(
              isArabic
                  ? 'إذن الموقع معطل من إعدادات النظام. يمكنك تفعيله يدوياً أو اختيار محافظتك من القائمة.'
                  : 'Location is disabled in system settings. You can open settings or select a governorate manually.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFFF97316),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: isArabic ? 'فتح إعدادات النظام' : 'Open System Settings',
              icon: const Icon(Icons.settings_rounded),
              isFullWidth: true,
              onPressed: onOpenSettings,
            ),
          ] else if (isServiceDisabled) ...[
            Text(
              isArabic
                  ? 'خدمات الموقع (GPS) مغلقة على الهاتف. يرجى تفعيلها من النظام.'
                  : 'Location services (GPS) are turned off. Please enable them in system settings.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFFF97316),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: isArabic ? 'تفعيل خدمات الموقع' : 'Enable Location Services',
              icon: const Icon(Icons.location_searching_rounded),
              isFullWidth: true,
              onPressed: onOpenLocationSettings,
            ),
          ] else ...[
            AppButton(
              label: isArabic ? 'تفعيل إذن الموقع' : 'Enable Location Permission',
              icon: const Icon(Icons.my_location_rounded),
              isFullWidth: true,
              onPressed: onRequestLocation,
            ),
            if (isDenied) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                isArabic
                    ? 'يمكنك دائماً اختيار محافظتك يدوياً في أي وقت دون إذن الموقع.'
                    : 'You can always select your governorate manually without location permission.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],

          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: onChooseGovernorate,
            icon: const Icon(Icons.list_alt_rounded, size: 18),
            label: Text(
              isArabic ? 'أو اختر محافظتك يدوياً' : 'Or Choose Governorate Manually',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsStep extends StatelessWidget {
  const _NotificationsStep({
    required this.isArabic,
    required this.granted,
    required this.onRequestNotification,
    required this.onOpenSettings,
  });

  final bool isArabic;
  final bool granted;
  final VoidCallback onRequestNotification;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: granted
                  ? AppColors.metallicGold.withValues(alpha: 0.15)
                  : AppColors.electricBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              granted
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              size: 40,
              color: granted ? AppColors.metallicGold : AppColors.electricBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isArabic ? 'إشعارات الطقس كل 12 ساعة' : '12-Hour Weather Updates',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isArabic
                ? 'احصل على ملخص دوري كل 12 ساعة بحالة الطقس الحالية ونصائح الملابس المناسبة، بالإضافة إلى تنبيهات فورية بالتقلبات الشديدة كالعواصف والشبورة.'
                : 'Receive real atmospheric summaries every 12 hours plus critical alerts for storms, dust, and heavy fog in your governorate.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          if (granted) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cyanAccent.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderMd,
                border: Border.all(
                  color: AppColors.cyanAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.cyanAccent,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'تم تفعيل إشعارات الطقس بنجاح!'
                          : 'Weather notifications activated successfully!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.cyanAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            AppButton(
              label: isArabic ? 'تفعيل الإشعارات' : 'Enable Notifications',
              icon: const Icon(Icons.notifications_active_rounded),
              isFullWidth: true,
              onPressed: onRequestNotification,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isArabic
                  ? 'يمكنك تعديل أوقات الإشعارات أو إيقافها في أي وقت من شاشة الإعدادات.'
                  : 'You can change notification preferences at any time in Settings.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.cyanAccent),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

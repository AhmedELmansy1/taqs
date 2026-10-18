import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taqs/core/constants/app_constants.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/typography/app_typography.dart';
import 'package:taqs/core/sharing/card_image_sharer.dart';
import 'package:taqs/features/prayer/domain/entities/prayer_entities.dart';
import 'package:taqs/features/weather/domain/entities/weather_entities.dart';
import 'package:taqs/features/weather/presentation/widgets/weather_condition_helper.dart';

/// An on-brand, high-resolution shareable weather & prayer card designed for social sharing.
class WeatherShareCard extends StatelessWidget {
  const WeatherShareCard({
    required this.weather,
    required this.isArabic,
    super.key,
    this.prayerTimes,
    this.customWidth = 380,
  });

  final WeatherBundle weather;
  final bool isArabic;
  final PrayerTimesBundle? prayerTimes;
  final double customWidth;

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final minTemp = weather.daily.isNotEmpty ? weather.daily.first.minTemp : null;
    final maxTemp = weather.daily.isNotEmpty ? weather.daily.first.maxTemp : null;
    final nextPrayer = prayerTimes?.nextPrayer;

    return Container(
      width: customWidth,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBackground,
            AppColors.darkSurface,
            Color(0xFF132038),
          ],
        ),
        border: Border.all(
          color: AppColors.cyanAccent.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Brand & Tagline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.cyanAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cyanAccent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Icon(
                        Icons.cloud_outlined,
                        color: AppColors.cyanAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? AppConstants.appNameAr : AppConstants.appNameEn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppTypography.primaryFontFamily,
                              color: AppColors.darkTextPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            isArabic ? AppConstants.appTaglineAr : AppConstants.appTaglineEn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppTypography.primaryFontFamily,
                              color: AppColors.metallicGold,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Location Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.darkBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.cyanAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isArabic ? current.cityNameAr : current.cityNameEn,
                      style: const TextStyle(
                        fontFamily: AppTypography.primaryFontFamily,
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main Temperature & Condition
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${current.temperature}°',
                    style: const TextStyle(
                      fontFamily: AppTypography.primaryFontFamily,
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      color: AppColors.darkTextPrimary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isArabic
                        ? WeatherConditionHelper.getLocalizedName(context, current.condition)
                        : current.condition.name.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AppTypography.primaryFontFamily,
                      color: AppColors.cyanAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    isArabic
                        ? 'الإحساس الفعلي ${current.feelsLike}°'
                        : 'Feels like ${current.feelsLike}°',
                    style: const TextStyle(
                      fontFamily: AppTypography.primaryFontFamily,
                      color: AppColors.darkTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              // Weather Condition Icon Artwork
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkSurfaceElevated.withValues(alpha: 0.6),
                  border: Border.all(
                    color: AppColors.cyanAccent.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  WeatherConditionHelper.getIcon(current.condition),
                  size: 42,
                  color: AppColors.cyanAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Metric highlights grid (Rain, Min/Max, Humidity)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceElevated.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _metricCol(
                  label: isArabic ? 'الأمطار' : 'Rain',
                  value: '${current.precipitationProbability}%',
                  icon: Icons.water_drop_outlined,
                  color: AppColors.cyanAccent,
                ),
                if (minTemp != null && maxTemp != null)
                  _metricCol(
                    label: isArabic ? 'صغرى / عظمى' : 'Min / Max',
                    value: '$minTemp° / $maxTemp°',
                    icon: Icons.thermostat_outlined,
                    color: AppColors.darkTextPrimary,
                  ),
                _metricCol(
                  label: isArabic ? 'الرطوبة' : 'Humidity',
                  value: '${current.humidityPercentage}%',
                  icon: Icons.opacity_outlined,
                  color: AppColors.cyanAccent,
                ),
              ],
            ),
          ),

          // Next Prayer Section (if present)
          if (nextPrayer != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.metallicGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.metallicGold.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_filled,
                    size: 18,
                    color: AppColors.metallicGold,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'الصلاة القادمة: ${nextPrayer.nameAr()}'
                          : 'Next Prayer: ${nextPrayer.nameEn()}',
                      style: const TextStyle(
                        fontFamily: AppTypography.primaryFontFamily,
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('h:mm a', isArabic ? 'ar' : 'en')
                        .format(nextPrayer.time),
                    style: const TextStyle(
                      fontFamily: AppTypography.primaryFontFamily,
                      color: AppColors.metallicGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                prayerTimes != null
                    ? (isArabic
                        ? prayerTimes!.hijriFormattedAr
                        : prayerTimes!.hijriFormattedEn)
                    : (isArabic ? 'طقس مصر المباشر' : 'Live Egypt Weather'),
                style: const TextStyle(
                  fontFamily: AppTypography.primaryFontFamily,
                  color: AppColors.darkTextSecondary,
                  fontSize: 10,
                ),
              ),
              Text(
                'taqs.app',
                style: TextStyle(
                  fontFamily: AppTypography.primaryFontFamily,
                  color: AppColors.cyanAccent.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCol({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppTypography.primaryFontFamily,
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTypography.primaryFontFamily,
            color: AppColors.darkTextSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Helper modal sheet to preview and share the weather card image.
class WeatherShareModal extends StatefulWidget {
  const WeatherShareModal({
    required this.weather,
    required this.isArabic,
    super.key,
    this.prayerTimes,
  });

  final WeatherBundle weather;
  final bool isArabic;
  final PrayerTimesBundle? prayerTimes;

  static Future<void> show(
    BuildContext context, {
    required WeatherBundle weather,
    required bool isArabic,
    PrayerTimesBundle? prayerTimes,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WeatherShareModal(
        weather: weather,
        isArabic: isArabic,
        prayerTimes: prayerTimes,
      ),
    );
  }

  @override
  State<WeatherShareModal> createState() => _WeatherShareModalState();
}

class _WeatherShareModalState extends State<WeatherShareModal> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _share() async {
    setState(() => _isSharing = true);
    final cityName = widget.isArabic
        ? widget.weather.current.cityNameAr
        : widget.weather.current.cityNameEn;
    final text = widget.isArabic
        ? 'طقس $cityName اليوم عبر تطبيق طقس ومواقيت الصلاة'
        : 'Weather in $cityName via Taqs App';

    await CardImageSharer.captureAndShare(
      repaintBoundaryKey: _cardKey,
      fileName: 'taqs_$cityName',
      shareText: text,
    );

    if (mounted) {
      setState(() => _isSharing = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.darkBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            widget.isArabic ? 'مشاركة بطاقة الطقس كصورة' : 'Share Weather Card',
            style: const TextStyle(
              fontFamily: AppTypography.primaryFontFamily,
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          // Off-screen or visible preview wrapped in RepaintBoundary
          RepaintBoundary(
            key: _cardKey,
            child: WeatherShareCard(
              weather: widget.weather,
              isArabic: widget.isArabic,
              prayerTimes: widget.prayerTimes,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSharing ? null : _share,
              icon: _isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.darkBackground,
                      ),
                    )
                  : const Icon(Icons.share, color: AppColors.darkBackground),
              label: Text(
                _isSharing
                    ? (widget.isArabic ? 'جارٍ التجهيز...' : 'Preparing...')
                    : (widget.isArabic
                        ? 'مشاركة البطاقة (واتساب / التطبيقات)'
                        : 'Share Image (WhatsApp / Apps)'),
                style: const TextStyle(
                  fontFamily: AppTypography.primaryFontFamily,
                  color: AppColors.darkBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyanAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taqs/core/design/components/app_card.dart';
import 'package:taqs/core/design/components/loading_state.dart';
import 'package:taqs/core/design/tokens/app_colors.dart';
import 'package:taqs/core/design/tokens/app_radius.dart';
import 'package:taqs/core/design/tokens/app_spacing.dart';
import 'package:taqs/core/permissions/location_service.dart';
import 'package:taqs/features/location/data/data_sources/open_meteo_geocoding_data_source.dart';
import 'package:taqs/features/location/data/repositories/egyptian_governorates.dart';
import 'package:taqs/features/location/domain/entities/location_item.dart';
import 'package:taqs/features/location/presentation/providers/location_controller.dart';
import 'package:taqs/l10n/app_localizations.dart';

/// Screen enabling search and quick selection of Egyptian governorates and current GPS location.
class LocationSearchScreen extends ConsumerStatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  ConsumerState<LocationSearchScreen> createState() =>
      _LocationSearchScreenState();
}

class _LocationSearchScreenState extends ConsumerState<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<LocationItem> _searchResults = const [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = const [];
        _isSearching = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      setState(() {
        _isSearching = true;
      });

      try {
        final geocodingSource =
            ref.read(openMeteoGeocodingDataSourceProvider);
        final results = await geocodingSource.searchLocations(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } on Object catch (_) {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    });
  }

  void _selectAndExit(LocationItem location) {
    unawaited(
      ref.read(locationControllerProvider.notifier).selectLocation(location),
    );
    if (context.mounted && context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locationState = ref.watch(locationControllerProvider);
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectLocation),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            children: [
              // Search Input Field
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.searchLocationHint,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.cyanAccent,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Permission Warning Banner if GPS disabled or denied
              if (locationState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    backgroundColor: AppColors.alertRed.withValues(alpha: 0.12),
                    borderColor: AppColors.alertRed.withValues(alpha: 0.3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.alertRed,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locationState.errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.alertRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (locationState.permissionStatus ==
                                  LocationPermissionStatus.deniedForever) ...[
                                const SizedBox(height: AppSpacing.sm),
                                TextButton.icon(
                                  onPressed: () => ref
                                      .read(locationControllerProvider.notifier)
                                      .openAppSettings(),
                                  icon: const Icon(Icons.settings, size: 16),
                                  label: Text(l10n.openSettings),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.alertRed,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // GPS Current Location Button
              AppCard(
                onTap: locationState.isLoadingGps
                    ? null
                    : () async {
                        final router = GoRouter.of(context);
                        final success = await ref
                            .read(locationControllerProvider.notifier)
                            .requestCurrentGpsLocation();
                        if (success && mounted && router.canPop()) {
                          router.pop();
                        }
                      },
                backgroundColor: isDark
                    ? AppColors.darkSurfaceElevated
                    : Colors.white,
                borderColor: locationState.selectedLocation.isCurrentLocation
                    ? AppColors.cyanAccent
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.cyanAccent.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: locationState.isLoadingGps
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.cyanAccent,
                              ),
                            )
                          : const Icon(
                              Icons.my_location_rounded,
                              color: AppColors.cyanAccent,
                              size: 20,
                            ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.useCurrentLocation,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            locationState.selectedLocation.isCurrentLocation
                                ? l10n.currentLocation
                                : l10n.locationPermissionRationale,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (locationState.selectedLocation.isCurrentLocation)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.cyanAccent,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Active Search Results
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: LoadingState(),
                )
              else if (_searchResults.isNotEmpty) ...[
                Text(
                  l10n.searchLocationHint,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.cyanAccent,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ..._searchResults.map(
                  (loc) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.location_city_rounded,
                      color: AppColors.electricBlue,
                    ),
                    title: Text(loc.nameAr),
                    subtitle: loc.admin1 != null ? Text(loc.admin1!) : null,
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => _selectAndExit(loc),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Saved / Favorite Locations Section
              if (locationState.favoriteLocations.isNotEmpty) ...[
                Text(
                  l10n.savedLocations,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.metallicGold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: locationState.favoriteLocations.map((fav) {
                    final isSelected =
                        locationState.selectedLocation.id == fav.id;
                    final displayName = isArabic ? fav.nameAr : fav.nameEn;

                    return FilterChip(
                      selected: isSelected,
                      label: Text(displayName),
                      avatar: isSelected
                          ? const Icon(Icons.check, size: 16)
                          : const Icon(Icons.star, size: 16, color: AppColors.metallicGold),
                      onSelected: (_) => _selectAndExit(fav),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Verified Egyptian Governorates Quick-Pick
              Text(
                l10n.egyptianGovernorates,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.cyanAccent,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: EgyptianGovernorates.all.map((gov) {
                  final isSelected =
                      locationState.selectedLocation.id == gov.id;
                  final displayName = isArabic ? gov.nameAr : gov.nameEn;

                  return ActionChip(
                    backgroundColor: isSelected
                        ? AppColors.electricBlue.withValues(alpha: 0.2)
                        : null,
                    side: isSelected
                        ? const BorderSide(color: AppColors.cyanAccent)
                        : null,
                    avatar: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.location_on_outlined,
                      size: 16,
                      color: isSelected
                          ? AppColors.cyanAccent
                          : AppColors.lightTextSecondary,
                    ),
                    label: Text(
                      displayName,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.cyanAccent
                            : null,
                      ),
                    ),
                    onPressed: () => _selectAndExit(gov),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:taqs/features/location/domain/entities/location_item.dart';

/// Data Transfer Object for Open-Meteo Geocoding Search API.
class GeocodingResultDto {
  const GeocodingResultDto({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.countryCode,
    this.country,
    this.admin1,
  });

  factory GeocodingResultDto.fromJson(Map<String, dynamic> json) {
    return GeocodingResultDto(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      countryCode: json['country_code'] as String?,
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
    );
  }

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? countryCode;
  final String? country;
  final String? admin1;

  LocationItem toDomain() {
    return LocationItem(
      id: id.toString(),
      nameAr: name,
      nameEn: name,
      latitude: latitude,
      longitude: longitude,
      admin1: admin1,
    );
  }
}

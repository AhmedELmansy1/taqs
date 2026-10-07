import 'package:flutter/foundation.dart';

/// Immutable domain model representing a geographic location in Egypt.
@immutable
class LocationItem {
  const LocationItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.latitude,
    required this.longitude,
    this.isCurrentLocation = false,
    this.admin1,
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) => LocationItem(
        id: json['id'] as String,
        nameAr: json['nameAr'] as String,
        nameEn: json['nameEn'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        isCurrentLocation: (json['isCurrentLocation'] as bool?) ?? false,
        admin1: json['admin1'] as String?,
      );

  final String id;
  final String nameAr;
  final String nameEn;
  final double latitude;
  final double longitude;
  final bool isCurrentLocation;
  final String? admin1;

  LocationItem copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    double? latitude,
    double? longitude,
    bool? isCurrentLocation,
    String? admin1,
  }) {
    return LocationItem(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
      admin1: admin1 ?? this.admin1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'latitude': latitude,
        'longitude': longitude,
        'isCurrentLocation': isCurrentLocation,
        if (admin1 != null) 'admin1': admin1,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

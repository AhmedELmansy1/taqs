import 'package:flutter/foundation.dart';

/// Immutable domain model representing daily clothing recommendations.
@immutable
class ClothingAdvice {
  const ClothingAdvice({
    required this.headlineAr,
    required this.headlineEn,
    required this.detailsAr,
    required this.detailsEn,
    required this.itemsAr,
    required this.itemsEn,
    required this.seasonTagAr,
    required this.seasonTagEn,
  });

  final String headlineAr;
  final String headlineEn;
  final String detailsAr;
  final String detailsEn;
  final List<String> itemsAr;
  final List<String> itemsEn;
  final String seasonTagAr;
  final String seasonTagEn;
}

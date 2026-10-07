import 'package:taqs/features/location/domain/entities/location_item.dart';

/// Predefined list of verified Egyptian governorates with accurate coordinates.
abstract final class EgyptianGovernorates {
  static const LocationItem cairo = LocationItem(
    id: 'gov_cairo',
    nameAr: 'القاهرة',
    nameEn: 'Cairo',
    latitude: 30.0444,
    longitude: 31.2357,
  );

  static const LocationItem giza = LocationItem(
    id: 'gov_giza',
    nameAr: 'الجيزة',
    nameEn: 'Giza',
    latitude: 30.0131,
    longitude: 31.2089,
  );

  static const LocationItem alexandria = LocationItem(
    id: 'gov_alexandria',
    nameAr: 'الإسكندرية',
    nameEn: 'Alexandria',
    latitude: 31.2001,
    longitude: 29.9187,
  );

  static const LocationItem sharqia = LocationItem(
    id: 'gov_sharqia',
    nameAr: 'الشرقية',
    nameEn: 'Sharqia',
    latitude: 30.5877,
    longitude: 31.5020,
  );

  static const LocationItem dakahlia = LocationItem(
    id: 'gov_dakahlia',
    nameAr: 'الدقهلية',
    nameEn: 'Dakahlia',
    latitude: 31.0379,
    longitude: 31.3815,
  );

  static const LocationItem gharbia = LocationItem(
    id: 'gov_gharbia',
    nameAr: 'الغربية',
    nameEn: 'Gharbia',
    latitude: 30.7885,
    longitude: 31.0019,
  );

  static const LocationItem qalyubia = LocationItem(
    id: 'gov_qalyubia',
    nameAr: 'القليوبية',
    nameEn: 'Qalyubia',
    latitude: 30.4660,
    longitude: 31.1853,
  );

  static const LocationItem portSaid = LocationItem(
    id: 'gov_port_said',
    nameAr: 'بورسعيد',
    nameEn: 'Port Said',
    latitude: 31.2653,
    longitude: 32.3019,
  );

  static const LocationItem suez = LocationItem(
    id: 'gov_suez',
    nameAr: 'السويس',
    nameEn: 'Suez',
    latitude: 29.9668,
    longitude: 32.5498,
  );

  static const LocationItem ismailia = LocationItem(
    id: 'gov_ismailia',
    nameAr: 'الإسماعيلية',
    nameEn: 'Ismailia',
    latitude: 30.5965,
    longitude: 32.2715,
  );

  static const LocationItem luxor = LocationItem(
    id: 'gov_luxor',
    nameAr: 'الأقصر',
    nameEn: 'Luxor',
    latitude: 25.6872,
    longitude: 32.6396,
  );

  static const LocationItem aswan = LocationItem(
    id: 'gov_aswan',
    nameAr: 'أسوان',
    nameEn: 'Aswan',
    latitude: 24.0889,
    longitude: 32.8998,
  );

  static const LocationItem redSea = LocationItem(
    id: 'gov_red_sea',
    nameAr: 'البحر الأحمر',
    nameEn: 'Red Sea',
    latitude: 27.2579,
    longitude: 33.8116,
  );

  static const LocationItem southSinai = LocationItem(
    id: 'gov_south_sinai',
    nameAr: 'جنوب سيناء',
    nameEn: 'South Sinai',
    latitude: 27.9158,
    longitude: 34.3299,
  );

  static const LocationItem fayoum = LocationItem(
    id: 'gov_fayoum',
    nameAr: 'الفيوم',
    nameEn: 'Fayoum',
    latitude: 29.3084,
    longitude: 30.8428,
  );

  static const LocationItem asyut = LocationItem(
    id: 'gov_asyut',
    nameAr: 'أسيوط',
    nameEn: 'Asyut',
    latitude: 27.1783,
    longitude: 31.1859,
  );

  static const LocationItem sohag = LocationItem(
    id: 'gov_sohag',
    nameAr: 'سوهاج',
    nameEn: 'Sohag',
    latitude: 26.5569,
    longitude: 31.6948,
  );

  static const LocationItem qena = LocationItem(
    id: 'gov_qena',
    nameAr: 'قنا',
    nameEn: 'Qena',
    latitude: 26.1551,
    longitude: 32.7160,
  );

  static const LocationItem damietta = LocationItem(
    id: 'gov_damietta',
    nameAr: 'دمياط',
    nameEn: 'Damietta',
    latitude: 31.4175,
    longitude: 31.8144,
  );

  static const LocationItem matrouh = LocationItem(
    id: 'gov_matrouh',
    nameAr: 'مطروح',
    nameEn: 'Matrouh',
    latitude: 31.3543,
    longitude: 27.2373,
  );

  /// All verified quick-pick Egyptian governorates.
  static const List<LocationItem> all = [
    cairo,
    giza,
    alexandria,
    sharqia,
    dakahlia,
    gharbia,
    qalyubia,
    portSaid,
    suez,
    ismailia,
    luxor,
    aswan,
    redSea,
    southSinai,
    fayoum,
    asyut,
    sohag,
    qena,
    damietta,
    matrouh,
  ];
}

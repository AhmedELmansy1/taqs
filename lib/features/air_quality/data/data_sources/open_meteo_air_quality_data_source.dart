import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/errors/app_failure.dart';
import 'package:taqs/core/network/http_client.dart';
import 'package:taqs/features/air_quality/data/models/air_quality_dto.dart';

/// Contract for Open-Meteo Air Quality remote communication.
abstract interface class OpenMeteoAirQualityDataSource {
  Future<AirQualityDto> getAirQuality({
    required double latitude,
    required double longitude,
  });
}

/// Production implementation of [OpenMeteoAirQualityDataSource].
class OpenMeteoAirQualityDataSourceImpl
    implements OpenMeteoAirQualityDataSource {
  const OpenMeteoAirQualityDataSourceImpl({
    required this.httpClient,
  });

  final AppHttpClient httpClient;

  static const String _baseUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  @override
  Future<AirQualityDto> getAirQuality({
    required double latitude,
    required double longitude,
  }) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': 'european_aqi,pm10,pm2_5,dust',
      'timezone': 'auto',
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await httpClient.get(uri);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AirQualityDto.fromJson(data);
      } else {
        throw ServerFailure(
          response.statusCode,
          'Air Quality API returned status code ${response.statusCode}',
        );
      }
    } on SocketException catch (e) {
      throw NoConnectionFailure(e.message);
    } on TimeoutException {
      throw const TimeoutFailure();
    } on FormatException {
      throw const ParseFailure();
    } on AppFailure {
      rethrow;
    } on Object catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}

/// Provider for [OpenMeteoAirQualityDataSource].
final openMeteoAirQualityDataSourceProvider =
    Provider<OpenMeteoAirQualityDataSource>((ref) {
  final httpClient = ref.watch(appHttpClientProvider);
  return OpenMeteoAirQualityDataSourceImpl(httpClient: httpClient);
});

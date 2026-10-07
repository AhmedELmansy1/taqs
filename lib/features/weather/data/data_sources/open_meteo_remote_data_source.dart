import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/errors/app_failure.dart';
import 'package:taqs/core/network/http_client.dart';
import 'package:taqs/features/weather/data/models/open_meteo_dto.dart';

/// Contract for Open-Meteo weather remote API communication.
abstract interface class OpenMeteoRemoteDataSource {
  /// Fetches raw forecast DTO for given geographic coordinates.
  Future<OpenMeteoForecastDto> getForecast({
    required double latitude,
    required double longitude,
  });
}

/// Production implementation of [OpenMeteoRemoteDataSource].
class OpenMeteoRemoteDataSourceImpl implements OpenMeteoRemoteDataSource {
  const OpenMeteoRemoteDataSourceImpl({
    required this.httpClient,
  });

  final AppHttpClient httpClient;

  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  @override
  Future<OpenMeteoForecastDto> getForecast({
    required double latitude,
    required double longitude,
  }) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m',
      'hourly':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,weather_code,wind_speed_10m,uv_index',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,uv_index_max,precipitation_probability_max,wind_speed_10m_max',
      'timezone': 'auto',
      'forecast_days': '7',
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await httpClient.get(uri);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return OpenMeteoForecastDto.fromJson(data);
      } else {
        throw ServerFailure(
          response.statusCode,
          'Weather API returned status code ${response.statusCode}',
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

/// Provider for [OpenMeteoRemoteDataSource].
final openMeteoRemoteDataSourceProvider =
    Provider<OpenMeteoRemoteDataSource>((ref) {
  final httpClient = ref.watch(appHttpClientProvider);
  return OpenMeteoRemoteDataSourceImpl(httpClient: httpClient);
});

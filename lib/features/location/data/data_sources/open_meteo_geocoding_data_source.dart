import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/errors/app_failure.dart';
import 'package:taqs/core/network/http_client.dart';
import 'package:taqs/features/location/data/models/geocoding_result_dto.dart';
import 'package:taqs/features/location/domain/entities/location_item.dart';

/// Contract for Open-Meteo Geocoding remote search.
abstract interface class OpenMeteoGeocodingDataSource {
  Future<List<LocationItem>> searchLocations(String query);
}

/// Implementation of [OpenMeteoGeocodingDataSource].
class OpenMeteoGeocodingDataSourceImpl
    implements OpenMeteoGeocodingDataSource {
  const OpenMeteoGeocodingDataSourceImpl({
    required this.httpClient,
  });

  final AppHttpClient httpClient;

  static const String _baseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  @override
  Future<List<LocationItem>> searchLocations(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return const [];

    final queryParams = {
      'name': cleanQuery,
      'count': '10',
      'language': 'ar',
      'countryCode': 'EG',
      'format': 'json',
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await httpClient.get(uri);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawResults = data['results'] as List<dynamic>?;

        if (rawResults == null || rawResults.isEmpty) {
          return const [];
        }

        return rawResults
            .map((e) =>
                GeocodingResultDto.fromJson(e as Map<String, dynamic>).toDomain())
            .toList();
      } else {
        throw ServerFailure(
          response.statusCode,
          'Geocoding API returned ${response.statusCode}',
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

/// Provider for [OpenMeteoGeocodingDataSource].
final openMeteoGeocodingDataSourceProvider =
    Provider<OpenMeteoGeocodingDataSource>((ref) {
  final httpClient = ref.watch(appHttpClientProvider);
  return OpenMeteoGeocodingDataSourceImpl(httpClient: httpClient);
});

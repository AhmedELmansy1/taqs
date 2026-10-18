import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taqs/features/marine/domain/entities/marine_conditions.dart';

/// Remote data source calling Open-Meteo Marine API.
class OpenMeteoMarineRemoteDataSource {
  OpenMeteoMarineRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'https://marine-api.open-meteo.com/v1/marine';

  /// Fetches marine data for [latitude] and [longitude]. Returns `null` if location
  /// has no oceanic data points (e.g. inland governorates).
  Future<MarineConditions?> fetchMarineConditions({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly': 'wave_height,wave_direction,wave_period,wind_wave_height',
        'timezone': 'auto',
      },
    );

    try {
      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        // Inland coordinates or API refusal return 400 with 'No sea points'
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['error'] == true) {
        return null;
      }

      final hourly = json['hourly'] as Map<String, dynamic>?;
      if (hourly == null) return null;

      final waveHeights = hourly['wave_height'] as List<dynamic>?;
      final wavePeriods = hourly['wave_period'] as List<dynamic>?;
      final waveDirections = hourly['wave_direction'] as List<dynamic>?;
      final windWaveHeights = hourly['wind_wave_height'] as List<dynamic>?;

      if (waveHeights == null || waveHeights.isEmpty) return null;

      // Find current hour index or first valid reading
      var targetIdx = 0;
      final times = hourly['time'] as List<dynamic>?;
      if (times != null && times.isNotEmpty) {
        final nowIso = DateTime.now().toIso8601String().substring(0, 13);
        final found = times.indexWhere((t) => (t as String).startsWith(nowIso));
        if (found != -1) {
          targetIdx = found;
        }
      }

      final rawHeight = waveHeights[targetIdx];
      if (rawHeight == null) return null;

      final waveHeight = (rawHeight as num).toDouble();
      final wavePeriod =
          (wavePeriods?[targetIdx] as num?)?.toDouble() ?? 4.0;
      final waveDirection =
          (waveDirections?[targetIdx] as num?)?.toInt() ?? 0;
      final windWaveHeight =
          (windWaveHeights?[targetIdx] as num?)?.toDouble() ?? 0.0;

      return MarineConditions(
        waveHeightMeters: waveHeight,
        wavePeriodSeconds: wavePeriod,
        waveDirectionDegrees: waveDirection,
        windWaveHeightMeters: windWaveHeight,
        rating: SeaStateRating.fromWaveHeight(waveHeight),
        fetchedAt: DateTime.now(),
      );
    } on Object catch (_) {
      // Graceful offline fallback / inland silence
      return null;
    }
  }
}

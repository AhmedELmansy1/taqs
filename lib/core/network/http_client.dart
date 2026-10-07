import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Contract for application HTTP communications.
abstract interface class AppHttpClient {
  /// Sends a GET request to [url] with optional [headers].
  Future<http.Response> get(Uri url, {Map<String, String>? headers});
}

/// Production implementation of [AppHttpClient] with timeouts,
/// HTTPS enforcement, and retry backoff for transient failures.
class AppHttpClientImpl implements AppHttpClient {
  AppHttpClientImpl({
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
    this.maxRetries = 2,
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;
  final int maxRetries;

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    if (!url.isScheme('https')) {
      throw const SocketException('Insecure HTTP schemes are prohibited. Use HTTPS.');
    }

    var attempts = 0;
    while (true) {
      try {
        attempts++;
        final response = await _client.get(url, headers: headers).timeout(timeout);
        
        // Retry on transient 5xx server errors
        if (response.statusCode >= 500 && attempts <= maxRetries) {
          await Future<void>.delayed(Duration(milliseconds: 300 * attempts));
          continue;
        }

        return response;
      } on TimeoutException {
        if (attempts <= maxRetries) {
          await Future<void>.delayed(Duration(milliseconds: 300 * attempts));
          continue;
        }
        rethrow;
      } on SocketException {
        if (attempts <= maxRetries) {
          await Future<void>.delayed(Duration(milliseconds: 300 * attempts));
          continue;
        }
        rethrow;
      }
    }
  }
}

/// Riverpod provider for [AppHttpClient].
final appHttpClientProvider = Provider<AppHttpClient>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return AppHttpClientImpl(client: client);
});

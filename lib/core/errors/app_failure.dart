import 'package:flutter/foundation.dart';

/// Base class for all application and domain failures.
@immutable
sealed class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Emitted when network connectivity is unavailable.
class NoConnectionFailure extends AppFailure {
  const NoConnectionFailure([super.message = 'No internet connection']);
}

/// Emitted when a network request times out.
class TimeoutFailure extends AppFailure {
  const TimeoutFailure([super.message = 'Request timed out']);
}

/// Emitted when the remote API returns an unexpected HTTP status code.
class ServerFailure extends AppFailure {
  const ServerFailure(this.statusCode, [super.message = 'Server returned error']);

  final int statusCode;
}

/// Emitted when remote JSON response could not be parsed.
class ParseFailure extends AppFailure {
  const ParseFailure([super.message = 'Failed to parse response']);
}

/// Emitted when location permissions are denied by the user.
class LocationPermissionDeniedFailure extends AppFailure {
  const LocationPermissionDeniedFailure([super.message = 'Location permission denied']);
}

/// Emitted when location permissions are permanently denied.
class LocationPermissionPermanentlyDeniedFailure extends AppFailure {
  const LocationPermissionPermanentlyDeniedFailure([
    super.message = 'Location permission permanently denied',
  ]);
}

/// Emitted when device location services (GPS) are disabled.
class LocationServiceDisabledFailure extends AppFailure {
  const LocationServiceDisabledFailure([super.message = 'Location service disabled']);
}

/// Generic unexpected failure.
class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'An unexpected error occurred']);
}

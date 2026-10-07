import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taqs/core/storage/key_value_storage.dart';

/// Provider for [KeyValueStorage]. Must be overridden at root [ProviderScope] in `main()`.
final keyValueStorageProvider = Provider<KeyValueStorage>((ref) {
  throw UnimplementedError('keyValueStorageProvider must be overridden');
});

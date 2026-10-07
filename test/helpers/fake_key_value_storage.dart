import 'package:taqs/core/storage/key_value_storage.dart';

/// In-memory fake implementation of [KeyValueStorage] for deterministic testing.
final class FakeKeyValueStorage implements KeyValueStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }
}

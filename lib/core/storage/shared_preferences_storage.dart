import 'package:shared_preferences/shared_preferences.dart';
import 'package:taqs/core/storage/key_value_storage.dart';

/// Concrete implementation of [KeyValueStorage] backed by [SharedPreferences].
final class SharedPreferencesStorage implements KeyValueStorage {
  const SharedPreferencesStorage(this._prefs);

  final SharedPreferences _prefs;

  /// Asynchronously creates an instance initialized with system [SharedPreferences].
  static Future<SharedPreferencesStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesStorage(prefs);
  }

  @override
  Future<String?> getString(String key) {
    return Future.value(_prefs.getString(key));
  }

  @override
  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  @override
  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  @override
  Future<bool> clear() {
    return _prefs.clear();
  }
}

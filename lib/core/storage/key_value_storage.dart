/// Abstract contract for local key-value persistent storage.
///
/// Designed to decouple business logic and state notifiers from SharedPreferences.
abstract interface class KeyValueStorage {
  /// Reads a string value for the given [key]. Returns null if not set.
  Future<String?> getString(String key);

  /// Saves a string [value] for the given [key].
  Future<bool> setString(String key, String value);

  /// Removes the stored value for [key].
  Future<bool> remove(String key);

  /// Clears all keys from storage.
  Future<bool> clear();
}

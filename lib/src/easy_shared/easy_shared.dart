import 'package:shared_preferences/shared_preferences.dart';

/// A simple wrapper around [SharedPreferences].
///
/// Supports saving and retrieving [String], [int], [double], and [bool] values.
///
/// Do not instantiate directly — use [EasyStore.shared] after calling [EasyStore.init].
class EasyShared {
  EasyShared._(this._prefs);

  final SharedPreferences _prefs;

  /// Initializes and returns an [EasyShared] instance.
  static Future<EasyShared> init() async {
    final prefs = await SharedPreferences.getInstance();
    return EasyShared._(prefs);
  }

  /// Saves a value by [key].
  ///
  /// Supported types: [String], [int], [double], [bool].
  ///
  /// Throws [ArgumentError] if the value type is not supported.
  ///
  /// ```dart
  /// await EasyStore.shared.save("username", "Abanob");
  /// await EasyStore.shared.save("age", 22);
  /// await EasyStore.shared.save("isDark", true);
  /// ```
  Future<void> save(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else {
      throw ArgumentError(
        'Unsupported type: ${value.runtimeType}. '
        'Supported types: String, int, double, bool.',
      );
    }
  }

  /// Retrieves a value by [key].
  ///
  /// Returns [defaultValue] if the key does not exist.
  ///
  /// ```dart
  /// String name = EasyStore.shared.get("username", defaultValue: "Guest");
  /// bool isDark = EasyStore.shared.get("isDark", defaultValue: false);
  /// ```
  T? get<T>(String key, {T? defaultValue}) {
    final value = _prefs.get(key);
    if (value == null) return defaultValue;
    if (value is T) return value as T;
    return defaultValue;
  }

  /// Returns `true` if the [key] exists in storage.
  ///
  /// ```dart
  /// if (EasyStore.shared.has("username")) { ... }
  /// ```
  bool has(String key) => _prefs.containsKey(key);

  /// Deletes the value associated with [key].
  ///
  /// ```dart
  /// await EasyStore.shared.delete("username");
  /// ```
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  /// Deletes all stored key-value pairs.
  ///
  /// ```dart
  /// await EasyStore.shared.clear();
  /// ```
  Future<void> clear() async {
    await _prefs.clear();
  }

  /// Returns all stored keys.
  ///
  /// ```dart
  /// Set<String> keys = EasyStore.shared.keys;
  /// ```
  Set<String> get keys => _prefs.getKeys();
}

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageProvider = Provider<LocalStorage>(
  (_) => throw UnimplementedError('Init in main.dart'),
);

class LocalStorage {
  final SharedPreferences _prefs;
  LocalStorage(this._prefs);

  // JSON helpers
  Future<void> setJson(String key, Map<String, dynamic> value) async =>
      _prefs.setString(key, jsonEncode(value));

  Map<String, dynamic>? getJson(String key) {
    final s = _prefs.getString(key);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  Future<void> setJsonList(String key, List<dynamic> value) async =>
      _prefs.setString(key, jsonEncode(value));

  List<dynamic>? getJsonList(String key) {
    final s = _prefs.getString(key);
    if (s == null) return null;
    return jsonDecode(s) as List<dynamic>;
  }

  Future<void> setString(String key, String value) async =>
      _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<void> setInt(String key, int value) async =>
      _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  Future<void> setTimestamp(String key) async =>
      _prefs.setString(key, DateTime.now().toIso8601String());

  DateTime? getTimestamp(String key) {
    final s = _prefs.getString(key);
    return s != null ? DateTime.tryParse(s) : null;
  }

  bool isCacheValid(String timestampKey, Duration ttl) {
    final ts = getTimestamp(timestampKey);
    if (ts == null) return false;
    return DateTime.now().difference(ts) < ttl;
  }

  Future<void> remove(String key) async => _prefs.remove(key);
  Future<void> clear() async => _prefs.clear();
}

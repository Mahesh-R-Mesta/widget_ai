import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // String
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Bool
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // Int
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // JSON
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await _prefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final value = _prefs.getString(key);
    if (value != null) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (e) {
        Fluttertoast.showToast(msg: 'Failed to load json $e');
        return null;
      }
    }
    return null;
  }

  // Delete
  Future<bool> delete(String key) async {
    return await _prefs.remove(key);
  }

  // Clear all
  Future<bool> clear() async {
    return await _prefs.clear();
  }
}

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? sharedPreferences;

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    try {
      if (value is String) {
        return await sharedPreferences!.setString(key, value);
      }
      if (value is int) return await sharedPreferences!.setInt(key, value);
      if (value is bool) return await sharedPreferences!.setBool(key, value);
      if (value is double) {
        return await sharedPreferences!.setDouble(key, value);
      }

      // Handle lists and maps by converting to JSON
      if (value is List || value is Map) {
        final jsonString = jsonEncode(value);
        return await sharedPreferences!.setString(key, jsonString);
      }

      return false;
    } catch (e) {
      debugPrint('Cache save error: $e');
      return false;
    }
  }

  static dynamic getData({required String key}) {
    try {
      return sharedPreferences!.get(key);
    } catch (e) {
      debugPrint('Cache read error: $e');
      return null;
    }
  }

  static Future<bool> removeData({required String key}) async {
    return await sharedPreferences!.remove(key);
  }
}

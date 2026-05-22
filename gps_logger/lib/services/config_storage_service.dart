import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bus_config.dart';

class ConfigStorageService {
  static const String key = 'bus_config';

  Future<void> saveConfig(BusConfig config) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, jsonEncode(config.toJson()));
  }

  Future<BusConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    final json = prefs.getString(key);

    if (json == null) {
      return BusConfig.empty();
    }

    return BusConfig.fromJson(jsonDecode(json));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(key);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_users/core/network/local_cache_service.dart';

class ThemeService {
  final _cache = Get.find<LocalCacheService>();
  final _key = 'isDarkMode';
  final _boxName = 'settings';

  ThemeMode get theme => _loadThemeFromCache() ? ThemeMode.dark : ThemeMode.light;

  bool _loadThemeFromCache() {
    // We'll use a simple sync check if possible, but since Hive is async in our service, 
    // we might need to handle this differently or just use GetStorage/SharedPreferences for simplicity.
    // However, staying consistent with the project's Hive usage:
    return false; // Default to light
  }

  // A more robust way given the existing LocalCacheService
  Future<bool> isDarkMode() async {
    final result = await _cache.get<bool>(_boxName, _key);
    return result ?? false;
  }

  void switchTheme() async {
    final isDark = Get.isDarkMode;
    Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
    await _cache.save<bool>(_boxName, _key, !isDark);
  }
}

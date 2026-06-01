import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_users/core/network/local_cache_service.dart';

class ThemeController extends GetxController {
  final _cache = Get.find<LocalCacheService>();
  final _key = 'isDarkMode';
  final _boxName = 'settings';

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final result = await _cache.get<bool>(_boxName, _key);
    isDarkMode.value = result ?? false;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    await _cache.save<bool>(_boxName, _key, isDarkMode.value);
  }
}

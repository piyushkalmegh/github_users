import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

/// Local cache service using Hive
class LocalCacheService {
  final Logger _logger = Logger();

  /// Initialize Hive
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _logger.i('Hive initialized');
    } catch (e) {
      _logger.e('Hive initialization error: $e');
    }
  }

  /// Open a box safely
  Future<Box> _getOpenBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box(boxName);
      }
      return await Hive.openBox(boxName);
    } catch (e) {
      _logger.e('Error opening box $boxName: $e');
      rethrow;
    }
  }

  /// Get value from cache
  Future<T?> get<T>(String boxName, String key) async {
    try {
      final box = await _getOpenBox(boxName);
      final value = box.get(key);
      if (value == null) return null;
      return value as T;
    } catch (e) {
      _logger.e('Error getting from cache: $e');
      return null;
    }
  }

  /// Save value to cache
  Future<void> save<T>(String boxName, String key, T value) async {
    try {
      final box = await _getOpenBox(boxName);
      await box.put(key, value);
      _logger.d('Saved to cache: $key');
    } catch (e) {
      _logger.e('Error saving to cache: $e');
    }
  }

  /// Get all values from a box
  Future<List<T>> getAll<T>(String boxName) async {
    try {
      final box = await _getOpenBox(boxName);
      return box.values.cast<T>().toList();
    } catch (e) {
      _logger.e('Error getting all from cache: $e');
      return [];
    }
  }

  /// Delete value from cache
  Future<void> delete(String boxName, String key) async {
    try {
      final box = await _getOpenBox(boxName);
      await box.delete(key);
      _logger.d('Deleted from cache: $key');
    } catch (e) {
      _logger.e('Error deleting from cache: $e');
    }
  }

  /// Clear entire box
  Future<void> clearBox(String boxName) async {
    try {
      final box = await _getOpenBox(boxName);
      await box.clear();
      _logger.d('Cleared box: $boxName');
    } catch (e) {
      _logger.e('Error clearing box: $e');
    }
  }

  /// Check if key exists
  Future<bool> exists(String boxName, String key) async {
    try {
      final box = await _getOpenBox(boxName);
      return box.containsKey(key);
    } catch (e) {
      _logger.e('Error checking key existence: $e');
      return false;
    }
  }
}

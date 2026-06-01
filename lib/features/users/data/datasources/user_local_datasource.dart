import 'package:github_users/core/network/local_cache_service.dart';
import 'package:github_users/core/utils/constants.dart';
import 'package:github_users/features/users/data/models/user_model.dart';
import 'package:logger/logger.dart';

/// Abstract local data source for user operations
abstract class UserLocalDataSource {
  /// Get all favorite users
  Future<List<UserModel>> getFavoriteUsers();

  /// Add user to favorites
  Future<void> addFavorite({required UserModel user});

  /// Remove user from favorites
  Future<void> removeFavorite({required int userId});

  /// Check if user is favorite
  Future<bool> isFavorite({required int userId});

  /// Clear all favorites
  Future<void> clearFavorites();
}

/// Implementation of UserLocalDataSource
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final LocalCacheService _cacheService;
  final Logger _logger = Logger();

  UserLocalDataSourceImpl({required LocalCacheService cacheService})
      : _cacheService = cacheService;

  @override
  Future<List<UserModel>> getFavoriteUsers() async {
    try {
      _logger.d('Fetching favorite users from local cache');

      final favorites =
          await _cacheService.getAll<dynamic>(AppConstants.favoritesBoxName);

      final users = favorites.map((favData) {
        try {
          // Convert from potentially Map<dynamic, dynamic> to Map<String, dynamic>
          final Map<String, dynamic> fav = Map<String, dynamic>.from(favData as Map);
          return UserModel.fromJson(fav);
        } catch (e) {
          _logger.e('Error parsing favorite user data: $e');
          return null;
        }
      })
      .whereType<UserModel>()
      .toList();

      _logger.d('Found ${users.length} favorite users');
      return users;
    } catch (e) {
      _logger.e('Error fetching favorite users: $e');
      return [];
    }
  }

  @override
  Future<void> addFavorite({required UserModel user}) async {
    try {
      _logger.d('Adding user ${user.username} to favorites');

      await _cacheService.save<Map<String, dynamic>>(
        AppConstants.favoritesBoxName,
        user.id.toString(),
        user.toJson(),
      );

      _logger.d('Successfully added ${user.username} to favorites');
    } catch (e) {
      _logger.e('Error adding to favorites: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFavorite({required int userId}) async {
    try {
      _logger.d('Removing user $userId from favorites');

      await _cacheService.delete(AppConstants.favoritesBoxName, userId.toString());

      _logger.d('Successfully removed user $userId from favorites');
    } catch (e) {
      _logger.e('Error removing from favorites: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isFavorite({required int userId}) async {
    try {
      return await _cacheService.exists(
        AppConstants.favoritesBoxName,
        userId.toString(),
      );
    } catch (e) {
      _logger.e('Error checking favorite status: $e');
      return false;
    }
  }

  @override
  Future<void> clearFavorites() async {
    try {
      _logger.d('Clearing all favorites');

      await _cacheService.clearBox(AppConstants.favoritesBoxName);

      _logger.d('Successfully cleared all favorites');
    } catch (e) {
      _logger.e('Error clearing favorites: $e');
      rethrow;
    }
  }
}

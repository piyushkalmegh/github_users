
import 'package:github_users/features/users/domain/entities/user.dart';

/// Abstract repository for user operations
abstract class UserRepository {
  /// Get list of users with pagination
  Future<List<UserEntity>> getUsers({required int since, required int limit});

  /// Get user details by username
  Future<UserEntity> getUserDetails({required String username});

  /// Search users by query
  Future<List<UserEntity>> searchUsers({required String query, required int page});

  /// Get all favorite users
  Future<List<UserEntity>> getFavoriteUsers();

  /// Add user to favorites
  Future<void> addFavorite({required UserEntity user});

  /// Remove user from favorites
  Future<void> removeFavorite({required int userId});

  /// Check if user is favorite
  Future<bool> isFavorite({required int userId});

  /// Clear all favorites
  Future<void> clearFavorites();
}


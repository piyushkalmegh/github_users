import 'package:github_users/core/error/exceptions.dart';
import 'package:github_users/core/network/network_service.dart';
import 'package:github_users/features/users/data/datasources/user_local_datasource.dart';
import 'package:github_users/features/users/data/datasources/user_remote_datasource.dart';
import 'package:github_users/features/users/data/models/user_model.dart';
import 'package:github_users/features/users/domain/entities/user.dart';
import 'package:github_users/features/users/domain/repositories/user_repository.dart';
import 'package:logger/logger.dart';

/// Implementation of UserRepository
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;
  final NetworkService _networkService;
  final Logger _logger = Logger();

  UserRepositoryImpl({
    required UserRemoteDataSource remoteDataSource,
    required UserLocalDataSource localDataSource,
    required NetworkService networkService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkService = networkService;

  @override
  Future<List<UserEntity>> getUsers({
    required int since,
    required int limit,
  }) async {
    try {
      // Check internet connectivity
      final hasInternet = await _networkService.hasInternet();
      if (!hasInternet) {
        throw NetworkException(message: 'No internet connection');
      }

      _logger.d('Fetching users from remote source');

      // Fetch from API
      final userModels = await _remoteDataSource.getUsers(
        since: since,
        limit: limit,
      );

      // Convert to entities
      final users = userModels.map((model) => model.toEntity()).toList();

      _logger.d('Successfully fetched ${users.length} users');
      return users;
    } catch (e) {
      _logger.e('Error in getUsers: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> getUserDetails({required String username}) async {
    try {
      // Check internet connectivity
      final hasInternet = await _networkService.hasInternet();
      if (!hasInternet) {
        throw NetworkException(message: 'No internet connection');
      }

      _logger.d('Fetching user details for $username');

      // Fetch from API
      final userModel = await _remoteDataSource.getUserDetails(
        username: username,
      );

      // Convert to entity
      final user = userModel.toEntity();

      _logger.d('Successfully fetched user details for $username');
      return user;
    } catch (e) {
      _logger.e('Error in getUserDetails: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserEntity>> searchUsers({
    required String query,
    required int page,
  }) async {
    try {
      // Check internet connectivity
      final hasInternet = await _networkService.hasInternet();
      if (!hasInternet) {
        throw NetworkException(message: 'No internet connection');
      }

      _logger.d('Searching users with query=$query');

      // Fetch from API
      final userModels = await _remoteDataSource.searchUsers(
        query: query,
        page: page,
      );

      // Convert to entities
      final users = userModels.map((model) => model.toEntity()).toList();

      _logger.d('Successfully searched ${users.length} users');
      return users;
    } catch (e) {
      _logger.e('Error in searchUsers: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserEntity>> getFavoriteUsers() async {
    try {
      _logger.d('Fetching favorite users');

      final userModels = await _localDataSource.getFavoriteUsers();
      final users = userModels.map((model) => model.toEntity()).toList();

      _logger.d('Found ${users.length} favorite users');
      return users;
    } catch (e) {
      _logger.e('Error in getFavoriteUsers: $e');
      return [];
    }
  }

  @override
  Future<void> addFavorite({required UserEntity user}) async {
    try {
      _logger.d('Adding user ${user.username} to favorites');

      // Convert entity to model
      final userModel = UserModel(
        id: user.id,
        username: user.username,
        avatarUrl: user.avatarUrl,
        profileUrl: user.profileUrl,
        bio: user.bio,
        location: user.location,
        company: user.company,
        blog: user.blog,
        email: user.email,
        followers: user.followers,
        following: user.following,
        publicRepos: user.publicRepos,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      );

      await _localDataSource.addFavorite(user: userModel);

      _logger.d('Successfully added ${user.username} to favorites');
    } catch (e) {
      _logger.e('Error in addFavorite: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFavorite({required int userId}) async {
    try {
      _logger.d('Removing user $userId from favorites');

      await _localDataSource.removeFavorite(userId: userId);

      _logger.d('Successfully removed user $userId from favorites');
    } catch (e) {
      _logger.e('Error in removeFavorite: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isFavorite({required int userId}) async {
    try {
      return await _localDataSource.isFavorite(userId: userId);
    } catch (e) {
      _logger.e('Error in isFavorite: $e');
      return false;
    }
  }

  @override
  Future<void> clearFavorites() async {
    try {
      _logger.d('Clearing all favorites');

      await _localDataSource.clearFavorites();

      _logger.d('Successfully cleared all favorites');
    } catch (e) {
      _logger.e('Error in clearFavorites: $e');
      rethrow;
    }
  }
}


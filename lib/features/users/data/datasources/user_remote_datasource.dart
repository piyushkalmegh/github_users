import 'package:github_users/core/error/exceptions.dart';
import 'package:github_users/core/network/dio_client.dart';
import 'package:github_users/core/utils/constants.dart';
import 'package:github_users/features/users/data/models/user_model.dart';
import 'package:logger/logger.dart';

/// Abstract data source for user API operations
abstract class UserRemoteDataSource {
  /// Get list of users with pagination
  Future<List<UserModel>> getUsers({required int since, required int limit});

  /// Get user details by username
  Future<UserModel> getUserDetails({required String username});

  /// Search users by query
  Future<List<UserModel>> searchUsers({required String query, required int page});
}

/// Implementation of UserRemoteDataSource
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient _dioClient;
  final Logger _logger = Logger();

  UserRemoteDataSourceImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<List<UserModel>> getUsers({
    required int since,
    required int limit,
  }) async {
    try {
      _logger.d('Fetching users with since=$since, limit=$limit');

      final response = await _dioClient.get<List<dynamic>>(
        AppConstants.usersEndpoint,
        queryParameters: {
          'since': since,
          'per_page': limit,
        },
      );

      final users = response
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();

      _logger.d('Successfully fetched ${users.length} users');
      return users;
    } catch (e) {
      _logger.e('Error fetching users: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> getUserDetails({required String username}) async {
    try {
      _logger.d('Fetching user details for $username');
      
      // Encode username to handle special characters correctly
      final encodedUsername = Uri.encodeComponent(username);

      final response = await _dioClient.get<Map<String, dynamic>>(
        '${AppConstants.usersEndpoint}/$encodedUsername',
      );

      final user = UserModel.fromJson(response);
      _logger.d('Successfully fetched user details for $username');
      return user;
    } catch (e) {
      _logger.e('Error fetching user details: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserModel>> searchUsers({
    required String query,
    required int page,
  }) async {
    try {
      _logger.d('Searching users with query=$query, page=$page');

      final response = await _dioClient.get<Map<String, dynamic>>(
        '/search/users',
        queryParameters: {
          'q': query,
          'page': page,
          'per_page': AppConstants.pageSize,
        },
      );

      final items = response['items'] as List<dynamic>?;
      if (items == null) {
        throw ApiException(message: 'Invalid search response format');
      }

      final users = items
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();

      _logger.d('Successfully searched ${users.length} users');
      return users;
    } catch (e) {
      _logger.e('Error searching users: $e');
      rethrow;
    }
  }
}


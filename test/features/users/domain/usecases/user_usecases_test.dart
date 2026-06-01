import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_users/features/users/domain/entities/user.dart';
import 'package:github_users/features/users/domain/repositories/user_repository.dart';
import 'package:github_users/features/users/domain/usecases/user_usecases.dart';

// A simple fake repository to avoid Mockito complexity in this environment.
class FakeUserRepository implements UserRepository {
  Future<List<UserEntity>> Function({required int since, required int limit})?
      onGetUsers;

  @override
  Future<List<UserEntity>> getUsers({required int since, required int limit}) {
    if (onGetUsers != null) {
      return onGetUsers!(since: since, limit: limit);
    }
    return Future.value([]);
  }

  // Unused methods in these tests; provide basic implementations.
  @override
  Future<UserEntity> getUserDetails({required String username}) {
    throw UnimplementedError();
  }

  @override
  Future<List<UserEntity>> searchUsers({required String query, required int page}) {
    return Future.value([]);
  }

  @override
  Future<List<UserEntity>> getFavoriteUsers() {
    return Future.value([]);
  }

  @override
  Future<void> addFavorite({required UserEntity user}) async {}

  @override
  Future<void> removeFavorite({required int userId}) async {}

  @override
  Future<bool> isFavorite({required int userId}) async => false;

  @override
  Future<void> clearFavorites() async {}
}

void main() {
  group('User Use Cases', () {
    late GetUsersUseCase getUsersUseCase;
    late FakeUserRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeUserRepository();
      getUsersUseCase = GetUsersUseCase(repository: fakeRepository);
    });

    final testUser = UserEntity(
      id: 1,
      username: 'testuser',
      avatarUrl: 'https://example.com/avatar.jpg',
      profileUrl: 'https://github.com/testuser',
      followers: 100,
      following: 50,
      publicRepos: 10,
    );

    test('should call repository.getUsers with correct parameters', () async {
      fakeRepository.onGetUsers = ({required int since, required int limit}) async {
        expect(since, 0);
        expect(limit, 10);
        return [testUser];
      };

      final result = await getUsersUseCase(since: 0, limit: 10);

      expect(result, [testUser]);
    });

    test('should return empty list when no users found', () async {
      fakeRepository.onGetUsers = ({required int since, required int limit}) async {
        return [];
      };

      final result = await getUsersUseCase(since: 0, limit: 10);

      expect(result, []);
    });
  });
}


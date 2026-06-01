

import 'package:github_users/features/users/domain/entities/user.dart';
import 'package:github_users/features/users/domain/repositories/user_repository.dart';

/// Use case for getting users list
class GetUsersUseCase {
  final UserRepository repository;

  GetUsersUseCase({required this.repository});

  Future<List<UserEntity>> call({required int since, required int limit}) {
    return repository.getUsers(since: since, limit: limit);
  }
}

/// Use case for getting user details
class GetUserDetailsUseCase {
  final UserRepository repository;

  GetUserDetailsUseCase({required this.repository});

  Future<UserEntity> call({required String username}) {
    return repository.getUserDetails(username: username);
  }
}

/// Use case for searching users
class SearchUsersUseCase {
  final UserRepository repository;

  SearchUsersUseCase({required this.repository});

  Future<List<UserEntity>> call({required String query, required int page}) {
    return repository.searchUsers(query: query, page: page);
  }
}

/// Use case for getting favorite users
class GetFavoriteUsersUseCase {
  final UserRepository repository;

  GetFavoriteUsersUseCase({required this.repository});

  Future<List<UserEntity>> call() {
    return repository.getFavoriteUsers();
  }
}

/// Use case for adding favorite user
class AddFavoriteUseCase {
  final UserRepository repository;

  AddFavoriteUseCase({required this.repository});

  Future<void> call({required UserEntity user}) {
    return repository.addFavorite(user: user);
  }
}

/// Use case for removing favorite user
class RemoveFavoriteUseCase {
  final UserRepository repository;

  RemoveFavoriteUseCase({required this.repository});

  Future<void> call({required int userId}) {
    return repository.removeFavorite(userId: userId);
  }
}

/// Use case for checking if user is favorite
class IsFavoriteUseCase {
  final UserRepository repository;

  IsFavoriteUseCase({required this.repository});

  Future<bool> call({required int userId}) {
    return repository.isFavorite(userId: userId);
  }
}


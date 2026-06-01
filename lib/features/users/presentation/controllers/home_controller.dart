import 'package:get/get.dart';
import 'package:github_users/core/utils/constants.dart';
import 'package:github_users/features/users/domain/entities/user.dart';
import 'package:github_users/features/users/domain/usecases/user_usecases.dart';
import 'package:logger/logger.dart';
import 'package:github_users/features/users/presentation/controllers/favorites_controller.dart';
import 'package:github_users/features/users/presentation/controllers/user_details_controller.dart';

/// State enum for home screen
enum HomeScreenState { initial, loading, success, error, empty }

/// GetX controller for home screen
class HomeController extends GetxController {
  final GetUsersUseCase getUsersUseCase;
  final SearchUsersUseCase searchUsersUseCase;
  final IsFavoriteUseCase isFavoriteUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;

  final Logger _logger = Logger();

  // Observables
  final Rx<HomeScreenState> state = HomeScreenState.initial.obs;
  final RxList<UserEntity> users = <UserEntity>[].obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxMap<int, bool> favoriteStatus = <int, bool>{}.obs;

  // Pagination
  int _currentSince = AppConstants.initialSinceValue;
  bool _isLoadingMore = false;

  HomeController({
    required this.getUsersUseCase,
    required this.searchUsersUseCase,
    required this.isFavoriteUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
  });

  @override
  void onInit() {
    super.onInit();
    _loadUsers();

    // Debounce search to avoid too many API calls while typing
    debounce(
      searchQuery,
      (_) => _performSearch(),
      time: const Duration(milliseconds: 500),
    );
  }

  /// Load initial users list
  Future<void> _loadUsers() async {
    try {
      state.value = HomeScreenState.loading;
      _currentSince = AppConstants.initialSinceValue;
      users.clear();
      errorMessage.value = '';

      final result = await getUsersUseCase(
        since: _currentSince,
        limit: AppConstants.pageSize,
      );

      if (result.isEmpty) {
        state.value = HomeScreenState.empty;
        return;
      }

      users.addAll(result);
      _currentSince += AppConstants.pageSize;

      // Load favorite status for all users
      for (var user in result) {
        await _loadFavoriteStatus(user.id);
      }

      state.value = HomeScreenState.success;
    } catch (e) {
      _logger.e('Error loading users: $e');
      errorMessage.value = e.toString();
      state.value = HomeScreenState.error;
    }
  }

  /// Refresh users list
  Future<void> refreshUsers() async {
    try {
      _logger.d('Refreshing users list');
      if (searchQuery.isEmpty) {
        await _loadUsers();
      } else {
        await _performSearch();
      }
    } catch (e) {
      _logger.e('Error refreshing users: $e');
    }
  }

  /// Load more users (pagination)
  Future<void> loadMoreUsers() async {
    if (_isLoadingMore) return;
    // Don't load more if we are in a search result (API doesn't support simple 'since' pagination for search in same way)
    if (searchQuery.isNotEmpty) return;

    try {
      _isLoadingMore = true;
      _logger.d('Loading more users with since=$_currentSince');

      final result = await getUsersUseCase(
        since: _currentSince,
        limit: AppConstants.pageSize,
      );

      if (result.isNotEmpty) {
        users.addAll(result);
        _currentSince += AppConstants.pageSize;

        // Load favorite status for new users
        for (var user in result) {
          await _loadFavoriteStatus(user.id);
        }

        state.value = HomeScreenState.success;
      }
    } catch (e) {
      _logger.e('Error loading more users: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Search users by query (called from UI)
  void searchUsers(String query) {
    searchQuery.value = query;
    // Debounce worker in onInit will handle the actual search
  }

  /// Perform the actual search API call
  Future<void> _performSearch() async {
    final query = searchQuery.value;
    
    try {
      if (query.isEmpty) {
        _loadUsers();
        return;
      }

      _logger.d('Performing debounced search for: $query');
      state.value = HomeScreenState.loading;
      users.clear();
      errorMessage.value = '';

      final result = await searchUsersUseCase(query: query, page: 1);

      if (result.isEmpty) {
        state.value = HomeScreenState.empty;
        return;
      }

      users.addAll(result);

      // Load favorite status for all users
      for (var user in result) {
        await _loadFavoriteStatus(user.id);
      }

      state.value = HomeScreenState.success;
    } catch (e) {
      _logger.e('Error searching users: $e');
      errorMessage.value = e.toString();
      state.value = HomeScreenState.error;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(UserEntity user) async {
    // Optimistic UI: update state immediately, then call use case. Revert on error.
    final previous = favoriteStatus[user.id] ?? false;
    try {
      errorMessage.value = '';
      // Optimistically toggle
      favoriteStatus[user.id] = !previous;
      favoriteStatus.refresh();

      if (previous) {
        // Was favorite -> remove
        await removeFavoriteUseCase(userId: user.id);
      } else {
        // Was not favorite -> add
        await addFavoriteUseCase(user: user);
      }

      _syncExternalControllers(user, !previous);
      _logger.d('Favorite status toggled for ${user.username}');
    } catch (e) {
      // Revert optimistic change
      favoriteStatus[user.id] = previous;
      favoriteStatus.refresh();
      _logger.e('Error toggling favorite: $e');
      errorMessage.value = 'Failed to update favorite status';
    }
  }

  /// Sync with other controllers if they are alive
  void _syncExternalControllers(UserEntity user, bool isFavorite) {
    // Update local status as well to be safe
    favoriteStatus[user.id] = isFavorite;
    favoriteStatus.refresh();

    // Sync with FavoritesController
    try {
      if (Get.isRegistered<FavoritesController>()) {
        final favs = Get.find<FavoritesController>();
        if (isFavorite) {
          if (!favs.favorites.any((u) => u.id == user.id)) {
            favs.favorites.add(user);
          }
          if (favs.state.value == FavoritesScreenState.empty) {
            favs.state.value = FavoritesScreenState.success;
          }
        } else {
          favs.favorites.removeWhere((u) => u.id == user.id);
          if (favs.favorites.isEmpty) {
            favs.state.value = FavoritesScreenState.empty;
          }
        }
      }
    } catch (_) {}

    // Sync with UserDetailsController
    try {
      if (Get.isRegistered<UserDetailsController>()) {
        final detail = Get.find<UserDetailsController>();
        if (detail.user.value?.id == user.id) {
          detail.isFavorite.value = isFavorite;
        }
      }
    } catch (_) {}
  }

  /// Load favorite status for a user
  Future<void> _loadFavoriteStatus(int userId) async {
    try {
      final isFav = await isFavoriteUseCase(userId: userId);
      favoriteStatus[userId] = isFav;
    } catch (e) {
      _logger.e('Error loading favorite status: $e');
      favoriteStatus[userId] = false;
    }
  }

  /// Retry loading users after error
  Future<void> retryLoadUsers() async {
    if (searchQuery.isEmpty) {
      await _loadUsers();
    } else {
      await _performSearch();
    }
  }

  /// Get user count
  int get userCount => users.length;

  /// Check if currently loading more
  bool get isLoadingMore => _isLoadingMore;
}

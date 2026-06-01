import 'package:get/get.dart';
import 'package:github_users/features/users/domain/entities/user.dart';
import 'package:github_users/features/users/domain/usecases/user_usecases.dart';
import 'package:logger/logger.dart';
import 'package:github_users/features/users/presentation/controllers/home_controller.dart';
import 'package:github_users/features/users/presentation/controllers/user_details_controller.dart';

/// State enum for favorites screen
enum FavoritesScreenState { initial, loading, success, empty, error }

/// GetX controller for favorites screen
class FavoritesController extends GetxController {
  final GetFavoriteUsersUseCase getFavoriteUsersUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;

  final Logger _logger = Logger();

  // Observables
  final Rx<FavoritesScreenState> state = FavoritesScreenState.initial.obs;
  final RxList<UserEntity> favorites = <UserEntity>[].obs;
  final RxString errorMessage = ''.obs;

  FavoritesController({
    required this.getFavoriteUsersUseCase,
    required this.removeFavoriteUseCase,
    required this.addFavoriteUseCase,
  });

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  /// Load favorite users
  Future<void> loadFavorites({bool showLoading = true}) async {
    try {
      if (showLoading) {
        state.value = FavoritesScreenState.loading;
      }
      errorMessage.value = '';
      _logger.d('Loading favorite users');

      final result = await getFavoriteUsersUseCase();

      if (result.isEmpty) {
        state.value = FavoritesScreenState.empty;
        favorites.clear();
        return;
      }

      favorites.assignAll(result);
      state.value = FavoritesScreenState.success;

      _logger.d('Loaded ${result.length} favorite users');
    } catch (e) {
      _logger.e('Error loading favorites: $e');
      errorMessage.value = e.toString();
      state.value = FavoritesScreenState.error;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(UserEntity user) async {
    final bool isFav = favorites.any((u) => u.id == user.id);
    
    if (isFav) {
      await removeFavorite(user);
    } else {
      await addFavorite(user);
    }
  }

  /// Add user to favorites
  Future<void> addFavorite(UserEntity user) async {
    try {
      _logger.d('Adding ${user.username} to favorites');
      errorMessage.value = '';

      // Optimistic update
      if (!favorites.any((u) => u.id == user.id)) {
        favorites.add(user);
        if (state.value == FavoritesScreenState.empty || state.value == FavoritesScreenState.initial) {
          state.value = FavoritesScreenState.success;
        }
      }

      await addFavoriteUseCase(user: user);
      _syncExternalControllers(user.id, true);
      
      _logger.d('Successfully added ${user.username} to favorites');
    } catch (e) {
      _logger.e('Error adding favorite: $e');
      // Revert optimistic update
      favorites.removeWhere((u) => u.id == user.id);
      if (favorites.isEmpty) {
        state.value = FavoritesScreenState.empty;
      }
      errorMessage.value = 'Failed to add favorite';
    }
  }

  /// Remove user from favorites
  Future<void> removeFavorite(UserEntity user) async {
    final originalFavorites = List<UserEntity>.from(favorites);
    final originalState = state.value;

    try {
      _logger.d('Removing ${user.username} from favorites');
      errorMessage.value = '';

      // Optimistic update
      favorites.removeWhere((u) => u.id == user.id);
      if (favorites.isEmpty) {
        state.value = FavoritesScreenState.empty;
      }

      await removeFavoriteUseCase(userId: user.id);
      _syncExternalControllers(user.id, false);

      _logger.d('Successfully removed ${user.username} from favorites');
    } catch (e) {
      _logger.e('Error removing favorite: $e');
      // Revert optimistic update
      favorites.assignAll(originalFavorites);
      state.value = originalState;
      errorMessage.value = 'Failed to remove favorite';
    }
  }

  /// Sync with other controllers if they are alive
  void _syncExternalControllers(int userId, bool isFavorite) {
    // Sync with HomeController
    try {
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        home.favoriteStatus[userId] = isFavorite;
        home.favoriteStatus.refresh();
      }
    } catch (_) {}

    // Sync with UserDetailsController
    try {
      if (Get.isRegistered<UserDetailsController>()) {
        final detail = Get.find<UserDetailsController>();
        if (detail.user.value?.id == userId) {
          detail.isFavorite.value = isFavorite;
        }
      }
    } catch (_) {}
  }

  /// Refresh favorites list
  Future<void> refreshFavorites() async {
    await loadFavorites(showLoading: false);
  }

  /// Get favorite count
  int get favoriteCount => favorites.length;
}

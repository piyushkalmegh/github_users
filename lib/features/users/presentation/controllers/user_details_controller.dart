import 'package:get/get.dart';
import 'package:github_users/features/users/domain/entities/user.dart';
import 'package:github_users/features/users/domain/usecases/user_usecases.dart';
import 'package:logger/logger.dart';
import 'package:github_users/features/users/presentation/controllers/home_controller.dart';
import 'package:github_users/features/users/presentation/controllers/favorites_controller.dart';

/// State enum for details screen
enum DetailsScreenState { loading, success, error }

/// GetX controller for user details screen
class UserDetailsController extends GetxController {
  final GetUserDetailsUseCase getUserDetailsUseCase;
  final IsFavoriteUseCase isFavoriteUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;

  final Logger _logger = Logger();

  // Observables
  final Rx<DetailsScreenState> state = DetailsScreenState.loading.obs;
  final Rx<UserEntity?> user = Rx<UserEntity?>(null);
  final RxBool isFavorite = false.obs;
  final RxString errorMessage = ''.obs;

  late String username;

  UserDetailsController({
    required this.getUserDetailsUseCase,
    required this.isFavoriteUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
  });

  @override
  void onInit() {
    super.onInit();
    username = Get.arguments ?? '';
    _loadUserDetails();
  }

  /// Load user details
  Future<void> _loadUserDetails() async {
    try {
      state.value = DetailsScreenState.loading;
      _logger.d('Loading user details for $username');
      errorMessage.value = '';

      final result = await getUserDetailsUseCase(username: username);
      user.value = result;

      // Load favorite status
      await _loadFavoriteStatus(result.id);

      state.value = DetailsScreenState.success;
    } catch (e) {
      _logger.e('Error loading user details: $e');
      errorMessage.value = e.toString();
      state.value = DetailsScreenState.error;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite() async {
    try {
      final currentUser = user.value;
      if (currentUser == null) return;
      errorMessage.value = '';

      if (isFavorite.value) {
        // Remove from favorites
        await removeFavoriteUseCase(userId: currentUser.id);
        isFavorite.value = false;
        _syncExternalControllers(currentUser, false);
      } else {
        // Add to favorites
        await addFavoriteUseCase(user: currentUser);
        isFavorite.value = true;
        _syncExternalControllers(currentUser, true);
      }

      _logger.d('Favorite status toggled for ${currentUser.username}');
    } catch (e) {
      _logger.e('Error toggling favorite: $e');
      errorMessage.value = 'Failed to update favorite status';
    }
  }

  /// Sync with other controllers if they are alive
  void _syncExternalControllers(UserEntity user, bool isFavorite) {
    // Sync with HomeController
    try {
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        home.favoriteStatus[user.id] = isFavorite;
        home.favoriteStatus.refresh();
      }
    } catch (_) {}

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
  }

  /// Load favorite status
  Future<void> _loadFavoriteStatus(int userId) async {
    try {
      final isFav = await isFavoriteUseCase(userId: userId);
      isFavorite.value = isFav;
    } catch (e) {
      _logger.e('Error loading favorite status: $e');
      isFavorite.value = false;
    }
  }

  /// Retry loading user details
  Future<void> retryLoadDetails() async {
    await _loadUserDetails();
  }
}

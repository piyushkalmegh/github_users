import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_users/core/utils/constants.dart';
import 'package:github_users/core/navigation/app_routes.dart';
import 'package:github_users/features/users/presentation/controllers/favorites_controller.dart';
import 'package:github_users/features/users/presentation/widgets/empty_view.dart';
import 'package:github_users/features/users/presentation/widgets/error_view.dart';
import 'package:github_users/features/users/presentation/widgets/user_card.dart';

/// Favorites screen
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesController controller = Get.find<FavoritesController>();

  @override
  void initState() {
    super.initState();
    // Ensure favorites are refreshed whenever this screen is pushed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadFavorites(showLoading: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        automaticallyImplyLeading: false, 
        leading: null,
        title: Text(
          AppStrings.favoriteUsers,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        return _buildContent();
      }),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildContent() {
    switch (controller.state.value) {
      case FavoritesScreenState.loading:
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFF0969DA),
            ),
          ),
        );
      case FavoritesScreenState.empty:
        return EmptyView(
          title: AppStrings.noFavorites,
          message: 'Start adding your favorite users',
          icon: Icons.favorite_outline,
        );
      case FavoritesScreenState.error:
        return ErrorView(
          message: controller.errorMessage.value,
          onRetry: controller.loadFavorites,
        );
      case FavoritesScreenState.success:
        return _buildFavoritesList();
      case FavoritesScreenState.initial:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFavoritesList() {
    return RefreshIndicator(
      onRefresh: controller.refreshFavorites,
      child: ListView.builder(
        itemCount: controller.favorites.length,
        itemBuilder: (context, index) {
          final user = controller.favorites[index];

          return UserCard(
            user: user,
            isFavorite: true,
              onTap: () {
                Get.toNamed(AppRoutes.details, arguments: user.username, preventDuplicates: false);
              },
            onFavoriteTap: () {
              controller.removeFavorite(user);
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.offNamed(AppRoutes.home); 
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFF0969DA),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Favorites',
                        style: TextStyle(
                          color: const Color(0xFF0969DA),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

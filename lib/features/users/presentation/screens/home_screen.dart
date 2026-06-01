import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_users/core/utils/constants.dart';
import 'package:github_users/core/navigation/app_routes.dart';
import 'package:github_users/features/users/presentation/controllers/home_controller.dart';
import 'package:github_users/features/users/presentation/controllers/theme_controller.dart';
import 'package:github_users/features/users/presentation/widgets/empty_view.dart';
import 'package:github_users/features/users/presentation/widgets/error_view.dart';
import 'package:github_users/features/users/presentation/widgets/user_card.dart';
import 'package:github_users/features/users/presentation/widgets/user_card_skeleton.dart';

/// Home screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.find<HomeController>();
  final ThemeController themeController = Get.find<ThemeController>();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (!controller.isLoadingMore) {
        controller.loadMoreUsers();
      }
    }
  }

  void _onSearchChanged(String query) {
    controller.searchUsers(query);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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
          AppStrings.appTitle,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              themeController.isDarkMode.value 
                ? Icons.light_mode_rounded 
                : Icons.dark_mode_rounded,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: themeController.toggleTheme,
            tooltip: 'Toggle Theme',
          )),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: AppStrings.searchUsers,
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Obx(() {
              return _buildContent();
            }),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildContent() {
    switch (controller.state.value) {
      case HomeScreenState.loading:
        return UserCardSkeleton();
      case HomeScreenState.empty:
        return EmptyView(
          title: AppStrings.noUsers,
          message: AppStrings.trySearchingForAUser,
          icon: Icons.search_off,
        );
      case HomeScreenState.error:
        return ErrorView(
          message: controller.errorMessage.value,
          onRetry: controller.retryLoadUsers,
        );
      case HomeScreenState.success:
        return _buildUsersList();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildUsersList() {
    return RefreshIndicator(
      onRefresh: controller.refreshUsers,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: controller.users.length + (controller.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show skeleton at the end when loading more
          if (index == controller.users.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF0969DA),
                  ),
                ),
              ),
            );
          }

          final user = controller.users[index];
          
          // Wrap UserCard in Obx for item-level reactivity
          return Obx(() {
            final isFav = controller.favoriteStatus[user.id] ?? false;
            return UserCard(
              user: user,
              isFavorite: isFav,
              onTap: () {
                Get.toNamed(AppRoutes.details, arguments: user.username, preventDuplicates: false);
              },
              onFavoriteTap: () {
                controller.toggleFavorite(user);
              },
            );
          });
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
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
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
                        Icons.home_filled,
                        color: Color(0xFF0969DA),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Home',
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
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.offNamed(AppRoutes.favorites); 
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_outline,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Favorites',
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
        ],
      ),
    );
  }
}

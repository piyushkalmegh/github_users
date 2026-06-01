import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_users/core/utils/constants.dart';
import 'package:github_users/features/users/presentation/controllers/user_details_controller.dart';
import 'package:github_users/features/users/presentation/widgets/error_view.dart';

/// User details screen
class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late UserDetailsController controller;

  @override
  void initState() {
    super.initState();
    // Controller is already registered in ServiceLocator, we just find it.
    // Since we delete it in dispose, Get.find will trigger fenix re-creation.
    controller = Get.find<UserDetailsController>();
  }

  @override
  void dispose() {
    // Delete controller to ensure it's re-initialized with new arguments next time
    Get.delete<UserDetailsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.userDetails,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        switch (controller.state.value) {
          case DetailsScreenState.loading:
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0969DA)),
              ),
            );
          case DetailsScreenState.error:
            return ErrorView(
              message: controller.errorMessage.value,
              onRetry: controller.retryLoadDetails,
            );
          case DetailsScreenState.success:
            return _buildContent();
        }
      }),
    );
  }

  Widget _buildContent() {
    final user = controller.user.value;
    if (user == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Avatar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Hero(
              tag: 'user_avatar_${user.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: user.avatarUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.person),
                  ),
                ),
              ),
            ),
          ),
          // Username
          Text(
            user.username,
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Bio
          if (user.bio != null && user.bio!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                user.bio!,
                style: TextStyle(
                  fontSize: 14, 
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 24),
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(AppStrings.followers, user.followers.toString()),
                _buildStatCard(AppStrings.following, user.following.toString()),
                _buildStatCard(AppStrings.repos, user.publicRepos.toString()),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Additional Info
          if (user.location != null && user.location!.isNotEmpty)
            _buildInfoRow(Icons.location_on_outlined, user.location!),
          if (user.company != null && user.company!.isNotEmpty)
            _buildInfoRow(Icons.business_outlined, user.company!),
          if (user.blog != null && user.blog!.isNotEmpty)
            _buildInfoRow(Icons.link, user.blog!),
          const SizedBox(height: 32),
          // Favorite button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.toggleFavorite,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isFavorite.value
                        ? Colors.red
                        : const Color(0xFF0969DA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        controller.isFavorite.value
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.isFavorite.value
                            ? AppStrings.removeFromFavorite
                            : AppStrings.markAsFavorite,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0969DA),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              fontSize: 12, 
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14, 
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

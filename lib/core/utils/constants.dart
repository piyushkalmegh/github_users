/// Application-wide constants
class AppConstants {
  // API
  static const String baseUrl = 'https://api.github.com';
  static const String usersEndpoint = '/users';
  static const int pageSize = 10;
  static const int connectionTimeout = 30000; // ms
  static const int receiveTimeout = 30000; // ms

  // App
  static const String appName = 'GitHub Users';

  // Hive Boxes
  static const String favoritesBoxName = 'favorites';
  static const String usersBoxName = 'users_cache';
  static const String userDetailsBoxName = 'user_details_cache';

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);

  // Pagination
  static const int initialSinceValue = 0;
}

class AppStrings {
  // General
  static const String appTitle = 'GitHub Users';
  static const String appLabel = 'Professional Developer Insights';
  static const String errorOccurred = 'An error occurred';
  static const String tryAgain = 'Try Again';
  static const String noInternet = 'No internet connection';
  static const String loading = 'Loading...';

  // Home Screen
  static const String searchUsers = 'Search users';
  static const String usersList = 'Users List';
  static const String noUsers = 'No users found';
  static const String trySearchingForAUser = 'Try searching for a user';
  static const String pullToRefresh = 'Pull to refresh';

  // Details Screen
  static const String userDetails = 'User Details';
  static const String followers = 'Followers';
  static const String following = 'Following';
  static const String repos = 'Repos';
  static const String markAsFavorite = 'Mark as Favorite';
  static const String removeFromFavorite = 'Remove from Favorite';

  // Favorites Screen
  static const String favoriteUsers = 'Favorite Users';
  static const String noFavorites = 'No favorites yet';

  // Error States
  static const String somethingWentWrong = 'Something went wrong';
  static const String userNotFound = 'User not found';
  static const String failedToLoadUsers = 'Failed to load users';
}


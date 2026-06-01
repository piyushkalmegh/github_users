import 'package:get/get.dart';
import 'package:github_users/features/users/presentation/screens/favorites_screen.dart';
import 'package:github_users/features/users/presentation/screens/home_screen.dart';
import 'package:github_users/features/users/presentation/screens/splash_screen.dart';
import 'package:github_users/features/users/presentation/screens/user_details_screen.dart';

/// App routes
class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String details = '/details';
  static const String favorites = '/favorites';

  static List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: details,
      page: () => const UserDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: favorites,
      page: () => const FavoritesScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}

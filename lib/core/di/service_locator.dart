import 'package:get/get.dart';
import 'package:github_users/core/network/dio_client.dart';
import 'package:github_users/core/network/local_cache_service.dart';
import 'package:github_users/core/network/network_service.dart';
import 'package:github_users/features/users/data/datasources/user_local_datasource.dart';
import 'package:github_users/features/users/data/datasources/user_remote_datasource.dart';
import 'package:github_users/features/users/data/repositories/user_repository_impl.dart';
import 'package:github_users/features/users/domain/repositories/user_repository.dart';
import 'package:github_users/features/users/domain/usecases/user_usecases.dart';
import 'package:github_users/features/users/presentation/controllers/favorites_controller.dart';
import 'package:github_users/features/users/presentation/controllers/home_controller.dart';
import 'package:github_users/features/users/presentation/controllers/user_details_controller.dart';

import 'package:github_users/features/users/presentation/controllers/theme_controller.dart';

/// Service locator - Setup all dependencies
class ServiceLocator {
  static Future<void> setup() async {
    // Core dependencies
    Get.lazyPut<DioClient>(() => DioClient(), fenix: true);
    Get.lazyPut<NetworkService>(() => NetworkService(), fenix: true);
    Get.lazyPut<LocalCacheService>(() => LocalCacheService(), fenix: true);

    // Initialize local cache
    await Get.find<LocalCacheService>().init();

    // Theme Controller
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // Data sources
    Get.lazyPut<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(dioClient: Get.find<DioClient>()),
      fenix: true,
    );
    Get.lazyPut<UserLocalDataSource>(
      () => UserLocalDataSourceImpl(cacheService: Get.find<LocalCacheService>()),
      fenix: true,
    );

    // Repository
    Get.lazyPut<UserRepository>(
      () => UserRepositoryImpl(
        remoteDataSource: Get.find<UserRemoteDataSource>(),
        localDataSource: Get.find<UserLocalDataSource>(),
        networkService: Get.find<NetworkService>(),
      ),
      fenix: true,
    );

    // Use cases - Using fenix: true to ensure they can be re-instantiated if needed
    Get.lazyPut<GetUsersUseCase>(
      () => GetUsersUseCase(repository: Get.find<UserRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetUserDetailsUseCase>(
      () => GetUserDetailsUseCase(repository: Get.find<UserRepository>()),
      fenix: true,
    );
    Get.lazyPut<SearchUsersUseCase>(
      () => SearchUsersUseCase(repository: Get.find<UserRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetFavoriteUsersUseCase>(
      () => GetFavoriteUsersUseCase(repository: Get.find<UserRepository>()),
      fenix: true,
    );
    Get.lazyPut<AddFavoriteUseCase>(
      () => AddFavoriteUseCase(repository: Get.find<UserRepository>()),
      fenix: true,
    );
    Get.lazyPut<RemoveFavoriteUseCase>(
      () => RemoveFavoriteUseCase(repository: Get.find<UserRepository>()),
      fenix: true,
    );
    Get.lazyPut<IsFavoriteUseCase>(
      () => IsFavoriteUseCase(repository: Get.find<UserRepository>()),
      fenix: true,
    );

    // Controllers
    // HomeController and FavoritesController are permanent singletons
    Get.put<HomeController>(
      HomeController(
        getUsersUseCase: Get.find<GetUsersUseCase>(),
        searchUsersUseCase: Get.find<SearchUsersUseCase>(),
        isFavoriteUseCase: Get.find<IsFavoriteUseCase>(),
        addFavoriteUseCase: Get.find<AddFavoriteUseCase>(),
        removeFavoriteUseCase: Get.find<RemoveFavoriteUseCase>(),
      ),
      permanent: true,
    );

    Get.put<FavoritesController>(
      FavoritesController(
        getFavoriteUsersUseCase: Get.find<GetFavoriteUsersUseCase>(),
        removeFavoriteUseCase: Get.find<RemoveFavoriteUseCase>(),
        addFavoriteUseCase: Get.find<AddFavoriteUseCase>(),
      ),
      permanent: true,
    );

    // UserDetailsController needs to be re-created for each user
    Get.lazyPut<UserDetailsController>(
      () => UserDetailsController(
        getUserDetailsUseCase: Get.find<GetUserDetailsUseCase>(),
        isFavoriteUseCase: Get.find<IsFavoriteUseCase>(),
        addFavoriteUseCase: Get.find<AddFavoriteUseCase>(),
        removeFavoriteUseCase: Get.find<RemoveFavoriteUseCase>(),
      ),
      fenix: true,
    );
  }
}

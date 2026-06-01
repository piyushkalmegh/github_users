# 📚 GitHub Users - Flutter App

A Flutter application for exploring GitHub users with advanced features like pagination, search, favorites, and real-time state synchronization.

## Quick Start

```bash
Go to project path: cd "D:\Studio Projects\github_users"
flutter pub get
flutter pub run build_runner build
flutter run
```

**Note for Web**: If running on Web, use the following command to bypass potential CORS issues during development:
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

## Architecture & Tech Stack

- **Framework**: Flutter (Null Safe)
- **State Management**: **GetX** (Controllers, Workers, and Reactive state)
- **Network**: **Dio** with custom interceptors and GitHub-specific headers.
- **Local Storage**: **Hive** (Optimized with type-safe caching and box management).
- **Architecture**: **Clean Architecture** (Data, Domain, and Presentation layers).
- **Service Locator**: Manual dependency injection with `Get.lazyPut` and `fenix` support.

## Technical Implementation Details

### GitHub API Integration
The app uses the official GitHub REST API. To ensure compatibility:
- Required headers: `User-Agent` and `X-GitHub-Api-Version` are included.
- `Accept: application/vnd.github+json` is used for consistent response formats.
- Connectivity is monitored via `connectivity_plus` with platform-specific handling.

### Local Storage Optimization
- Uses Hive for lightweight and fast persistence.
- Implemented a robust `LocalCacheService` to prevent "Box already open" errors.
- Automatic data conversion from Hive's `Map<dynamic, dynamic>` to type-safe `UserModel`.

### Navigation Strategy
- Optimized stack management using `Get.offNamed` for top-level screens.
- Proper controller lifecycle management (Automatic disposal and re-creation of detail controllers).

## 📱 Project Structure

```
lib/
├── core/
│   ├── di/             # Service Locator (Dependency Injection)
│   ├── error/          # Custom exceptions and failures
│   ├── navigation/     # Route configuration
│   ├── network/        # Dio client & Connectivity service
│   └── utils/          # Constants and helpers
├── features/users/
│   ├── data/           # Repositories & Data Sources (Remote/Local)
│   ├── domain/         # Entities & Use Cases (Business Logic)
│   └── presentation/   # UI Screens, Widgets & GetX Controllers
```

## Stats
- **Dependencies**: 13 (Dio, Get, Hive, etc.)
- **State Management**: Reactive (Obx)
- **Quality**: SOLID principles, Repository pattern, Clean Architecture.

---

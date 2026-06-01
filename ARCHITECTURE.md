# GitHub Users - Flutter App

A Flutter application for exploring GitHub users with advanced features like pagination, search, favorites, and local persistence.

## 📱 Features

- **User List**: Browse GitHub users with smooth pagination
- **Search**: Debounced search to find specific users
- **User Details**: View comprehensive user information with hero animations
- **Favorites**: Save and manage favorite users locally
- **Pull-to-Refresh**: Refresh data with smooth animations
- **Infinite Scrolling**: Automatic pagination as you scroll
- **Skeleton Loading**: Shimmer effect during data loading
- **Error Handling**: Comprehensive error states with retry mechanism
- **Network Detection**: Automatic handling of connectivity issues
- **Dark Mode**: Full dark theme support
- **Caching**: Smart local and network caching

## 🏗️ Architecture

This project follows **Clean Architecture** with clear separation of concerns:

```
lib/
├── core/                          # Core utilities and services
│   ├── di/
│   │   └── service_locator.dart  # GetX dependency injection setup
│   ├── error/
│   ���   └── exceptions.dart       # Custom exceptions
│   ├── navigation/
│   │   └── app_routes.dart       # App routing
│   ├── network/
│   │   ├── dio_client.dart       # HTTP client wrapper
│   │   ├── local_cache_service.dart  # Hive cache service
│   │   └── network_service.dart  # Connectivity service
│   └── utils/
│       └── constants.dart        # App constants
│
├── features/
│   └── users/
│       ├── data/                 # Data layer
│       │   ├── datasources/
│       │   │   ├── user_local_datasource.dart
│       │   │   └── user_remote_datasource.dart
│       │   ├── models/
│       │   │   └── user_model.dart
│       │   └── repositories/
│       │       └── user_repository_impl.dart
│       │
│       ├── domain/               # Domain layer
│       │   ├── entities/
│       │   │   └── user.dart
│       │   ├── repositories/
│       │   │   └── user_repository.dart
│       │   └── usecases/
│       │       └── user_usecases.dart
│       │
│       └── presentation/         # Presentation layer
│           ├── controllers/
│           │   ├── home_controller.dart
│           │   ├── user_details_controller.dart
│           │   └── favorites_controller.dart
│           ├── screens/
│           │   ├── splash_screen.dart
│           │   ├── home_screen.dart
│           │   ├── user_details_screen.dart
│           │   └── favorites_screen.dart
│           └── widgets/
│               ├── user_card.dart
│               ├── user_card_skeleton.dart
│               ├── error_view.dart
│               └── empty_view.dart
│
└── main.dart
```

## 🎯 Technical Stack

- **State Management**: GetX - Reactive and lightweight state management
- **API Client**: Dio - Powerful HTTP client with interceptors
- **Local Storage**: Hive - Fast and lightweight local database
- **Network Detection**: Connectivity Plus - Monitor network connectivity
- **Image Loading**: Cached Network Image - With caching support
- **Shimmer Effect**: Shimmer - Skeleton loading animations
- **Logging**: Logger - Structured logging
- **Testing**: Mockito & Flutter Test

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.11.5)
- Dart SDK (>=3.11.5)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd github_users
```

2. Install dependencies
```bash
flutter pub get
```

3. Generate JSON serialization code (if not auto-generated)
```bash
flutter pub run build_runner build
```

4. Run the app
```bash
flutter run
```

## 📖 API Reference

### Base URL
```
https://api.github.com
```

### Endpoints Used

1. **Get Users List**
   - `GET /users?since=0&per_page=10`
   - Pagination via `since` parameter

2. **Get User Details**
   - `GET /users/{username}`
   - Detailed user information

3. **Search Users**
   - `GET /search/users?q=query&page=1&per_page=10`
   - Full-text search across GitHub

## 🎨 UI/UX Features

### Screens

1. **Splash Screen**
   - Animated app logo and name
   - Loading indicator at bottom
   - Version display
   - Auto-navigation after 3 seconds

2. **Home Screen**
   - AppBar with title
   - Full-width search bar with debouncing
   - User list with infinite scrolling
   - Pull-to-refresh capability
   - Favorite toggle for each user
   - Bottom navigation bar

3. **User Details Screen**
   - Hero animation from avatar
   - User avatar, name, and bio
   - Stats (Followers, Following, Repos)
   - Additional info (Location, Company, Blog)
   - Mark as Favorite CTA button
   - Back navigation

4. **Favorites Screen**
   - List of favorited users
   - Pull-to-refresh capability
   - Empty state message
   - Remove from favorites option
   - Bottom navigation bar

## 💾 Data Persistence

### Local Storage
- Uses Hive for fast local persistence
- Stores favorite users with full details
- Automatic serialization/deserialization

### Favorites Box Structure
```dart
{
  'id': int,
  'username': String,
  'avatarUrl': String,
  'profileUrl': String,
  'bio': String?,
  'location': String?,
  'company': String?,
  'blog': String?,
  'email': String?,
  'followers': int,
  'following': int,
  'publicRepos': int,
  'createdAt': String?,
  'updatedAt': String?,
}
```

## 🔍 Advanced Features

### Search Implementation
- Debounced search (300ms delay)
- Clears results on empty query
- Uses GitHub search API for accuracy

### Pagination
- Implements cursor-based pagination
- Uses `since` parameter with user IDs
- Automatic loading on scroll threshold

### Error Handling
- Network connectivity checks
- API error response handling
- Cache fallback for failed requests
- User-friendly error messages
- Retry mechanism with CTA

### State Management
- Reactive observables with GetX
- Optimistic UI updates
- Proper disposal of resources
- Lazy initialization of controllers

### Performance Optimizations
- Image caching with Cached Network Image
- Skeleton loading instead of spinners
- Efficient list rebuilding with Obx
- Lazy loading of dependencies
- Network request debouncing

## 🧪 Testing

### Unit Tests
Located in `test/features/users/`

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/users/domain/usecases/user_usecases_test.dart

# Run with coverage
flutter test --coverage
```

### Test Files Included
- `user_model_test.dart` - Model serialization tests
- `user_usecases_test.dart` - Use case logic tests
- `user_card_test.dart` - Widget tests

## 📱 Screens Breakdown

### Splash Screen
- Displays app icon (code icon in blue box)
- Shows app name: "GitHub Users"
- Shows tagline: "Professional Developer Insights"
- Loading progress bar at bottom
- Version badge
- 3-second auto-navigation to Home

### Home Screen
- AppBar: "GitHub Users" title
- Search bar (full-width, rounded)
- Users list with pagination
- Each card shows:
  - User avatar (rounded square)
  - Username (bold, blue)
  - User ID
  - Favorite heart icon
- Pull-to-refresh support
- Infinite scroll pagination
- Bottom navigation (Home/Favorites toggle)

### User Details Screen
- AppBar with back button and "User Details" title
- Large centered avatar with hero animation
- Username (bold)
- Bio (if available)
- Stats row: Followers | Following | Repos
- Additional info:
  - Location
  - Company
  - Blog link
- "Mark as Favorite" button (blue)
- Changes to "Remove from Favorite" when favorited

### Favorites Screen
- Same layout as Home but only favorite users
- Title: "Favorite Users (count)"
- Empty state: "No favorites yet"
- Remove from favorites on tap
- Pull-to-refresh support

## 🔐 Error Handling

The app handles multiple error scenarios:

1. **No Internet Connection**
   - Shows network error view
   - Provides retry option

2. **API Errors**
   - Rate limiting (429)
   - Not found (404)
   - Server errors (500)
   - Timeout errors

3. **Local Storage Errors**
   - Gracefully handles cache failures
   - Falls back to fresh API calls

4. **Data Parsing Errors**
   - Validates JSON responses
   - Shows appropriate error messages

## 🎯 Key Decisions

1. **GetX over Provider**: Lightweight, reactive, and built-in routing
2. **Clean Architecture**: Testable, maintainable, and scalable
3. **Dio for HTTP**: Interceptors, retry logic, and request/response handling
4. **Hive for Cache**: Fast, reliable local persistence
5. **Skeleton Loading**: Better UX than spinners
6. **Hero Animations**: Smooth visual transitions

## 📝 Code Quality

- Null safety enabled
- Const constructors used where possible
- Proper error handling throughout
- Comprehensive logging
- Well-documented code with comments
- Following Dart style guide

## 🚀 Deployment

### Android
```bash
flutter build apk
# or
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

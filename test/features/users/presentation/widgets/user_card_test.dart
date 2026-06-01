import 'package:flutter_test/flutter_test.dart';
import 'package:github_users/features/users/presentation/widgets/user_card.dart';
import 'package:github_users/features/users/domain/entities/user.dart';
import 'package:flutter/material.dart';

void main() {
  group('UserCard Widget', () {

    testWidgets('should display user card with correct information',
        (WidgetTester tester) async {
      final testUser = UserEntity(
        id: 1,
        username: 'testuser',
        avatarUrl: 'https://example.com/avatar.jpg',
        profileUrl: 'https://github.com/testuser',
        followers: 100,
        following: 50,
        publicRepos: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(
              user: testUser,
              isFavorite: false,
              onTap: () {},
              onFavoriteTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('ID: 1'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should show filled heart when isFavorite is true',
        (WidgetTester tester) async {
      final testUser = UserEntity(
        id: 1,
        username: 'testuser',
        avatarUrl: 'https://example.com/avatar.jpg',
        profileUrl: 'https://github.com/testuser',
        followers: 100,
        following: 50,
        publicRepos: 10,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(
              user: testUser,
              isFavorite: true,
              onTap: () {},
              onFavoriteTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped',
        (WidgetTester tester) async {
      final testUser = UserEntity(
        id: 1,
        username: 'testuser',
        avatarUrl: 'https://example.com/avatar.jpg',
        profileUrl: 'https://github.com/testuser',
        followers: 100,
        following: 50,
        publicRepos: 10,
      );
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(
              user: testUser,
              isFavorite: false,
              onTap: () {
                tapped = true;
              },
              onFavoriteTap: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tapped, true);
    });

    testWidgets('should call onFavoriteTap when heart icon is tapped',
        (WidgetTester tester) async {
      final testUser = UserEntity(
        id: 1,
        username: 'testuser',
        avatarUrl: 'https://example.com/avatar.jpg',
        profileUrl: 'https://github.com/testuser',
        followers: 100,
        following: 50,
        publicRepos: 10,
      );
      bool favoriteTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(
              user: testUser,
              isFavorite: false,
              onTap: () {},
              onFavoriteTap: () {
                favoriteTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(favoriteTapped, true);
    });
  });
}


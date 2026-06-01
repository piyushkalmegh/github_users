import 'package:flutter_test/flutter_test.dart';
import 'package:github_users/features/users/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    const testUserJson = {
      'id': 1,
      'login': 'testuser',
      'avatar_url': 'https://example.com/avatar.jpg',
      'html_url': 'https://github.com/testuser',
      'bio': 'Test bio',
      'location': 'Test location',
      'company': 'Test company',
      'blog': 'https://blog.com',
      'email': 'test@example.com',
      'followers': 100,
      'following': 50,
      'public_repos': 10,
      'created_at': '2020-01-01T00:00:00Z',
      'updated_at': '2021-01-01T00:00:00Z',
    };

    test('should create UserModel from JSON', () {
      final model = UserModel.fromJson(testUserJson);

      expect(model.id, 1);
      expect(model.username, 'testuser');
      expect(model.avatarUrl, 'https://example.com/avatar.jpg');
      expect(model.bio, 'Test bio');
      expect(model.followers, 100);
    });

    test('should convert UserModel to JSON', () {
      final model = UserModel.fromJson(testUserJson);
      final json = model.toJson();

      expect(json['id'], 1);
      expect(json['login'], 'testuser');
      expect(json['bio'], 'Test bio');
    });

    test('should convert UserModel to UserEntity', () {
      final model = UserModel.fromJson(testUserJson);
      final entity = model.toEntity();

      expect(entity.id, 1);
      expect(entity.username, 'testuser');
      expect(entity.bio, 'Test bio');
      expect(entity.followers, 100);
      expect(entity.following, 50);
      expect(entity.publicRepos, 10);
    });
  });
}


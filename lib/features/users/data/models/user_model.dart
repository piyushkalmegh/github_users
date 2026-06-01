import 'package:github_users/features/users/domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User model from API
@JsonSerializable()
class UserModel {
  final int id;
  @JsonKey(name: 'login')
  final String username;
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;
  @JsonKey(name: 'html_url')
  final String profileUrl;
  final String? bio;
  final String? location;
  final String? company;
  final String? blog;
  final String? email;
  final int? followers;
  final int? following;
  @JsonKey(name: 'public_repos')
  final int? publicRepos;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.profileUrl,
    this.bio,
    this.location,
    this.company,
    this.blog,
    this.email,
    this.followers,
    this.following,
    this.publicRepos,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convert to UserEntity (domain layer)
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      avatarUrl: avatarUrl,
      profileUrl: profileUrl,
      bio: bio,
      location: location,
      company: company,
      blog: blog,
      email: email,
      followers: followers ?? 0,
      following: following ?? 0,
      publicRepos: publicRepos ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}



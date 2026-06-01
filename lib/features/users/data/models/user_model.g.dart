// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: (json['id'] as num).toInt(),
      username: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
      profileUrl: json['html_url'] as String,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      company: json['company'] as String?,
      blog: json['blog'] as String?,
      email: json['email'] as String?,
      followers: (json['followers'] as num?)?.toInt(),
      following: (json['following'] as num?)?.toInt(),
      publicRepos: (json['public_repos'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'login': instance.username,
      'avatar_url': instance.avatarUrl,
      'html_url': instance.profileUrl,
      'bio': instance.bio,
      'location': instance.location,
      'company': instance.company,
      'blog': instance.blog,
      'email': instance.email,
      'followers': instance.followers,
      'following': instance.following,
      'public_repos': instance.publicRepos,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

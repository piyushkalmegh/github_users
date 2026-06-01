/// User entity - core domain model
class UserEntity {
  final int id;
  final String username;
  final String avatarUrl;
  final String profileUrl;
  final String? bio;
  final String? location;
  final String? company;
  final String? blog;
  final String? email;
  final int followers;
  final int following;
  final int publicRepos;
  final String? createdAt;
  final String? updatedAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.profileUrl,
    this.bio,
    this.location,
    this.company,
    this.blog,
    this.email,
    required this.followers,
    required this.following,
    required this.publicRepos,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity && other.id == id && other.username == username;
  }

  @override
  int get hashCode => id.hashCode ^ username.hashCode;
}


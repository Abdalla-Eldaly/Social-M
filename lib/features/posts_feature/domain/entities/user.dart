class User {
  final int? id;
  final String? username;
  final String? bio;
  final String? profileImageUrl;
  final String? email;
  final int? followersCount;
  final int? followingCount;
  final bool? isFollowedByUser;

  User({
    this.id,
    this.username,
    this.bio,
    this.profileImageUrl,
    this.email,
    this.followersCount,
    this.followingCount,
    this.isFollowedByUser,
  });
}
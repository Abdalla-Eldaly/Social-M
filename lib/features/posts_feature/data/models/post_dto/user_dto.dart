import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/user.dart'; // Assuming you have a User entity

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  final int? id;
  final String? username;
  final String? bio;
  final String? profileImageUrl;
  final String? email;
  final int? followersCount;
  final int? followingCount;
  final bool? isFollowedByUser;

  UserDto({
    this.id,
    this.username,
    this.bio,
    this.profileImageUrl,
    this.email,
    this.followersCount,
    this.followingCount,
    this.isFollowedByUser,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  User toDomain() {
    return User(
      id: id,
      username: username,
      bio: bio,
      profileImageUrl: profileImageUrl,
      email: email,
      followersCount: followersCount,
      followingCount: followingCount,
      isFollowedByUser: isFollowedByUser,
    );
  }
}
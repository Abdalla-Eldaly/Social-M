import 'package:json_annotation/json_annotation.dart';
import 'package:social_m_app/features/posts_feature/data/models/post_dto/user_dto.dart';

import '../../../domain/entities/post_entity.dart';
import 'comment_dto.dart';
import 'location_dto.dart';
part 'post_dto.g.dart';

@JsonSerializable()
class PostDto {
  final int? id;
  final String? imageUrl;
  final String? caption;
  final String? createdAt;
  final int? userId;
  final UserDto? user;
  final int? likesCount;
  final bool? isLikedByUser;
  final LocationDto? location;
  final List<CommentDto>? comments;

  PostDto({
    this.id,
    this.imageUrl,
    this.caption,
    this.createdAt,
    this.userId,
    this.user,
    this.likesCount,
    this.isLikedByUser,
    this.location,
    this.comments,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) => _$PostDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostDtoToJson(this);


  Post toDomain() {
    return Post(
      id: id,
      imageUrl: imageUrl,
      caption: caption,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      userId: userId,
      user: user?.toDomain(),
      likesCount: likesCount,
      isLikedByUser: isLikedByUser,
      location: location?.toDomain(),
      comments: comments?.map((comment) => comment.toDomain()).toList(),
    );
  }
}
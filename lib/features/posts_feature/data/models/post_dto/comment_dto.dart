import 'package:json_annotation/json_annotation.dart';
import 'package:social_m_app/features/posts_feature/data/models/post_dto/user_dto.dart';
import '../../../domain/entities/comment.dart';
part 'comment_dto.g.dart';

@JsonSerializable()
class CommentDto {
  final int? id;
  final String? content;
  final String? createdAt;
  final int? userId;
  final UserDto? user;

  CommentDto({
    this.id,
    this.content,
    this.createdAt,
    this.userId,
    this.user,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) => _$CommentDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CommentDtoToJson(this);

  Comment toDomain() {
    return Comment(
      id: id,
      content: content,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      userId: userId,
      user: user?.toDomain(),
    );
  }
}
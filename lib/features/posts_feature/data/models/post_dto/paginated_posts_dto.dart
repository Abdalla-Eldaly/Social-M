// lib/features/posts/data/models/paginated_posts_dto.dart
import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/paginated_posts.dart';
import 'post_dto.dart';

part 'paginated_posts_dto.g.dart';

@JsonSerializable()
class PaginatedPostsDto {
  final List<PostDto>? items;
  final int? currentPage;
  final int? pageSize;
  final int? totalCount;

  PaginatedPostsDto({
    this.items,
    this.currentPage,
    this.pageSize,
    this.totalCount,
  });

  factory PaginatedPostsDto.fromJson(Map<String, dynamic> json) => _$PaginatedPostsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedPostsDtoToJson(this);

  PaginatedPosts toDomain() {
    return PaginatedPosts(
      items: items?.map((post) => post.toDomain()).toList() ?? [], // Default to empty list
      currentPage: currentPage ?? 0,
      pageSize: pageSize ?? 0,
      totalCount: totalCount ?? 0,
    );
  }
}
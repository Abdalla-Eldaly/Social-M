
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';

class PaginatedPosts {
  final List<Post>? items;
  final int? currentPage;
  final int? pageSize;
  final int? totalCount;

  PaginatedPosts({
    this.items,
    this.currentPage,
    this.pageSize,
    this.totalCount,
  });
}
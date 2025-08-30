import 'package:dartz/dartz.dart';

import '../../../../core/utils/network/failure.dart';
import '../../../../core/utils/network/network_exception.dart';
import '../entities/comment.dart';
import '../entities/paginated_posts.dart';
import '../entities/post_entity.dart';
import '../entities/user.dart';

abstract class PostRepository {
  Future<Either<NetworkException, PaginatedPosts>> getPosts(int pageNumber, int pageSize);
  Future<Either<NetworkException, List<Post >>> getUserPosts(int userId);
  Future<Either<NetworkException, Comment>> addComment(String comment, int postId);
  Future<Either<NetworkException, User>> getUserInfo();
}
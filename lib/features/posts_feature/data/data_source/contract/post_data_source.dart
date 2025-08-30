 import 'package:dartz/dartz.dart';
import 'package:social_m_app/core/utils/network/network_exception.dart';

import '../../../../../core/utils/network/failure.dart';
import '../../../domain/entities/paginated_posts.dart';
import '../../models/post_dto/comment_dto.dart';
import '../../models/post_dto/post_dto.dart';
import '../../models/post_dto/user_dto.dart';


abstract class PostDataSource {
  Future<Either<NetworkException, PaginatedPosts>> getPosts(int pageNumber, int pageSize);
  Future<Either<NetworkException, List<PostDto>>> getUserPosts(int userId);
  Future<Either<NetworkException, CommentDto>> addComment(String comment, int postId);
  Future<Either<NetworkException, UserDto>> getUserInfo();

}
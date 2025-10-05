import 'package:dartz/dartz.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/hastag.dart';

import '../../../../core/utils/network/failure.dart';
import '../../../../core/utils/network/network_exception.dart';
import '../../data/models/post_dto/create_post_dto.dart';
import '../entities/comment.dart';
import '../entities/paginated_posts.dart';
import '../entities/post_entity.dart';
import '../entities/user.dart';

abstract class PostRepository {
  Future<Either<NetworkException, PaginatedPosts>> getPosts(int pageNumber, int pageSize);
  Future<Either<NetworkException, List<Post >>> getUserPosts(int userId);
  Future<Either<NetworkException, Comment>> addComment(String comment, int postId);
  Future<Either<NetworkException, User>> getUserInfo();
  Future<Either<NetworkException, Post>> getSinglePost(int postId);
  Future<Either<NetworkException, List<User>>> getUserFollowers(int userId);
  Future<Either<NetworkException, List<User>>> getUserFollowing(int userId);
  Future<Either<NetworkException, Post>> createPost(CreatePostDto createPostDto);
  Future<Either<NetworkException, List<User>>> getUserSearch(String user);
  Future<Either<NetworkException, List<Post>>> getPostSearch(String post);
  Future<Either<NetworkException, List<Hashtag>>> getHashTagSearch(String hashtag);
}
 import 'package:dartz/dartz.dart';
import 'package:social_m_app/core/utils/network/network_exception.dart';
import 'package:social_m_app/features/posts_feature/data/models/post_dto/hashtag_dto.dart';

import '../../../../../core/utils/network/failure.dart';
import '../../../domain/entities/paginated_posts.dart';
import '../../models/post_dto/comment_dto.dart';
import '../../models/post_dto/create_post_dto.dart';
import '../../models/post_dto/post_dto.dart';
import '../../models/post_dto/user_dto.dart';


abstract class PostDataSource {
  Future<Either<NetworkException, PaginatedPosts>> getPosts(int pageNumber, int pageSize);
  Future<Either<NetworkException, List<PostDto>>> getUserPosts(int userId);
  Future<Either<NetworkException, PostDto>> getSinglePost(int postId);
  Future<Either<NetworkException, PostDto>> createPost(CreatePostDto createPostDto);
  Future<Either<NetworkException, CommentDto>> addComment(String comment, int postId);
  Future<Either<NetworkException, UserDto>> getUserInfo();
  Future<Either<NetworkException, List<UserDto>>> getUserFollowing(int userId);
  Future<Either<NetworkException, List<UserDto>>> getUserFollowers(int userId);
  Future<Either<NetworkException, List<UserDto>>> getUserSearch(String user);
  Future<Either<NetworkException, List<PostDto>>> getPostSearch(String post);
  Future<Either<NetworkException, List<HashtagDto>>> getHashTagSearch(String hashtag);

}
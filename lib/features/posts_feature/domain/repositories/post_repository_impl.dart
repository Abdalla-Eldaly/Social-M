import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_m_app/features/posts_feature/data/models/post_dto/hashtag_dto.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/hastag.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/user.dart';
import '../../../../core/utils/network/failure.dart';
import '../../../../core/utils/network/network_exception.dart';
import '../../data/data_source/contract/post_data_source.dart';
import '../../data/models/post_dto/create_post_dto.dart';
import '../entities/comment.dart';
import '../entities/paginated_posts.dart';
import '../entities/post_entity.dart';
import 'post_repository.dart';

@Injectable(as: PostRepository)
class PostRepositoryImpl implements PostRepository {
  final PostDataSource dataSource;

  PostRepositoryImpl(this.dataSource);

  @override
  Future<Either<NetworkException, PaginatedPosts>> getPosts(int pageNumber, int pageSize) async {
    return await dataSource.getPosts(pageNumber, pageSize);
  }
  @override
  Future<Either<NetworkException, List<Post>>> getUserPosts(int userId) async {
    final result = await dataSource.getUserPosts(userId);
    return result.map((postDtos) => postDtos.map((dto) => dto.toDomain()).toList());
  }

  @override
  Future<Either<NetworkException, Comment>> addComment(String comment, int postId) async {
    final result = await dataSource.addComment(comment, postId);
    return result.map((commentDto) => commentDto.toDomain());
  }
  @override
  Future<Either<NetworkException, User>> getUserInfo() async {
    final result = await dataSource.getUserInfo( );
    return result.map((userDto) => userDto.toDomain());

  }
  @override
  Future<Either<NetworkException, Post>> getSinglePost(int postId) async {
    final result = await dataSource.getSinglePost(postId );
    return result.map((post) => post.toDomain());

  }
  @override
  Future<Either<NetworkException, Post>> createPost(CreatePostDto createPostDto) async {
    final result = await dataSource.createPost(createPostDto);
    return result.map((postDto) => postDto.toDomain());
  }
  @override
  Future<Either<NetworkException, List<User>>> getUserFollowers(int userId) async {
    final result = await dataSource.getUserFollowers(userId);
    return result.map((userDto) => userDto.map((dto) => dto.toDomain()).toList());
  }

  @override
  Future<Either<NetworkException, List<User>>> getUserFollowing(int userId) async {
    final result = await dataSource.getUserFollowing(userId);
    return result.map((userDto) => userDto.map((dto) => dto.toDomain()).toList());
  }
  @override
  Future<Either<NetworkException, List<User>>> getUserSearch(String user) async {
    final result = await dataSource.getUserSearch(user);
    return result.map((userDto) => userDto.map((dto) => dto.toDomain()).toList());
  }

  @override
  Future<Either<NetworkException, List<Post>>> getPostSearch(String post) async {
    final result = await dataSource.getPostSearch(post);
    return result.map((postDto) => postDto.map((dto) => dto.toDomain()).toList());
  }

  @override
  Future<Either<NetworkException, List<Hashtag>>> getHashTagSearch(String hashtag) async {
    final result = await dataSource.getHashTagSearch(hashtag);
    return result.map((hashtagDto) => hashtagDto.map((dto) => dto.toDomain()).toList());
  }
}
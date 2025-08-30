import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/user.dart';
import '../../../../core/utils/network/failure.dart';
import '../../../../core/utils/network/network_exception.dart';
import '../../data/data_source/contract/post_data_source.dart';
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
}
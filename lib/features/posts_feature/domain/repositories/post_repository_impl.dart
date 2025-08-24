 import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/network/failure.dart';
import '../../../../core/utils/network/network_exception.dart';
import '../../data/data_source/contract/post_data_source.dart';
import '../entities/paginated_posts.dart';
import 'post_repository.dart';

@Injectable(as: PostRepository)
class PostRepositoryImpl implements PostRepository {
  final PostDataSource dataSource;

  PostRepositoryImpl(this.dataSource);

  @override
  Future<Either<NetworkException, PaginatedPosts>> getPosts(int pageNumber, int pageSize) async {
    return await dataSource.getPosts(pageNumber, pageSize);
  }
}
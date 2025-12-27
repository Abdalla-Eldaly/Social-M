import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_m_app/core/utils/network/network_exception.dart';
import '../../../../core/utils/network/failure.dart';
import '../entities/paginated_posts.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

@injectable
class GetUserPostsUseCase {
  final PostRepository postRepository;

  GetUserPostsUseCase(this.postRepository);

  Future<Either<NetworkException, List<Post>>> execute(int id) async {
    final result = await postRepository.getUserPosts(id);
    return result.fold(
          (networkException) => Left(NetworkException(
        message: networkException.message,
      )),
          (posts) => Right(posts),
    );
  }
}
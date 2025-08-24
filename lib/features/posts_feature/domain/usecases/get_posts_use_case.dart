import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_m_app/core/utils/network/network_exception.dart';
import '../../../../core/utils/network/failure.dart';
import '../entities/paginated_posts.dart';
import '../repositories/post_repository.dart';

@injectable
class GetPostsUseCase {
  final PostRepository postRepository;

  GetPostsUseCase(this.postRepository);

  Future<Either<NetworkException, PaginatedPosts>> execute(
      GetPostsInput input) async {
    final result =
        await postRepository.getPosts(input.pageNumber, input.pageSize);
    return result.fold(
      (networkException) => Left(NetworkException(
        message: networkException.message,
      )),
      (paginatedPosts) => Right(paginatedPosts),
    );
  }
}

class GetPostsInput {
  final int pageNumber;
  final int pageSize;

  GetPostsInput({
    required this.pageNumber,
    required this.pageSize,
  });
}

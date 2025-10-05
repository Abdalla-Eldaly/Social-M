
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/post_entity.dart';

import '../../../../core/utils/network/network_exception.dart';
import '../repositories/post_repository.dart';

@injectable
class GetSinglePostUseCase {
  final PostRepository postRepository;

  GetSinglePostUseCase(this.postRepository);

  Future<Either<NetworkException, Post>> execute(int postId
       ) async {
    final result =
    await postRepository.getSinglePost(postId );
    return result.fold(
          (networkException) => Left(NetworkException(
        message: networkException.message,
      )),
          (post) => Right(post),
    );
  }
}
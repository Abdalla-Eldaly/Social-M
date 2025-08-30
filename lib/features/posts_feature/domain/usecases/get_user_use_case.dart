
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/user.dart';

import '../../../../core/utils/network/network_exception.dart';
import '../repositories/post_repository.dart';

@injectable
class GetUserInfoUseCase {
  final PostRepository postRepository;

  GetUserInfoUseCase(this.postRepository);

  Future<Either<NetworkException, User>> execute(
       ) async {
    final result =
    await postRepository.getUserInfo( );
    return result.fold(
          (networkException) => Left(NetworkException(
        message: networkException.message,
      )),
          (user) => Right(user),
    );
  }
}
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/hastag.dart';
import '../../../../../core/utils/network/failure.dart';
import '../../../../core/utils/network/network_exception.dart';
import '../../domain/entities/user.dart';
import '../repositories/post_repository.dart';

@injectable
class SearchHashTagsUseCase {
  final PostRepository repository;

  SearchHashTagsUseCase(this.repository);

  Future<Either<NetworkException, List<Hashtag>>> call(String hashtag) async {
    final result = await repository.getHashTagSearch(hashtag);
    return result.fold(
          (exception) => Left(NetworkException(
            message: exception.message,
          )),
          (hashtags) => Right(hashtags),
    );
  }
}
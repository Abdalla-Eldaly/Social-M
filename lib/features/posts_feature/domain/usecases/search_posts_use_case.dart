import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/utils/network/failure.dart';
import '../../../../../core/utils/network/network_exception.dart';
import '../../domain/entities/post_entity.dart';
import '../repositories/post_repository.dart';

@injectable
class SearchPostsUseCase {
  final PostRepository repository;

  SearchPostsUseCase(this.repository);

  Future<Either<NetworkException, List<Post>>> call(String query) async {
    final result = await repository.getPostSearch(query);
    return result.fold(
          (exception) => Left(NetworkException(
            message: exception.message,
          )),
          (posts) => Right(posts),
    );
  }
}
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/utils/network/failure.dart';
import '../../../../../core/utils/network/network_exception.dart';
import '../../domain/entities/user.dart';
 import '../repositories/post_repository.dart';

@injectable
class SearchUsersUseCase {
  final PostRepository repository;

  SearchUsersUseCase(this.repository);

  Future<Either<NetworkException, List<User>>> call(String query) async {
    final result = await repository.getUserSearch(query);
    return result.fold(
          (exception) => Left(NetworkException(
            message: exception.message,
          )),
          (users) => Right(users),
    );
  }
}
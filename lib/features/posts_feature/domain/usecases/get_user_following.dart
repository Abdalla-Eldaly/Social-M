import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/network/network_exception.dart';
import '../entities/user.dart';
import '../repositories/post_repository.dart';

@injectable
class GetUserFollowing {
  final PostRepository _postRepository;

  GetUserFollowing(this._postRepository);

  Future<Either<NetworkException, List<User>>> call(int userId) async {
    return await _postRepository.getUserFollowing(userId);
  }
}
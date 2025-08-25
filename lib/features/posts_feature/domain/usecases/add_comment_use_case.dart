import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/network/network_exception.dart';
import '../entities/comment.dart';
import '../repositories/post_repository.dart';

@injectable
class AddCommentUseCase {
  final PostRepository repository;

  AddCommentUseCase(this.repository);

  Future<Either<NetworkException, Comment>> execute(String comment, int postId) async {
    return await repository.addComment(comment, postId);
  }
}
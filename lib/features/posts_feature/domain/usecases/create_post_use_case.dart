import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/network/network_exception.dart';
 import '../../data/models/post_dto/create_post_dto.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

@injectable
class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  Future<Either<NetworkException, Post>> call(CreatePostDto params) async {
    return await repository.createPost(params);
  }
}
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/utils/network/failure.dart';
import '../auth_repository/auth_repository.dart';
import '../entites/response/auth_result.dart';

@injectable
class RegisterUseCase extends BaseUseCase<
    ({String name, String username, String email, String password, String bio, File profileImage}),
    AuthOutcome> {
  final  Repository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, AuthOutcome>> execute(
      ({
      String name,
      String username,
      String email,
      String password,
      String bio,
      File profileImage
      }) input,
      ) async {
    return await repository.register(
      name: input.name,
      username: input.username,
      email: input.email,
      password: input.password,
      bio: input.bio,
      profileImage: input.profileImage,
    );
  }
}
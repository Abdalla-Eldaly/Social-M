import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import '../../domain/auth_repository/auth_repository.dart';
import '../../domain/entites/response/auth_result.dart';
import '../auth_data_source/contract/auth_online_date_source.dart';
import '../../../../core/utils/network/failure.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, AuthOutcome>> login(String email, String password) async {
    final result = await dataSource.login(email, password);
    return result.fold(
          (errorDto) => Left(AuthFailure(errorDto.toDomain())),
          (responseDto) => Right(responseDto.toDomain()),
    );
  }

  @override
  Future<Either<Failure, AuthOutcome>> refreshToken(String refreshToken) async {
    final result = await dataSource.refreshToken(refreshToken);
    return result.fold(
          (errorDto) => Left(AuthFailure(errorDto.toDomain())),
          (responseDto) => Right(responseDto.toDomain()),
    );
  }

  @override
  Future<Either<Failure, AuthOutcome>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String bio,
    required File profileImage,
  }) async {
    final result = await dataSource.register(
      name: name,
      username: username,
      email: email,
      password: password,
      bio: bio,
      profileImage: profileImage,
    );
    return result.fold(
          (errorDto) => Left(AuthFailure(errorDto.toDomain())),
          (responseDto) => Right(responseDto.toDomain()),
    );
  }
}
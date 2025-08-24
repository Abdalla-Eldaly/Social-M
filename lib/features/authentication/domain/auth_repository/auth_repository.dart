import 'package:dartz/dartz.dart';
import 'dart:io';

import '../../../../core/utils/network/failure.dart';
import '../entites/response/auth_result.dart';

abstract class  Repository {
  Future<Either<Failure, AuthOutcome>> login(String email, String password);
  Future<Either<Failure, AuthOutcome>> refreshToken(String refreshToken);
  Future<Either<Failure, AuthOutcome>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String bio,
    required File profileImage,
  });
}
import 'package:dartz/dartz.dart';
import '../../models/response/auth_response_dto.dart';
import 'dart:io';

abstract class DataSource {
  Future<Either<AuthErrorDto, AuthResponseDto>> login(String email, String password);
  Future<Either<AuthErrorDto, AuthResponseDto>> refreshToken(String refreshToken);
  Future<Either<AuthErrorDto, AuthResponseDto>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String bio,
    required File profileImage,
  });
}
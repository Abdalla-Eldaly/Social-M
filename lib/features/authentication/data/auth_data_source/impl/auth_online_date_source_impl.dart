import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/utils/network/api_client.dart';
import '../../../../../core/utils/network/connectivity_service.dart';
import '../../models/response/auth_response_dto.dart';
import '../contract/auth_online_date_source.dart';

@Injectable(as: AuthDataSource)
class AuthDataSourceImpl implements AuthDataSource {
  final ApiClient apiClient;
  final ConnectivityService connectivityService;

  AuthDataSourceImpl(this.apiClient, this.connectivityService);

  Future<Either<AuthErrorDto, T>> _executeApiCall<T>({
    required String endpoint,
    required dynamic data,
    int successStatusCode = 200,
    required T Function(dynamic) successMapper,
  }) async {
    if (!(await connectivityService.hasConnection())) {
      return const Left(AuthErrorDto(
        message: 'No internet connection. Please check your network.',
        status: 0,
      ));
    }

    try {
      final response = await apiClient.post(endpoint, data: data);

      if (response.statusCode == successStatusCode) {
        return Right(successMapper(response.data));
      } else {
        return Left(AuthErrorDto.fromJson(response.data is String
            ? {'title': response.data, 'status': response.statusCode}
            : response.data));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        if (e.message?.contains('Failed host lookup') ?? false) {
          return const Left(AuthErrorDto(
            message: 'No internet connection. Please check your network.',
            status: 0,
          ));
        }
        return const Left(AuthErrorDto(
          message: 'No internet connection. Please check your network.',
          status: 0,
        ));
      }
      return Left(AuthErrorDto(
        message: 'Network error: ${e.message ?? 'Unknown error'}',
        status: e.response?.statusCode ?? 0,
      ));
    } catch (e) {
      return Left(AuthErrorDto(
        message: 'Unexpected error: $e',
        status: 0,
      ));
    }
  }

  @override
  Future<Either<AuthErrorDto, AuthResponseDto>> login(String email, String password) async {
    return _executeApiCall(
      endpoint: ApiConstants.login,
      data: {'userName': email, 'password': password},
      successMapper: (data) => AuthResponseDto.fromJson(data),
    );
  }

  @override
  Future<Either<AuthErrorDto, AuthResponseDto>> refreshToken(String refreshToken) async {
    return _executeApiCall(
      endpoint: ApiConstants.refresh,
      data: {'refreshToken': refreshToken},
      successMapper: (data) => AuthResponseDto.fromJson(data),
    );
  }

  @override
  Future<Either<AuthErrorDto, AuthResponseDto>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String bio,
    required File profileImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'bio': bio,
        'profileImage': await MultipartFile.fromFile(
          profileImage.path,
          contentType: MediaType('image', profileImage.path.split('.').last),
        ),
      });

      return _executeApiCall(
        endpoint: ApiConstants.register,
        data: formData,
        successStatusCode: 201,
        successMapper: (data) => AuthResponseDto.fromJson(data),
      );
    } catch (e) {
      return Left(AuthErrorDto(
        message: 'Unexpected error during registration: $e',
        status: 0,
      ));
    }
  }
}
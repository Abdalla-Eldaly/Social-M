import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../constants/app_constants.dart';
import '../storage/secure_storage.dart';

@injectable
class ApiClient {
  final Dio dio;
  final SecureStorage secureStorage;

  ApiClient(this.dio, this.secureStorage) {
    dio.options
      ..baseUrl = ApiConstants.baseUrl
      ..connectTimeout = const Duration(seconds: 5)
      ..receiveTimeout = const Duration(seconds: 5);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final tokens = await secureStorage.getTokens();
        if (tokens != null) {
          options.headers['Authorization'] = 'Bearer ${tokens['access_token']}';
        }
        return handler.next(options);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(contentType: 'application/json'),
    );
  }

  Future<Response> post(String path, {dynamic data}) {
    final isMultipart = data is FormData;
    return dio.post(
      path,
      data: data,
      options: Options(
        contentType: isMultipart ? 'multipart/form-data' : 'application/json',
      ),
    );
  }
}

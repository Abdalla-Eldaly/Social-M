import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_constants.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio() {
    Dio dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      followRedirects: false,
      headers: {'accept': '*/*'},
      connectTimeout: const Duration(seconds: 60),
      contentType: 'application/json',
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      validateStatus: (status) => status != null && status < 500, // Allow 401 responses
    ));

    // Logger interceptor
    dio.interceptors.add(
      PrettyDioLogger(
        enabled: true,
        error: true,
        request: true,
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: true,
      ),
    );

    // Interceptor to attach the access token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final token = 'prefs.getString(ApiConstants.tokenKey)'; // Fixed typo
          if (token != null && token.isNotEmpty) {
            debugPrint('AccessToken: $token');
            options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
          } else {
            debugPrint('No token found in SharedPreferences');
          }
          return handler.next(options);
        },
      ),
    );

    return dio;
  }
}
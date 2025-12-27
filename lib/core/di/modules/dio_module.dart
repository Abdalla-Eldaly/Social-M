import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../constants/app_constants.dart';
import '../../utils/storage/secure_storage.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio(SecureStorage secureStorage) {
    Dio dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      followRedirects: false,
      headers: {'accept': '*/*'},
      connectTimeout: const Duration(seconds: 60),
      contentType: 'application/json',
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      validateStatus: (status) => status != null && status < 500,
    ));

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

    // Auth interceptor for handling access tokens
    dio.interceptors.add(AuthInterceptor(secureStorage));

    return dio;
  }
}

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Check if token is valid before attaching
      final isValid = await _secureStorage.isTokenValid();

      if (isValid) {
        final accessToken = await _secureStorage.getAccessToken();

        if (accessToken != null && accessToken.isNotEmpty) {
          debugPrint('Attaching access token to request');
          options.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
        } else {
          debugPrint('Access token is null or empty');
        }
      } else {
        debugPrint('Token is invalid or expired - request will proceed without token');
        // Optionally, you could try to refresh the token here
        // await _refreshTokenIfNeeded();
      }
    } catch (e) {
      debugPrint('Error getting access token: $e');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized responses
    if (err.response?.statusCode == 401) {
      debugPrint('Received 401 - Token might be invalid');

      try {
        // Try to refresh the token
        final refreshSuccess = await _refreshToken();

        if (refreshSuccess) {
          // Retry the original request with new token
          final response = await _retry(err.requestOptions);
          handler.resolve(response);
          return;
        } else {
          // Refresh failed, clear tokens and let the error pass through
          await _secureStorage.deleteAll();
          debugPrint('Token refresh failed - tokens cleared');
        }
      } catch (e) {
        debugPrint('Error during token refresh: $e');
        await _secureStorage.deleteAll();
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('No refresh token available');
        return false;
      }

      // Create a new Dio instance for refresh request to avoid interceptor loop
      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        contentType: 'application/json',
      ));

      final response = await refreshDio.post(
        '/auth/refresh', // Replace with your actual refresh endpoint
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Parse the new tokens - adjust according to your API response structure
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'] ?? refreshToken; // Some APIs don't return new refresh token
        final expiresIn = data['expires_in']; // seconds

        final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

        // Save new tokens
        await _secureStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          expiresAt: expiresAt,
        );

        debugPrint('Token refreshed successfully');
        return true;
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }

    return false;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    // Get the new access token
    final newAccessToken = await _secureStorage.getAccessToken();

    if (newAccessToken != null) {
      requestOptions.headers[HttpHeaders.authorizationHeader] = 'Bearer $newAccessToken';
    }

    // Create a new Dio instance to avoid interceptor loop
    final retryDio = Dio();
    return retryDio.fetch(requestOptions);
  }
}
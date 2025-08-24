import 'dart:io';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

class NetworkException extends Equatable implements Exception {
  final String message;
  final int? statusCode;
  final String? instructions;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.instructions,
  });

  NetworkException.fromDioError(DioException dioException)
      : statusCode = dioException.response?.statusCode,
        instructions = null,
        message = (() {
          switch (dioException.type) {
            case DioExceptionType.cancel:
              return 'Request was cancelled. Please try again.';
            case DioExceptionType.connectionTimeout:
              return 'Connection timeout. Please check your internet connection and try again.';
            case DioExceptionType.receiveTimeout:
              return 'Receive timeout in connection with the server.';
            case DioExceptionType.sendTimeout:
              return 'Send timeout in connection with the server.';
            case DioExceptionType.connectionError:
              if (dioException.error is SocketException) {
                return 'No Internet connection. Please check your connection and try again.';
              } else {
                return 'An unexpected connection error occurred.';
              }
            case DioExceptionType.badCertificate:
              return 'Bad certificate detected. Connection is not secure.';
            case DioExceptionType.badResponse:
              final data = dioException.response?.data;
              print('Backend Response: $data');
              if (data is Map<String, dynamic>) {
                // Prioritize 'message' over 'error'
                final errorMessage = (data['message'] == 'Failed to register user')
                    ? data['error'] as String? ?? 'Error occurred'
                    : data['message'] as String? ??
                    data['error'] as String? ??
                    data['statusMessage'] as String?;
                print('Extracted error message: $errorMessage');
                if (errorMessage != null && errorMessage.isNotEmpty) {
                  return errorMessage;
                }
              }

              if (dioException.response?.statusCode == 400) {
                return 'Bad Request: Please check your input and try again.';
              }
              if (dioException.response?.statusCode == 500) {
                return 'Internal Server Error. Please try again later.';
              }
              return 'An unexpected error occurred. Please try again.';
            case DioExceptionType.unknown:
              return 'An unexpected error occurred. Please try again.';
          }
        })() {
    print(
        'NetworkException created: statusCode=$statusCode, message=$message, instructions=$instructions');
  }

  @override
  List<Object?> get props => [message, statusCode, instructions];

  @override
  String toString() => message;
}

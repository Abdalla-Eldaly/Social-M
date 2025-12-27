import 'dart:io';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

class NetworkException extends Equatable implements Exception {
  final String message;
  final int? statusCode;
  final String? instructions;
  final Map<String, List<String>>? validationErrors;
  final String? traceId;
  final String? type;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.instructions,
    this.validationErrors,
    this.traceId,
    this.type,
  });

  NetworkException.fromDioError(DioException dioException)
      : statusCode = dioException.response?.statusCode,
        instructions = _generateInstructions(dioException),
        validationErrors = _extractValidationErrors(dioException.response?.data),
        traceId = _extractTraceId(dioException.response?.data),
        type = _extractType(dioException.response?.data),
        message = _extractMessage(dioException);

  // Factory constructor for creating from API response
  factory NetworkException.fromApiResponse({
    required dynamic responseData,
    required int statusCode,
  }) {
    final validationErrors = _extractValidationErrors(responseData);
    final traceId = _extractTraceId(responseData);
    final type = _extractType(responseData);
    final instructions = _generateInstructionsFromStatusCode(statusCode);

    String message = _extractResponseMessage(responseData) ??
        _getDefaultMessageForStatusCode(statusCode);

    // If we have validation errors but a generic message, create a better one
    if (validationErrors != null &&
        validationErrors.isNotEmpty &&
        message == 'One or more validation errors occurred.') {
      final errorMessages = <String>[];
      validationErrors.forEach((field, errors) {
        errorMessages.addAll(errors.map((error) => '$field: $error'));
      });
      message = 'Validation failed:\n${errorMessages.join('\n')}';
    }

    return NetworkException(
      message: message,
      statusCode: statusCode,
      instructions: instructions,
      validationErrors: validationErrors,
      traceId: traceId,
      type: type,
    );
  }

  static String _extractMessage(DioException dioException) {
    // First try to extract custom error message from response
    final responseMessage = _extractResponseMessage(dioException.response?.data);
    if (responseMessage != null) {
      return responseMessage;
    }

    // Fallback to default DioException handling
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
        return _handleBadResponse(dioException);
      case DioExceptionType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  static String? _extractResponseMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Handle validation errors format - improved for your API structure
      if (responseData.containsKey('errors') && responseData['errors'] is Map) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        final errorMessages = <String>[];

        errors.forEach((field, fieldErrors) {
          if (fieldErrors is List) {
            for (final error in fieldErrors) {
              errorMessages.add('$field: $error');
            }
          } else if (fieldErrors is String) {
            errorMessages.add('$field: $fieldErrors');
          }
        });

        if (errorMessages.isNotEmpty) {
          return 'Validation errors:\n${errorMessages.join('\n')}';
        }
      }

      // Handle other message formats with priority
      if (responseData.containsKey('title') && responseData['title'] is String) {
        final title = responseData['title'] as String;
        if (title.isNotEmpty && title != 'One or more validation errors occurred.') {
          return title;
        }
      }

      if (responseData.containsKey('message') && responseData['message'] is String) {
        final message = responseData['message'] as String;
        if (message.isNotEmpty) {
          return message;
        }
      }

      if (responseData.containsKey('error') && responseData['error'] is String) {
        final error = responseData['error'] as String;
        if (error.isNotEmpty) {
          return error;
        }
      }

      // Handle detail field if present
      if (responseData.containsKey('detail') && responseData['detail'] is String) {
        final detail = responseData['detail'] as String;
        if (detail.isNotEmpty) {
          return detail;
        }
      }
    } else if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }

    return null;
  }

  static String _handleBadResponse(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    final data = dioException.response?.data;

    // Try to extract meaningful message from response data
    final responseMessage = _extractResponseMessage(data);
    if (responseMessage != null) {
      return responseMessage;
    }

    // Fallback to status code based messages
    return _getDefaultMessageForStatusCode(statusCode);
  }

  static String _getDefaultMessageForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad Request: Please check your input and try again.';
      case 401:
        return 'Unauthorized: Please login again.';
      case 403:
        return 'Forbidden: You don\'t have permission to perform this action.';
      case 404:
        return 'Not Found: The requested resource was not found.';
      case 422:
        return 'Validation Error: Please check your input and try again.';
      case 429:
        return 'Too Many Requests: Please wait a moment and try again.';
      case 500:
        return 'Internal Server Error: Please try again later.';
      case 502:
        return 'Bad Gateway: Server is temporarily unavailable.';
      case 503:
        return 'Service Unavailable: Server is temporarily down.';
      case 504:
        return 'Gateway Timeout: Server took too long to respond.';
      default:
        return statusCode != null
            ? 'HTTP $statusCode: An unexpected error occurred.'
            : 'An unexpected error occurred. Please try again.';
    }
  }

  static Map<String, List<String>>? _extractValidationErrors(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('errors') &&
        responseData['errors'] is Map) {

      final errors = responseData['errors'] as Map<String, dynamic>;
      final validationErrors = <String, List<String>>{};

      errors.forEach((field, fieldErrors) {
        if (fieldErrors is List) {
          validationErrors[field] = fieldErrors.map((e) => e.toString()).toList();
        } else if (fieldErrors is String) {
          validationErrors[field] = [fieldErrors];
        }
      });

      return validationErrors.isNotEmpty ? validationErrors : null;
    }

    return null;
  }

  static String? _extractTraceId(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('traceId') &&
        responseData['traceId'] is String) {
      return responseData['traceId'] as String;
    }
    return null;
  }

  static String? _extractType(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('type') &&
        responseData['type'] is String) {
      return responseData['type'] as String;
    }
    return null;
  }

  static String? _generateInstructions(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    return _generateInstructionsFromStatusCode(statusCode);
  }

  static String? _generateInstructionsFromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Please verify your input data and try again.';
      case 401:
        return 'Please log in again to continue.';
      case 403:
        return 'Contact support if you believe you should have access.';
      case 404:
        return 'Please check the URL or contact support if the issue persists.';
      case 422:
        return 'Please correct the highlighted errors and try again.';
      case 429:
        return 'Please wait a few minutes before trying again.';
      case 500:
        return 'Please try again later or contact support if the issue persists.';
      case 502:
      case 503:
      case 504:
        return 'Please wait a moment and try again.';
      default:
        return 'Please try again or contact support if the issue persists.';
    }
  }

  // Convenience getters
  bool get isValidationError => validationErrors != null && validationErrors!.isNotEmpty;
  bool get isNetworkError => statusCode == null || statusCode! >= 500;
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isTooManyRequests => statusCode == 429;

  // Get formatted validation errors for UI display
  String? get formattedValidationErrors {
    if (!isValidationError) return null;

    final messages = <String>[];
    validationErrors!.forEach((field, errors) {
      for (final error in errors) {
        messages.add('• $field: $error');
      }
    });

    return messages.join('\n');
  }

  // Get user-friendly error message
  String get userFriendlyMessage {
    if (isValidationError) {
      return formattedValidationErrors ?? message;
    }
    return message;
  }

  // Get validation errors for a specific field
  List<String>? getFieldErrors(String fieldName) {
    return validationErrors?[fieldName];
  }

  // Check if a specific field has errors
  bool hasFieldError(String fieldName) {
    return validationErrors?.containsKey(fieldName) ?? false;
  }

  // Get all field names with errors
  List<String> get errorFields {
    return validationErrors?.keys.toList() ?? [];
  }

  @override
  List<Object?> get props => [
    message,
    statusCode,
    instructions,
    validationErrors,
    traceId,
    type,
  ];

  @override
  String toString() => userFriendlyMessage;

  // Copy with method for creating modified instances
  NetworkException copyWith({
    String? message,
    int? statusCode,
    String? instructions,
    Map<String, List<String>>? validationErrors,
    String? traceId,
    String? type,
  }) {
    return NetworkException(
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      instructions: instructions ?? this.instructions,
      validationErrors: validationErrors ?? this.validationErrors,
      traceId: traceId ?? this.traceId,
      type: type ?? this.type,
    );
  }

  // Convert to Map for logging or debugging
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'statusCode': statusCode,
      'instructions': instructions,
      'validationErrors': validationErrors,
      'traceId': traceId,
      'type': type,
    };
  }

  // Convert to JSON string for logging
  String toJsonString() {
    return toMap().toString();
  }
}
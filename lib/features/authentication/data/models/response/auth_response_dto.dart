import 'package:equatable/equatable.dart';
import '../../../domain/entites/response/auth_result.dart';

// Success response DTO
class AuthResponseDto extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiration;
  final DateTime refreshTokenExpiration;

  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiration,
    required this.refreshTokenExpiration,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiration: DateTime.parse(json['accessTokenExpiration'] as String),
      refreshTokenExpiration: DateTime.parse(json['refreshTokenExpiration'] as String),
    );
  }

  AuthOutcome toDomain() {
    return AuthSuccess(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: accessTokenExpiration,
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, accessTokenExpiration, refreshTokenExpiration];
}

// Error response DTO
class AuthErrorDto extends Equatable {
  final String message;
  final int status;

  const AuthErrorDto({
    required this.message,
    required this.status,
  });

  factory AuthErrorDto.fromJson(Map<String, dynamic> json) {
    // Handle simple error message like "Invalid username or password"
    return AuthErrorDto(
      message: json['title'] ?? json.toString(),
      status: json['status'] ?? 400,
    );
  }

  AuthError toDomain() {
    return AuthError(
      message: message,
      status: status,
    );
  }

  @override
  List<Object?> get props => [message, status];
}
import 'package:equatable/equatable.dart';

// Base class for authentication outcomes
sealed class AuthOutcome extends Equatable {}

// Successful authentication
class AuthSuccess extends AuthOutcome {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

   AuthSuccess({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}

// Authentication error
class AuthError extends AuthOutcome {
  final String message;
  final int status;

   AuthError({
    required this.message,
    required this.status,
  });

  @override
  List<Object?> get props => [message, status];
}
import 'package:equatable/equatable.dart';
import '../../../features/authentication/domain/entites/response/auth_result.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends Failure {
  final AuthError authError;

  AuthFailure(this.authError) : super(authError.message);

  @override
  List<Object?> get props => [authError];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NoInternetFailure extends Failure {
  const NoInternetFailure() : super('No internet connection. Please check your network.');
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
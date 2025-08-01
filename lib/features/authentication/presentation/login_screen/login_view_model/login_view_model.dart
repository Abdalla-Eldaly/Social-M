import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/base/base_state.dart';
import '../../../../../core/utils/extensions/extensions.dart';
import '../../../../../core/utils/storage/secure_storage.dart';
import '../../../../../core/utils/network/failure.dart';
import '../../../domain/entites/response/auth_result.dart';
import '../../../domain/usecases/login_usecases.dart';
import '../../../domain/usecases/refresh_usecase.dart';

@injectable
class LoginViewModel extends Cubit<BaseState> {
  final LoginUseCase loginUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final SecureStorage secureStorage;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<String?> _emailError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _passwordError = ValueNotifier<String?>(null);

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  GlobalKey<FormState> get formKey => _formKey;
  ValueNotifier<String?> get emailError => _emailError;
  ValueNotifier<String?> get passwordError => _passwordError;

  LoginViewModel(
      this.loginUseCase,
      this.refreshTokenUseCase,
      this.secureStorage,
      ) : super(InitialState());

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      _emailError.value = 'Please enter your email';
      return _emailError.value;
    }
    if (!value.isValidEmail()) {
      _emailError.value = 'Please enter a valid email';
      return _emailError.value;
    }
    _emailError.value = null;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      _passwordError.value = 'Please enter your password';
      return _passwordError.value;
    }
    if (value.length < 6) {
      _passwordError.value = 'Password must be at least 6 characters';
      return _passwordError.value;
    }
    _passwordError.value = null;
    return null;
  }

  Future<void> login(String email, String password) async {

    emit(LoadingState());
    final result = await loginUseCase.execute((email, password));
    result.fold(
          (failure) {
        final errorMessage = failure is AuthFailure ? failure.authError.message : failure.message;
        if (errorMessage.toLowerCase().contains('username or password')) {
          _passwordError.value = errorMessage;
        } else if (errorMessage.toLowerCase().contains('email')) {
          _emailError.value = errorMessage;
        } else {
          _emailError.value = errorMessage;
        }
        emit(ErrorState(errorMessage));
      },
          (authResult) async {
        if (authResult is AuthSuccess) {
          try {
            await secureStorage.saveTokens(
              accessToken: authResult.accessToken,
              refreshToken: authResult.refreshToken,
              expiresAt: authResult.expiresAt,
            );
            _emailError.value = null;
            _passwordError.value = null;
            emit(SuccessState(authResult));
          } catch (e) {
            _emailError.value = 'Failed to save tokens';
            emit(ErrorState('Failed to save tokens'));
          }
        } else if (authResult is AuthError) {
          _passwordError.value = authResult.message;
          emit(ErrorState(authResult.message));
        }
      },
    );
  }

  Future<void> refreshToken() async {
    try {
      final tokens = await secureStorage.getTokens();
      if (tokens == null || tokens['refresh_token'] == null) {
        emit(const ErrorState('No refresh token available'));
        return;
      }

      emit(LoadingState());
      final result = await refreshTokenUseCase.execute(tokens['refresh_token']!);
      result.fold(
            (failure) => emit(ErrorState(failure.message)),
            (authResult) async {
          if (authResult is AuthSuccess) {
            await secureStorage.saveTokens(
              accessToken: authResult.accessToken,
              refreshToken: authResult.refreshToken,
              expiresAt: authResult.expiresAt,
            );
            emit(SuccessState(authResult));
          } else if (authResult is AuthError) {
            emit(ErrorState(authResult.message));
          }
        },
      );
    } catch (e) {
      emit(ErrorState('Failed to retrieve tokens: $e'));
    }
  }

  void clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _emailError.value = null;
    _passwordError.value = null;
    emit(InitialState());
  }

  @override
  Future<void> close() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailError.dispose();
    _passwordError.dispose();
    return super.close();
  }
}
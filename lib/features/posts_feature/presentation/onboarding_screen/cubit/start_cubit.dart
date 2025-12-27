import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:social_m_app/features/posts_feature/presentation/onboarding_screen/cubit/start_states.dart';
import '../../../../../core/utils/storage/secure_storage.dart';
import '../../../../authentication/domain/entites/response/auth_result.dart';
import '../../../../authentication/domain/usecases/refresh_usecase.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  final RefreshTokenUseCase _refreshTokenUseCase;
  final SecureStorage _secureStorage;

  OnboardingCubit(this._refreshTokenUseCase, this._secureStorage)
      : super(OnboardingState.initial());

  Future<void> initializeOnboarding() async {
    emit(OnboardingState.loading());

    try {
      // Check if user has tokens stored
      final tokens = await _secureStorage.getTokens();

      if (tokens == null) {
        debugPrint("No tokens found - proceeding as guest");
        emit(OnboardingState.guest());
        return;
      }

      // Check if current token is still valid
      final isValid = await _secureStorage.isTokenValid();

      if (isValid) {
        debugPrint("Token is valid - user authenticated");
        emit(OnboardingState.authenticated());
      } else {
        debugPrint("Token expired - attempting refresh");
        final refreshSuccess = await _refreshToken();

        if (refreshSuccess) {
          debugPrint("Token refresh successful - user authenticated");
          emit(OnboardingState.authenticated());
        } else {
          debugPrint("Token refresh failed - proceeding as guest");
          emit(OnboardingState.guest());
        }
      }
    } catch (e) {
      debugPrint("Error during onboarding initialization: $e");
      emit(OnboardingState.error("Failed to initialize authentication: ${e.toString()}"));
    }
  }

  Future<bool> _refreshToken() async {
    try {
      // Get stored tokens
      final tokens = await _secureStorage.getTokens();

      if (tokens == null || tokens['refresh_token'] == null) {
        debugPrint("No refresh token available");
        return false;
      }

      debugPrint("Attempting token refresh...");

      // Call refresh use case
      final refreshResult = await _refreshTokenUseCase.execute(
        tokens['refresh_token'] as String,
      );

      return refreshResult.fold(
            (failure) {
          debugPrint("Refresh token failed: ${failure.message}");
          return false;
        },
            (authOutcome) async {
          // Check if the result is AuthSuccess and save new tokens
          if (authOutcome is AuthSuccess) {
            debugPrint("Token refresh successful, saving new tokens");

            await _secureStorage.saveTokens(
              accessToken: authOutcome.accessToken,
              refreshToken: authOutcome.refreshToken,
              expiresAt: authOutcome.expiresAt,
            );

            debugPrint("New tokens saved successfully");
            return true;
          } else {
            debugPrint("Unexpected auth result type: ${authOutcome.runtimeType}");
            return false;
          }
        },
      );
    } catch (e) {
      debugPrint("Refresh token error: $e");
      return false;
    }
  }

  // Method to retry initialization (useful for error state)
  Future<void> retryInitialization() async {
    await initializeOnboarding();
  }

  // Method to force logout and clear tokens
  Future<void> forceLogout() async {
    try {
      await _secureStorage.deleteAll();
      emit(OnboardingState.guest());
    } catch (e) {
      emit(OnboardingState.error("Failed to logout: ${e.toString()}"));
    }
  }
}

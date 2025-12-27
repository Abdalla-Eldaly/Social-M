import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../features/authentication/domain/usecases/refresh_usecase.dart';
import '../../features/posts_feature/domain/entities/user.dart';
import '../../features/posts_feature/domain/usecases/get_user_use_case.dart';
import '../utils/storage/secure_storage.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  guest,
  unauthenticated,
  error,
}

@singleton
class UserProvider extends ChangeNotifier {
  final RefreshTokenUseCase _refreshTokenUseCase;
  final GetUserInfoUseCase _getUserInfoUseCase;
  final SecureStorage _secureStorage;

  UserProvider(
      this._refreshTokenUseCase,
      this._getUserInfoUseCase,
      this._secureStorage,
      );

  AuthStatus _authStatus = AuthStatus.initial;
  User? _currentUser;
  String? _errorMessage;
  bool _isGuest = false;

  // Getters
  AuthStatus get authStatus => _authStatus;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authStatus == AuthStatus.authenticated;
  bool get isGuest => _authStatus == AuthStatus.guest;
  bool get isLoggedIn => _authStatus == AuthStatus.authenticated || _authStatus == AuthStatus.guest;

  /// Initialize the app by checking authentication status
  Future<void> initializeAuth() async {
    _setLoading();
    try {
      // Check if user has tokens
      final tokens = await _secureStorage.getTokens();
      if (tokens == null) {
        // No tokens found - user is guest
        _setGuestMode();
        return;
      }

      // Check if token is valid
      final isValid = await _secureStorage.isTokenValid();
      if (isValid) {
        // Token is valid, fetch user info
        await _fetchUserInfo();
      } else {
        // Token expired, try to refresh
        final refreshSuccess = await _refreshToken();
        if (refreshSuccess) {
          await _fetchUserInfo();
        } else {
          _setGuestMode();
        }
      }
    } catch (e) {
      _setError("Failed to initialize authentication: ${e.toString()}");
    }
  }

  /// Refresh the authentication token
  Future<bool> _refreshToken() async {
    try {
      final tokens = await _secureStorage.getTokens();
      if (tokens == null || tokens['refresh_token'] == null) {
        return false;
      }

      final refreshResult = await _refreshTokenUseCase.execute(
        tokens['refresh_token'] as String,
      );

      return refreshResult.fold(
            (failure) {
          debugPrint("Refresh token failed: ${failure.message}");
          return false;
        },
            (authOutcome) async {
          // Save new tokens
          // Uncomment and modify according to your AuthOutcome structure
          // await _secureStorage.saveTokens(
          //   accessToken: authOutcome.accessToken,
          //   refreshToken: authOutcome.refreshToken,
          //   expiresAt: authOutcome.expiresAt,
          // );
          return true;
        },
      );
    } catch (e) {
      debugPrint("Refresh token error: $e");
      return false;
    }
  }

  /// Fetch user information
  Future<void> _fetchUserInfo() async {
    final result = await _getUserInfoUseCase.execute();
    result.fold(
          (failure) {
        debugPrint("Failed to fetch user info: ${failure.message}");
        _setGuestMode();
      },
          (user) {
        _currentUser = user;
        _authStatus = AuthStatus.authenticated;
        _errorMessage = null;
        _isGuest = false;
        notifyListeners();
      },
    );
  }

  /// Ensure token is valid before API calls
  Future<bool> ensureValidToken() async {
    if (_authStatus == AuthStatus.guest) {
      return true; // Guest mode is valid
    }

    try {
      final isValid = await _secureStorage.isTokenValid();
      if (isValid) {
        return true;
      }

      // Try to refresh token
      final refreshSuccess = await _refreshToken();
      if (refreshSuccess) {
        return true;
      } else {
        // Failed to refresh, set as guest
        _setGuestMode();
        return true; // Return true to allow guest access
      }
    } catch (e) {
      debugPrint("Token validation error: $e");
      _setGuestMode();
      return true; // Allow guest access even on error
    }
  }

  /// Login with tokens (called after successful login)
  Future<void> loginWithTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    _setLoading();
    try {
      // Save tokens
      await _secureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
      );
      // Fetch user info
      await _fetchUserInfo();
    } catch (e) {
      _setError("Login failed: ${e.toString()}");
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _secureStorage.deleteAll();
      _currentUser = null;
      _authStatus = AuthStatus.unauthenticated;
      _errorMessage = null;
      _isGuest = false;
      notifyListeners();
    } catch (e) {
      _setError("Logout failed: ${e.toString()}");
    }
  }

  /// Switch to guest mode
  void _setGuestMode() {
    _currentUser = null;
    _authStatus = AuthStatus.guest;
    _errorMessage = null;
    _isGuest = true;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading() {
    _authStatus = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set error state
  void _setError(String message) {
    _authStatus = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// Retry authentication
  Future<void> retryAuth() async {
    await initializeAuth();
  }

  /// Force refresh user data
  Future<void> refreshUserData() async {
    if (_authStatus == AuthStatus.authenticated) {
      _setLoading();
      await _fetchUserInfo();
    }
  }
}
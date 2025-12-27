// lib/core/handlers/unauthorized_handler.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../theme/app_color.dart';

class UnauthorizedHandler {
  static void handleUnauthorizedError(
      BuildContext context, {
        required String action,
        VoidCallback? onLoginSuccess,
        bool showSnackBar = true,
      }) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // If user is already authenticated, this might be a token expiry issue
    if (userProvider.isAuthenticated) {
      _handleTokenExpiry(context, action: action, onRetry: onLoginSuccess);
      return;
    }

    // Show login prompt dialog
    _showLoginDialog(context, action: action, onLoginSuccess: onLoginSuccess);

    // Optionally show a snackbar as well
    if (showSnackBar) {
      _showUnauthorizedSnackBar(context, action);
    }
  }

  static void _handleTokenExpiry(
      BuildContext context, {
        required String action,
        VoidCallback? onRetry,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Session Expired',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Your session has expired. Please log in again to $action.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Set user as guest mode
                Provider.of<UserProvider>(context, listen: false).logout();
              },
              child: const Text(
                'Later',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                // Navigate to login and handle success
                await _navigateToLogin(context, onLoginSuccess: onRetry);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void _showLoginDialog(
      BuildContext context, {
        required String action,
        VoidCallback? onLoginSuccess,
      }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.login,
                color: AppColors.primary,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Login Required',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'You need to be logged in to $action. Would you like to log in now?',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _navigateToLogin(context, onLoginSuccess: onLoginSuccess);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void _showUnauthorizedSnackBar(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.lock_outline,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Login required to $action'),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Login',
          textColor: AppColors.white,
          onPressed: () {
            _navigateToLogin(context);
          },
        ),
      ),
    );
  }

  static Future<void> _navigateToLogin(
      BuildContext context, {
        VoidCallback? onLoginSuccess,
      }) async {
    // Replace this with your actual navigation logic
    // Example with auto_route:
    // final result = await context.router.pushNamed('/login');

    // For demonstration, showing a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigation Placeholder'),
        content: const Text('Replace this with actual navigation to login screen'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Simulate successful login for demo
              if (onLoginSuccess != null) {
                onLoginSuccess();
              }
            },
            child: const Text('Simulate Login Success'),
          ),
        ],
      ),
    );
  }

  // Helper method for checking authorization before actions
  static Future<bool> checkAuthorizationForAction(
      BuildContext context, {
        required String action,
        VoidCallback? onLoginSuccess,
        bool requiresAuth = true,
      }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!requiresAuth) return true;

    // Check if user is logged in
    if (!userProvider.isLoggedIn) {
      handleUnauthorizedError(
        context,
        action: action,
        onLoginSuccess: onLoginSuccess,
      );
      return false;
    }

    // Ensure token is valid for authenticated users
    if (userProvider.isAuthenticated) {
      final isValidToken = await userProvider.ensureValidToken();
      if (!isValidToken) {
        handleUnauthorizedError(
          context,
          action: action,
          onLoginSuccess: onLoginSuccess,
        );
        return false;
      }
    }

    return true;
  }
}

// lib/core/mixins/unauthorized_mixin.dart
mixin UnauthorizedMixin<T extends StatefulWidget> on State<T> {

  Future<bool> checkAuth({
    required String action,
    VoidCallback? onLoginSuccess,
    bool requiresAuth = true,
  }) async {
    return await UnauthorizedHandler.checkAuthorizationForAction(
      context,
      action: action,
      onLoginSuccess: onLoginSuccess,
      requiresAuth: requiresAuth,
    );
  }

  void handleUnauthorized({
    required String action,
    VoidCallback? onLoginSuccess,
    bool showSnackBar = true,
  }) {
    UnauthorizedHandler.handleUnauthorizedError(
      context,
      action: action,
      onLoginSuccess: onLoginSuccess,
      showSnackBar: showSnackBar,
    );
  }
}

// lib/core/widgets/auth_required_wrapper.dart
class AuthRequiredWrapper extends StatelessWidget {
  final Widget child;
  final String action;
  final VoidCallback? onTap;
  final VoidCallback? onLoginSuccess;
  final bool requiresAuth;

  const AuthRequiredWrapper({
    super.key,
    required this.child,
    required this.action,
    this.onTap,
    this.onLoginSuccess,
    this.requiresAuth = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final isAuthorized = await UnauthorizedHandler.checkAuthorizationForAction(
          context,
          action: action,
          onLoginSuccess: onLoginSuccess,
          requiresAuth: requiresAuth,
        );

        if (isAuthorized && onTap != null) {
          onTap!();
        }
      },
      child: child,
    );
  }
}
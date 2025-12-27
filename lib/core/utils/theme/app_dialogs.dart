import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'app_dialogs_utils.dart';
import 'app_images.dart';

enum ToastType { error, success, info, warning }

enum ToastPosition { top, center, bottom }

class AppDialogs {
  static OverlayEntry? _overlayEntry;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Configuration for toast appearance
  static const Duration _defaultDuration = Duration(seconds: 3);
  static const Duration _animationDuration = Duration(milliseconds: 400);
  static const double _topOffset = 60.0; // Below status bar
  static const double _bottomOffset = 30.0;
  static const double _horizontalMargin = 16.0;

  static void showFailDialog({
    required String message,
    required BuildContext context,
    String? posActionTitle,
    VoidCallback? posAction,
    String? negativeActionTitle,
    VoidCallback? negativeAction,
  }) {
    AppDialogUtils.showDialogOnScreen(
      context: context,
      message: message,
      imagePath: LottiePath.error,
      posAction: posAction,
      negativeAction: negativeAction,
      negativeActionTitle: negativeActionTitle,
      posActionTitle: posActionTitle,
    );
  }

  static void showInfoDialog({
    required String message,
    required BuildContext context,
    String? posActionTitle,
    VoidCallback? posAction,
    String? negativeActionTitle,
    VoidCallback? negativeAction,
  }) {
    AppDialogUtils.showDialogOnScreen(
      context: context,
      message: message,
      imagePath: LottiePath.error,
      posAction: posAction,
      negativeAction: negativeAction,
      negativeActionTitle: negativeActionTitle,
      posActionTitle: posActionTitle,
    );
  }

  // Enhanced toast methods with improved positioning
  static void showErrorToast(
      String message, {
        Duration? duration,
        ToastPosition position = ToastPosition.top,
        bool hapticFeedback = true,
      }) {
    if (hapticFeedback) HapticFeedback.lightImpact();

    _showToast(
      message: message,
      type: ToastType.error,
      duration: duration ?? _defaultDuration,
      position: position,
    );
  }

  static void showSuccessToast(
      String message, {
        Duration? duration,
        ToastPosition position = ToastPosition.top,
        bool hapticFeedback = true,
      }) {
    if (hapticFeedback) HapticFeedback.lightImpact();

    _showToast(
      message: message,
      type: ToastType.success,
      duration: duration ?? _defaultDuration,
      position: position,
    );
  }

  static void showInfoToast(
      String message, {
        Duration? duration,
        ToastPosition position = ToastPosition.top,
        bool hapticFeedback = false,
      }) {
    if (hapticFeedback) HapticFeedback.lightImpact();

    _showToast(
      message: message,
      type: ToastType.info,
      duration: duration ?? _defaultDuration,
      position: position,
    );
  }

  static void showWarningToast(
      String message, {
        Duration? duration,
        ToastPosition position = ToastPosition.top,
        bool hapticFeedback = true,
      }) {
    if (hapticFeedback) HapticFeedback.lightImpact();

    _showToast(
      message: message,
      type: ToastType.warning,
      duration: duration ?? _defaultDuration,
      position: position,
    );
  }

  static void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static void _showToast({
    required String message,
    required ToastType type,
    required Duration duration,
    required ToastPosition position,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Remove any existing overlay
    _removeOverlay();

    final overlayState = navigatorKey.currentState!.overlay!;
    final overlayAnimationController = AnimationController(
      vsync: Navigator.of(context),
      duration: _animationDuration,
    );

    // Create slide and fade animations
    final slideAnimation = Tween<Offset>(
      begin: _getInitialOffset(position),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: overlayAnimationController,
      curve: Curves.elasticOut,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: overlayAnimationController,
      curve: Curves.easeOut,
    ));

    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: overlayAnimationController,
      curve: Curves.elasticOut,
    ));

    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        position: position,
        slideAnimation: slideAnimation,
        fadeAnimation: fadeAnimation,
        scaleAnimation: scaleAnimation,
        onDismiss: _removeOverlay,
      ),
    );

    overlayState.insert(_overlayEntry!);
    overlayAnimationController.forward();

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (_overlayEntry != null) {
        overlayAnimationController.reverse().then((_) {
          _removeOverlay();
          overlayAnimationController.dispose();
        });
      }
    });
  }

  static Offset _getInitialOffset(ToastPosition position) {
    switch (position) {
      case ToastPosition.top:
        return const Offset(0, -1);
      case ToastPosition.center:
        return const Offset(-1, 0);
      case ToastPosition.bottom:
        return const Offset(0, 1);
    }
  }

  // Utility method to get toast configuration
  static _ToastConfig _getToastConfig(ToastType type) {
    switch (type) {
      case ToastType.error:
        return _ToastConfig(
          backgroundColor: const Color(0xffFBEAEA),
          borderColor: const Color(0xffF87171),
          iconPath: SvgPath.errorIcon,
          iconColor: const Color(0xffDC2626),
          textColor: const Color(0xff991B1B),
        );
      case ToastType.success:
        return _ToastConfig(
          backgroundColor: const Color(0xffEBF8F2),
          borderColor: const Color(0xff34D399),
          iconPath: SvgPath.successIcon,
          iconColor: const Color(0xff059669),
          textColor: const Color(0xff065F46),
        );
      case ToastType.info:
        return _ToastConfig(
          backgroundColor: const Color(0xffFEF6E9),
          borderColor: const Color(0xffFBBF24),
          iconPath: SvgPath.infoIcon,
          iconColor: const Color(0xffD97706),
          textColor: const Color(0xff92400E),
        );
      case ToastType.warning:
        return _ToastConfig(
          backgroundColor: const Color(0xffFEF3E2),
          borderColor: const Color(0xffF59E0B),
          iconPath: SvgPath.infoIcon, // You might want to add a warning icon
          iconColor: const Color(0xffD97706),
          textColor: const Color(0xff92400E),
        );
    }
  }
}

// Configuration class for toast appearance
class _ToastConfig {
  final Color backgroundColor;
  final Color borderColor;
  final String iconPath;
  final Color iconColor;
  final Color textColor;

  const _ToastConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconPath,
    required this.iconColor,
    required this.textColor,
  });
}

// Separate widget for toast content
class _ToastWidget extends StatelessWidget {
  final String message;
  final ToastType type;
  final ToastPosition position;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.position,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final config = AppDialogs._getToastConfig(type);
    final mediaQuery = MediaQuery.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([slideAnimation, fadeAnimation, scaleAnimation]),
      builder: (context, child) {
        return Positioned(
          top: position == ToastPosition.top
              ? AppDialogs._topOffset + mediaQuery.padding.top
              : null,
          bottom: position == ToastPosition.bottom
              ? AppDialogs._bottomOffset + mediaQuery.padding.bottom
              : null,
          left: AppDialogs._horizontalMargin,
          right: AppDialogs._horizontalMargin,
          child: SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: GestureDetector(
                  onTap: onDismiss,
                  onPanUpdate: (details) {
                    // Swipe to dismiss
                    if (details.delta.dy.abs() > 10) {
                      onDismiss();
                    }
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: config.backgroundColor,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: config.borderColor.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20.0,
                            offset: const Offset(0, 8),
                            spreadRadius: -4,
                          ),
                          BoxShadow(
                            color: config.borderColor.withOpacity(0.1),
                            blurRadius: 40.0,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: config.iconColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SvgPicture.asset(
                              config.iconPath,
                              height: 20,
                              width: 20,
                              colorFilter: ColorFilter.mode(
                                config.iconColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              message,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: config.textColor,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          GestureDetector(
                            onTap: onDismiss,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: config.textColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: config.textColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Extension methods for easier usage
extension AppDialogsExtension on BuildContext {
  void showErrorToast(String message, {Duration? duration}) {
    AppDialogs.showErrorToast(message, duration: duration);
  }

  void showSuccessToast(String message, {Duration? duration}) {
    AppDialogs.showSuccessToast(message, duration: duration);
  }

  void showInfoToast(String message, {Duration? duration}) {
    AppDialogs.showInfoToast(message, duration: duration);
  }

  void showWarningToast(String message, {Duration? duration}) {
    AppDialogs.showWarningToast(message, duration: duration);
  }
}
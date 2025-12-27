import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

enum NavigationAnimationType {
  fade,
  slideRight,
  slideLeft,
  slideUp,
  slideDown,
  scale,
  rotate,
  size,
  slideRightWithFade,
  slideLeftWithFade,
  none,
}

class NavigationConfig {
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve fastCurve = Curves.easeOut;
  static const Curve slowCurve = Curves.easeInOutCubic;
}

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static BuildContext get context => navigatorKey.currentContext!;

  // Main navigation method with animation
  static Future<T?> navigateWithAnimation<T extends Object?>({
    required BuildContext context,
    required Widget destination,
    NavigationAnimationType animationType = NavigationAnimationType.fade,
    Duration? duration,
    Duration? reverseDuration,
    Curve? curve,
    Alignment? alignment,
    bool replace = false,
    bool fullScreenDialog = false,
  }) async {
    final pageTransitionType = _mapAnimationType(animationType);
    final animationDuration = duration ?? NavigationConfig.defaultDuration;
    final animationCurve = curve ?? NavigationConfig.defaultCurve;

    final route = PageTransition<T>(
      type: pageTransitionType,
      child: destination,
      duration: animationDuration,
      reverseDuration: reverseDuration ??
          Duration(
            milliseconds: (animationDuration.inMilliseconds * 0.8).round(),
          ),
      curve: animationCurve,
      alignment: alignment ?? Alignment.center,
      fullscreenDialog: fullScreenDialog,
    );

    if (replace) {
      return Navigator.pushReplacement(context, route);
    } else {
      return Navigator.push(context, route);
    }
  }

  // Navigate and clear stack
  static Future<T?> navigateAndClearStack<T extends Object?>({
    required BuildContext context,
    required Widget destination,
    NavigationAnimationType animationType = NavigationAnimationType.fade,
    Duration? duration,
  }) async {
    final pageTransitionType = _mapAnimationType(animationType);

    return Navigator.pushAndRemoveUntil(
      context,
      PageTransition<T>(
        type: pageTransitionType,
        child: destination,
        duration: duration ?? NavigationConfig.defaultDuration,
        curve: NavigationConfig.defaultCurve,
      ),
          (route) => false,
    );
  }

  // Show animated modal/dialog
  static Future<T?> showAnimatedModal<T extends Object?>({
    required BuildContext context,
    required Widget modal,
    NavigationAnimationType animationType = NavigationAnimationType.slideUp,
    Duration? duration,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    final pageTransitionType = _mapAnimationType(animationType);

    return Navigator.push<T>(
      context,
      PageTransition<T>(
        type: pageTransitionType,
        child: modal,
        duration: duration ?? const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        reverseType: PageTransitionType.rightToLeft,
        fullscreenDialog: true,
      ),
    );
  }

  // Pop with animation (automatic)
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  // Pop until specific route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  // Map enum to PageTransition type
  static PageTransitionType _mapAnimationType(NavigationAnimationType type) {
    switch (type) {
      case NavigationAnimationType.fade:
        return PageTransitionType.fade;
      case NavigationAnimationType.slideRight:
        return PageTransitionType.rightToLeft;
      case NavigationAnimationType.slideLeft:
        return PageTransitionType.leftToRight;
      case NavigationAnimationType.slideUp:
        return PageTransitionType.bottomToTop;
      case NavigationAnimationType.slideDown:
        return PageTransitionType.topToBottom;
      case NavigationAnimationType.scale:
        return PageTransitionType.scale;
      case NavigationAnimationType.rotate:
        return PageTransitionType.rotate;
      case NavigationAnimationType.size:
        return PageTransitionType.size;
      case NavigationAnimationType.slideRightWithFade:
        return PageTransitionType.rightToLeftWithFade;
      case NavigationAnimationType.slideLeftWithFade:
        return PageTransitionType.leftToRightWithFade;
      case NavigationAnimationType.none:
        return PageTransitionType.fade; // Fallback
    }
  }
}

// ----------------------------------------------------------
// Extension for BuildContext Navigation Helpers
// ----------------------------------------------------------
extension NavigationExtensions on BuildContext {
  Future<T?> navigateTo<T extends Object?>(
      Widget destination, {
        NavigationAnimationType animation = NavigationAnimationType.fade,
        Duration? duration,
      }) {
    return NavigationService.navigateWithAnimation<T>(
      context: this,
      destination: destination,
      animationType: animation,
      duration: duration,
    );
  }

  Future<T?> navigateToWithSlide<T extends Object?>(Widget destination) {
    return NavigationService.navigateWithAnimation<T>(
      context: this,
      destination: destination,
      animationType: NavigationAnimationType.slideRight,
    );
  }

  Future<T?> navigateToWithFade<T extends Object?>(Widget destination) {
    return NavigationService.navigateWithAnimation<T>(
      context: this,
      destination: destination,
      animationType: NavigationAnimationType.fade,
    );
  }

  Future<T?> navigateToWithScale<T extends Object?>(Widget destination) {
    return NavigationService.navigateWithAnimation<T>(
      context: this,
      destination: destination,
      animationType: NavigationAnimationType.scale,
      duration: NavigationConfig.slowDuration,
    );
  }

  // ✅ New method: Navigate replacement
  Future<T?> navigateReplacement<T extends Object?, TO extends Object?>(
      Widget destination, {
        NavigationAnimationType animation = NavigationAnimationType.fade,
        Duration? duration,
      }) {
    return NavigationService.navigateWithAnimation<T>(
      context: this,
      destination: destination,
      animationType: animation,
      duration: duration,
      replace: true,
    );
  }

  Future<T?> showModalWithAnimation<T extends Object?>(Widget modal) {
    return NavigationService.showAnimatedModal<T>(
      context: this,
      modal: modal,
    );
  }

  void goBack<T extends Object?>([T? result]) {
    NavigationService.pop(this, result);
  }
}

// ----------------------------------------------------------
// Mixin for Reusable Navigation Logic (for Cubits/ViewModels)
// ----------------------------------------------------------
mixin NavigationMixin {
  Future<void> navigateToScreen(
      BuildContext context,
      Widget screen, {
        NavigationAnimationType animation = NavigationAnimationType.slideRight,
      }) async {
    await NavigationService.navigateWithAnimation(
      context: context,
      destination: screen,
      animationType: animation,
    );
  }

  // ✅ New method: Navigate replacement
  Future<void> navigateToReplacement(
      BuildContext context,
      Widget screen, {
        NavigationAnimationType animation = NavigationAnimationType.fade,
      }) async {
    await NavigationService.navigateWithAnimation(
      context: context,
      destination: screen,
      animationType: animation,
      replace: true,
    );
  }

  Future<void> showBottomSheetModal(
      BuildContext context,
      Widget content,
      ) async {
    await NavigationService.showAnimatedModal(
      context: context,
      modal: _buildBottomSheetWrapper(context, content),
      animationType: NavigationAnimationType.slideUp,
    );
  }

  Future<void> showFullScreenModal(
      BuildContext context,
      Widget content,
      ) async {
    await NavigationService.showAnimatedModal(
      context: context,
      modal: content,
      animationType: NavigationAnimationType.scale,
    );
  }

  Widget _buildBottomSheetWrapper(BuildContext context, Widget content) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

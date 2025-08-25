import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'app_dialogs_utils.dart';
import 'app_images.dart';

class AppDialogs {
  static OverlayEntry? _overlayEntry;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<
      NavigatorState>();

  static void showFailDialog(
      {required String message,
        required BuildContext context,
        String? posActionTitle,
        VoidCallback? posAction,
        String? negativeActionTitle,
        VoidCallback? negativeAction}) {
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

  static void showInfoDialog(
      {required String message,
        required BuildContext context,
        String? posActionTitle,
        VoidCallback? posAction,
        String? negativeActionTitle,
        VoidCallback? negativeAction}) {
    AppDialogUtils.showDialogOnScreen(
        context: context,
        message: message,
        imagePath: LottiePath.error,
        posAction: posAction,
        negativeAction: negativeAction,
        negativeActionTitle: negativeActionTitle,
        posActionTitle: posActionTitle);
  }




  static void showErrorToast(String message) {
    _showToast(
      context: navigatorKey.currentContext!,
      message: message,
      bgColor: const Color(0xffFBEAEA),
      iconPath: SvgPath.errorIcon,
    );
  }

  static void showSuccessToast(String message) {
    _showToast(
      context: navigatorKey.currentContext!,
      message: message,
      bgColor: const Color(0xffEBF8F2),
      iconPath: SvgPath.successIcon,
    );
  }

  static void showInfoToast(String message) {
    _showToast(
      context: navigatorKey.currentContext!,
      message: message,
      bgColor: const Color(0xffFEF6E9),
      iconPath: SvgPath.infoIcon,
    );
  }


  static void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static void _showToast({
    required BuildContext context,
    required String message,
    required Color bgColor,
    required String iconPath,
  }) {
    _removeOverlay();

    final overlayState = navigatorKey.currentState!.overlay!;
    final overlayAnimationController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 300),
    );

    final animation = CurvedAnimation(
      parent: overlayAnimationController,
      curve: Curves.easeOut,
    );

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 30.0,
        left: 16.0,
        right: 16.0,
        child: FadeTransition(
          opacity: animation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  SvgPicture.asset(iconPath, height: 24),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.close, size: 18, color: Colors.grey[700]),
                  //   onPressed: _removeOverlay,
                  //   splashRadius: 16,
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
    overlayAnimationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      overlayAnimationController.reverse().then((_) => _removeOverlay());
    });
  }
}
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

import 'app_color.dart';


class AppDialogUtils {
  static Future<void> showLoadingDialog({
    required BuildContext context,
    required String message,
  }) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          contentPadding: const EdgeInsets.all(30),
          content: Row(
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
              ),
              const SizedBox(
                width: 20,
              ),
              FittedBox(
                child: Text(
                  message,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            ],
          ),
        ),
        barrierColor: Colors.black.withOpacity(0.7),
        barrierDismissible: false);
  }

  static showDialogOnScreen({
    required BuildContext context,
    required String message,
    required String imagePath,
    String? posActionTitle,
    VoidCallback? posAction,
    String? negativeActionTitle,
    VoidCallback? negativeAction,
  }) {
    List<Widget> actionList = [];

    // add the button to the action list if it doesn't equal null
    if (negativeActionTitle != null) {
      if (negativeAction != null) {
        actionList.add(NegativeActionButton(
          negativeActionTitle: negativeActionTitle,
          negativeAction: negativeAction,
        ));
      } else {
        actionList.add(
            NegativeActionButton(negativeActionTitle: negativeActionTitle));
      }
    }

    // add the button to the action list if it doesn't equal null
    if (posActionTitle != null) {
      if (actionList.isNotEmpty) {
        actionList.add(const SizedBox(
          width: 16,
        ));
      }
      if (posAction != null) {
        actionList.add(PosActionButton(
          posActionTitle: posActionTitle,
          posAction: posAction,
        ));
      } else {
        actionList.add(PosActionButton(posActionTitle: posActionTitle));
      }
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          contentPadding: EdgeInsets.zero,
          content: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(16),
                            topLeft: Radius.circular(16),
                          )),
                      child: Center(
                          child: Lottie.asset(imagePath,
                              width: 120, fit: BoxFit.cover)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: actionList,
                ),
              )
            ],
          ),
        ),
        barrierColor: Colors.black.withOpacity(0.7),
        barrierDismissible: false);
  }
}



class PosActionButton extends StatelessWidget {
  final VoidCallback? posAction;
  final String posActionTitle;

  const PosActionButton(
      {required this.posActionTitle, this.posAction, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ElevatedButton(
            onPressed: () {
              context.router.maybePop();
              if (posAction != null) {
                posAction!();
              }
            },
            style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: FittedBox(child: Text(posActionTitle)),
            )));
  }
}



class NegativeActionButton extends StatelessWidget {
  final VoidCallback? negativeAction;
  final String negativeActionTitle;

  const NegativeActionButton(
      {required this.negativeActionTitle, this.negativeAction, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          context.router.maybePop();
          if (negativeAction != null) {
            negativeAction!();
          }
        },
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor:
          WidgetStateProperty.all(Theme.of(context).primaryColor),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(12),
          )),
        ),
        child: FittedBox(
          child: Text(
            negativeActionTitle,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_color.dart';
import '../theme/app_images.dart';
import '../theme/app_text_style.dart';

class CustomElevatedButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final Color? textColor;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double? minimumSize;
  final bool isLoading;

  const CustomElevatedButton({
    super.key,
    this.text,
    this.child,
    this.textColor,
    this.onPressed,
    this.isPrimary = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.textStyle,
    this.padding,
    this.borderRadius,
    this.minimumSize,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? (backgroundColor ?? AppColors.primary)
            : (backgroundColor ?? AppColors.fieldFill),
        foregroundColor: isPrimary
            ? (foregroundColor ?? Colors.white)
            : (foregroundColor ?? AppColors.textPrimary),
        elevation: elevation ?? 0,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(20),
        ),
        minimumSize: Size(minimumSize ?? 120, 48),
      ),
      child: isLoading
          ?  SizedBox(
        width: 25,
        height: 25,
child: Padding(
  padding: const EdgeInsets.all(0),
  child: Lottie.asset(LottiePath.loading),
),
//         child: CircularProgressIndicator(
//           color: Colors.white,
//
// strokeWidth: 1.7,
//         ),
      )
          : child ??
          (text != null
              ? Text(
            text!,
            style: textStyle?.copyWith(color: textColor) ??
                AppTextStyle.labelLarge.copyWith(color: textColor ?? Colors.white),
          )
              : const SizedBox.shrink()),
    );
  }
}
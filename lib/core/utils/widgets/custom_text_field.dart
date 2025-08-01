import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final void Function()? onTap;
  final TextEditingController? controller;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final InputBorder? border;
  final Color? fillColor;
  final EdgeInsets? contentPadding;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final String? errorText; // New property for error text
  final FocusNode? focusNode;
  final TextAlign? textAlign;
  final int? maxLines;
  final int? maxLength;
  final bool? readOnly;

  const CustomTextField({
    super.key,
    this.hintText,
    this.onTap,
    this.controller,
    this.obscureText,
    this.keyboardType,
    this.style,
    this.hintStyle,
    this.border,
    this.fillColor,
    this.contentPadding,
    this.enabled,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.errorText,
    this.focusNode,
    this.textAlign,
    this.maxLines,
    this.maxLength,
    this.readOnly,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText ?? false;
  }

  void _toggleObscureText() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = AppTheme.lightTheme.textTheme;
    final effectiveMaxLines = widget.obscureText == true ? 1 : widget.maxLines;

    return TextFormField(
      onTap: widget.onTap,
      readOnly: widget.readOnly ?? false,
      controller: widget.controller,
      obscureText: _isObscured,
      keyboardType: widget.keyboardType,
      cursorColor: AppColors.textSecondary,
      textInputAction: widget.textInputAction,
      style: widget.style ??
          textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        hintStyle: widget.hintStyle ??
            textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
        fillColor: widget.fillColor ?? AppColors.fieldFill,
        border: widget.border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        suffixIcon: widget.obscureText == true
            ? IconButton(
          icon: Icon(
            _isObscured ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye,
            color: AppColors.textSecondary,
          ),
          onPressed: _toggleObscureText,
        )
            : null,
        errorText: widget.errorText, // Use errorText property
        errorStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.errorRed,
          fontSize: 12,
        ),
      ),
      enabled: widget.enabled ?? true,
      onChanged: widget.onChanged,
      validator: widget.validator,
      focusNode: widget.focusNode,
      textAlign: widget.textAlign ?? TextAlign.start,
      maxLines: effectiveMaxLines,
      maxLength: widget.maxLength,
    );
  }
}
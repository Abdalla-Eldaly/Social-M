import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color.dart';

class AppTextStyle {
  // Headline styles
  static TextStyle get headlineLarge => GoogleFonts.cairo(
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle get headlineMedium => GoogleFonts.cairo(
    fontSize: 28,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle get headlineSmall => GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle get buttonText => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
    height: 1.25,
  );

  // Title styles
  static TextStyle get titleLarge => GoogleFonts.cairo(
    fontSize: 22,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get titleMedium => GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get titleSmall => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Body styles
  static TextStyle get bodyLarge => GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Label styles (e.g., for buttons, captions)
  static TextStyle get labelLarge => GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get labelMedium => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get labelSmall => GoogleFonts.cairo(
    fontSize: 10,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Error text style (for validation errors)
  static TextStyle get error => GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w600, // Regular
    color: AppColors.errorRed, // Match previous error style; replace with AppColors.error if defined
    height: 1.5,
  );
}
import 'package:flutter/material.dart';

import 'app_color.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 14,color: AppColors.textPrimary, fontFamily: 'Plus Jakarta Sans',fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(fontSize: 14,color: AppColors.textSecondary, fontFamily: 'Plus Jakarta Sans',fontWeight: FontWeight.w500),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          minimumSize: const Size(120, 48),
        ),
      ),
      fontFamily: 'Plus Jakarta Sans',
    );
  }
}
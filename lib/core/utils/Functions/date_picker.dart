import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_color.dart';
import '../theme/app_text_style.dart';

class DatePickerUtils {
  static Future<void> selectDate({
    required BuildContext context,
    required Function(DateTime?) onDateSelected,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String dateFormat = 'dd/MM/yyyy',
    Locale locale = const Locale('ar', 'EG'),
    TextEditingController? controller,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      locale: locale,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accentBlue,
              onPrimary: AppColors.white,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
              secondary: AppColors.textSecondary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentBlue, // Button text color
              ),
            ),
            textTheme: Theme.of(context).textTheme.copyWith(
              bodyLarge: AppTextStyle.bodyLarge, // General text style
              titleMedium: AppTextStyle.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ), // Month/Year picker text
            ),
            dialogBackgroundColor: AppColors.background, // Dialog background
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate = DateFormat(dateFormat, locale.languageCode).format(picked);
      if (controller != null) {
        controller.text = formattedDate;
      }
      onDateSelected(picked);
    }
  }
}
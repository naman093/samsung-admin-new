import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_theme/app_colors.dart';

class CustomDatePicker {
  const CustomDatePicker._();

  static DateTime parseDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return DateTime.now();

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return DateTime.now();
    }

    return DateTime(year, month, day);
  }

  static Future<void> pickDate({
    required TextEditingController controller,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime defaultFirstDate = firstDate ?? DateTime(2000);
    final DateTime defaultLastDate = lastDate ?? DateTime(2100);

    DateTime initialDate = controller.text.isEmpty
        ? DateTime.now()
        : parseDate(controller.text);

    if (initialDate.isBefore(defaultFirstDate)) {
      initialDate = defaultFirstDate;
    } else if (initialDate.isAfter(defaultLastDate)) {
      initialDate = defaultLastDate;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: defaultFirstDate,
      lastDate: defaultLastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.white,
              surface: AppColors.backgroundColor,
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      controller.text =
          "${pickedDate.day.toString().padLeft(2, '0')}-"
          "${pickedDate.month.toString().padLeft(2, '0')}-"
          "${pickedDate.year}";
    }
  }
}

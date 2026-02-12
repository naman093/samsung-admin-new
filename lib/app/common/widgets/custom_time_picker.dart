import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_theme/app_colors.dart';

class CustomTimePicker {
  const CustomTimePicker._();

  static TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return TimeOfDay.now();

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return TimeOfDay.now();
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  static Future<void> pickTime({
    required TextEditingController controller,
    bool is24HourFormat = true,
  }) async {
    final TimeOfDay initialTime = controller.text.isEmpty
        ? TimeOfDay.now()
        : _parseTime(controller.text);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: Get.context!,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: AppColors.backgroundColor,
              dayPeriodColor:  AppColors.primaryColor,
            ),
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.white,
              surface: AppColors.backgroundColor,
              onSurface: AppColors.white,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: is24HourFormat,
            ),
            child: child!,
          ),
        );
      },
    );

    if (pickedTime != null) {
      if (is24HourFormat) {
        final hour = pickedTime.hour.toString().padLeft(2, '0');
        final minute = pickedTime.minute.toString().padLeft(2, '0');
        controller.text = "$hour:$minute";
      } else {
        controller.text = pickedTime.format(Get.context!);
      }
    }
  }
}


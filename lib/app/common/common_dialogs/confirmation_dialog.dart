import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';

class CMDialogs {
  static Future<void> showConfirmationDialog({
    required String title,
    required String subtitle,
    VoidCallback? onPressed,
    String? confirmBtnText,
  }) {
    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.backgroundColor,
          titlePadding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 10,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          actionsPadding: EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 16,
          ),
          title: Text(
            title,
            style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            subtitle,
            style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: onPressed,
              child: Text(
                'Yes',
                style: TextStyle(
                  color: AppColors.redColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

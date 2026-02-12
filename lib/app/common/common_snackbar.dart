import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import '../app_theme/app_colors.dart';

class CommonSnackbar {
  static void error(String? message) {
    toastification.dismissAll();
    toastification.show(
      icon: Icon(Icons.error, color: AppColors.white),
      title: Text(
        message ?? 'Something went wrong!',
        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      closeButton: ToastCloseButton(
        buttonBuilder: (context, onClose) => IconButton(
          onPressed: () => toastification.dismissAll(),
          icon: Icon(Icons.clear, color: AppColors.white, size: 16),
        ),
      ),
      autoCloseDuration: Duration(seconds: 2),
      backgroundColor: Theme.of(Get.context!).colorScheme.error,
    );
  }

  static void success(String message, {Duration? autoCloseDuration}) {
    toastification.dismissAll();
    toastification.show(
      icon: Icon(Icons.check_outlined, color: AppColors.white),
      title: Text(
        message,
        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      closeButton: ToastCloseButton(
        buttonBuilder: (context, onClose) => IconButton(
          onPressed: () => toastification.dismissAll(),
          icon: Icon(Icons.clear, color: AppColors.white, size: 16),
        ),
      ),
      autoCloseDuration: autoCloseDuration ?? Duration(seconds: 2),
      backgroundColor: Theme.of(Get.context!).colorScheme.primary,
    );
  }

  static void notification({String message = '', String? descrption}) {
    toastification.dismissAll();
    toastification.show(
      icon: Icon(Icons.notifications, color: AppColors.white),
      title: Text(
        message,
        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      description: Text(
        descrption != null ? descrption : '',
        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      closeButton: ToastCloseButton(
        buttonBuilder: (context, onClose) => IconButton(
          onPressed: () => toastification.dismissAll(),
          icon: Icon(Icons.clear, color: AppColors.white, size: 16),
        ),
      ),
      autoCloseDuration: Duration(seconds: 2),
      backgroundColor: Theme.of(Get.context!).colorScheme.secondary,
    );
  }

  static void info(String message) {
    toastification.dismissAll();
    toastification.show(
      icon: Icon(Icons.info_outline, color: AppColors.white),
      title: Text(
        message,
        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      closeButton: ToastCloseButton(
        buttonBuilder: (context, onClose) => IconButton(
          onPressed: () => toastification.dismissAll(),
          icon: Icon(Icons.clear, color: AppColors.white, size: 16),
        ),
      ),
      autoCloseDuration: Duration(seconds: 2),
      backgroundColor: Theme.of(Get.context!).colorScheme.secondary,
    );
  }
}

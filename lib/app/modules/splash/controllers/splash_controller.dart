import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/repository/auth_repo/auth_repo.dart';
import 'package:samsung_admin_main_new/app/routes/app_pages.dart';

class SplashController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    Timer(const Duration(seconds: 3), () async {
      _determineInitialRoute();
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  Future<void> _determineInitialRoute() async {
    try {
      final authController = Get.find<AuthRepo>();
      await authController.checkAuthStatus();
      if (authController.isAuthenticated.value) {
        Get.offAllNamed(Routes.HOME);
      }
      else {
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      Get.offAllNamed(Routes.LOGIN);
    }
  }

}

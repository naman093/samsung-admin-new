import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/repository/auth_repo/auth_repo.dart';
import 'package:samsung_admin_main_new/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final mobileController = TextEditingController();
  final authRepo = Get.find<AuthRepo>();

  final mobileError = ''.obs;
  final isValidating = false.obs;
  final hasValidated = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'mobileNumberRequired'.tr;
    }
    final normalizedPhone = value.replaceAll(RegExp(r'\D'), '');

    if (normalizedPhone.length < 10) {
      return 'invalidPhoneNumber'.tr;
    }

    return null;
  }

  Future<void> handleLogin() async {
    debugPrint('🔵 handleLogin() called');
    debugPrint('📌 Starting form validation');
    if ((formKey.currentState!.validate())) {
      hasValidated.value = true;
      mobileError.value = '';
      final phoneNumber = mobileController.text.trim();
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      debugPrint('📞 Normalized phone number: $normalizedPhone');

      isValidating.value = true;
      debugPrint('⏳ isValidating set to true');

      try {
        debugPrint('🔍 Checking if user exists for login...');
        final userExists = await authRepo.checkUserExists(normalizedPhone);
        debugPrint('📨 User exists result: $userExists');

        if (!userExists) {
          debugPrint('❌ No user found for this phone number. Aborting login.');
          isValidating.value = false;
          mobileError.value = 'userNotFoundPleaseSignUp'.tr;
          CommonSnackbar.error(mobileError.value);
          return;
        }

        debugPrint('🚀 Calling generateOTPForLogin API...');
        final otpCode = await authRepo.generateOTPForLogin(normalizedPhone);

        debugPrint('📨 OTP response received: $otpCode');

        if (otpCode != null) {
          debugPrint('✅ OTP generated successfully');
          isValidating.value = false;

          debugPrint('➡️ Navigating to VERIFY_CODE screen');
          Get.toNamed(
            Routes.VERIFY_CODE,
            parameters: {'phoneNumber': normalizedPhone, 'source': 'login'},
          );
        } else {
          debugPrint('❌ OTP generation failed');

          String errorMessage = authRepo.errorMessage.value;
          debugPrint('⚠️ Error message from repo: $errorMessage');

          isValidating.value = false;

          if (errorMessage.contains('USER_NOT_FOUND')) {
            debugPrint('🔍 Error: USER_NOT_FOUND');
            mobileError.value = 'userNotFoundPleaseSignUp'.tr;
          } else if (errorMessage.contains('USER_NOT_ADMIN')) {
            debugPrint('🔍 Error: USER_NOT_ADMIN');
            mobileError.value = 'userNotAdmin'.tr;
          } else {
            debugPrint('🔍 Unknown error');
            mobileError.value = errorMessage.isNotEmpty
                ? errorMessage
                : 'failedToGenerateVerificationCode'.tr;
          }

          if (mobileError.value.isNotEmpty) {
            CommonSnackbar.error(mobileError.value);
          }
        }
      } catch (e, stackTrace) {
        debugPrint('🔥 Exception occurred in handleLogin');
        debugPrint('❌ Error: $e');
        debugPrint('📚 StackTrace: $stackTrace');

        isValidating.value = false;
        mobileError.value = 'genericErrorTryAgain'.tr;
        CommonSnackbar.error(mobileError.value);
      } finally {
        hasValidated.value = false;
        isValidating.value = false;
      }

      debugPrint('🔴 handleLogin() completed');
    }
  }
}

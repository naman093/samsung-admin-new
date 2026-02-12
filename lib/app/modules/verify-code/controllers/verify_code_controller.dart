import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/repository/auth_repo/auth_repo.dart';

import '../../../routes/app_pages.dart';

class VerifyCodeController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final verificationCodeController = TextEditingController();
  final _authRepo = Get.find<AuthRepo>();

  final phoneNumber = Get.parameters['phoneNumber'];
  final source = Get.parameters['source'];
  final isResending = false.obs;
  final isVerifying = false.obs;
  final otpError = ''.obs;
  Timer? _resendTimer;
  final resendCountdown = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _startResendTimer();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    verificationCodeController.dispose();
    super.onClose();
  }

  /// Check if form is valid
  bool get isFormValid {
    final otpCode = verificationCodeController.text.trim();
    return otpCode.length == 6;
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    resendCountdown.value = 60;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        timer.cancel();
        resendCountdown.value = 0;
      }
    });
  }

  Future<void> handleResendCode() async {
    if (phoneNumber == null || phoneNumber!.isEmpty) return;
    if (resendCountdown.value > 0) return;
    isResending.value = true;
    try {
      String? otpCode;
      if (source == 'login') {
        otpCode = await _authRepo.generateOTPForLogin(phoneNumber!);
      } else {
        otpCode = await _authRepo.generateOTP(phoneNumber!);
      }
      if (otpCode != null) {
        isResending.value = false;
        otpError.value = '';
        _startResendTimer();
      } else {
        isResending.value = false;
        otpError.value = _authRepo.errorMessage.value.isNotEmpty
            ? _authRepo.errorMessage.value
            : 'failedToResendVerificationCode'.tr;
        CommonSnackbar.error(otpError.value);
        formKey.currentState?.validate();
      }
    } catch (e) {
      isResending.value = false;
      otpError.value = 'errorWhileResendingCode'.tr;
      CommonSnackbar.error(otpError.value);
      formKey.currentState?.validate();
    }
  }

  Future<void> handleApproval() async {
    otpError.value = '';

    if (phoneNumber == null || phoneNumber!.isEmpty) {
      otpError.value = 'mobileNumberRequired'.tr;
      formKey.currentState?.validate();
      return;
    }

    final otpCode = verificationCodeController.text.trim();

    if (otpCode.isEmpty) {
      otpError.value = '${'verificationCode'.tr} ${'cantBeEmpty'.tr}';
      formKey.currentState?.validate();
      return;
    }

    isVerifying.value = true;

    try {
      // Use verifyOTPAndSignIn for both login and signup to ensure JWT token is stored
      bool success = await _authRepo.verifyOTPAndSignIn(
        phoneNumber: phoneNumber!,
        otpCode: otpCode,
      );

      if (success) {
        isVerifying.value = false;
        final currentUser = _authRepo.currentUser.value;
        final fullName = currentUser?.fullName?.trim() ?? '';

        if (source == 'login') {
          if (fullName.isEmpty) {
            Get.toNamed(
              Routes.PROFILE_DETAILS,
              parameters: {'phoneNumber': phoneNumber ?? ''},
            );
          } else {
            Get.offAllNamed(Routes.HOME);
          }
        } else {
          // For signup, navigate to profile details
          Get.toNamed(
            Routes.PROFILE_DETAILS,
            parameters: {'phoneNumber': phoneNumber ?? ''},
          );
        }
      } else {
        String errorMessage = _authRepo.errorMessage.value;

        isVerifying.value = false;
        if (errorMessage.contains('OTP_INCORRECT')) {
          otpError.value = 'otpIncorrect'.tr;
        } else if (errorMessage.contains('OTP_EXPIRED')) {
          otpError.value = 'otpExpired'.tr;
        } else {
          otpError.value = errorMessage.isNotEmpty
              ? errorMessage
              : 'otpVerificationFailed'.tr;
        }

        if (otpError.value.isNotEmpty) {
          CommonSnackbar.error(otpError.value);
        }
      }
    } catch (e) {
      isVerifying.value = false;
      otpError.value = 'genericErrorTryAgain'.tr;
      CommonSnackbar.error(otpError.value);
      formKey.currentState?.validate();
    } finally {
      isVerifying.value = false;
      isVerifying.value = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/repository/auth_repo/auth_repo.dart';
import 'package:samsung_admin_main_new/app/routes/app_pages.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final mobileController = TextEditingController();
  final _authRepo = Get.find<AuthRepo>();

  final mobileError = ''.obs;
  final isValidating = false.obs;
  final hasValidated = false.obs;
  final isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to mobile number changes and update form validity
    mobileController.addListener(_updateFormValidity);
  }

  void _updateFormValidity() {
    final phoneNumber = mobileController.text.trim();
    if (phoneNumber.isEmpty) {
      isFormValid.value = false;
      return;
    }

    // Normalize phone number for validation
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    // Phone number must be exactly 10 digits
    isFormValid.value = normalizedPhone.length == 10;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    mobileController.removeListener(_updateFormValidity);
    super.onClose();
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'mobileNumberRequired'.tr;
    }

    // Normalize phone number for validation
    final normalizedPhone = value.replaceAll(RegExp(r'\D'), '');

    // Phone number must be exactly 10 digits
    if (normalizedPhone.length != 10) {
      return 'invalidPhoneNumber'.tr;
    }

    return null;
  }

  Future<void> handleSignUp() async {
    debugPrint('🔵 handleSignUp() called');
    debugPrint('📌 Starting form validation');
    if (formKey.currentState!.validate()) {
      hasValidated.value = true;
      mobileError.value = '';
      final phoneNumber = mobileController.text.trim();
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

      debugPrint('📞 Phone entered: $phoneNumber');
      debugPrint('📞 Normalized phone: $normalizedPhone');

      isValidating.value = true;
      debugPrint('⏳ isValidating set to true');

      try {
        debugPrint('🔍 Fetching user details by phone...');
        final userDetails = await _authRepo.getUserDetailsByPhone(
          normalizedPhone,
        );

        debugPrint('📨 User details response: $userDetails');

        if (userDetails != null) {
          final role = userDetails['role'] as String?;
          final fullName = (userDetails['full_name'] as String?)?.trim() ?? '';

          debugPrint('👤 User role: $role');
          debugPrint('👤 Full name: $fullName');

          if (role == 'admin') {
            if (fullName.isNotEmpty) {
              debugPrint(
                '⚠️ Admin with full name already exists → blocking signup',
              );

              isValidating.value = false;
              mobileError.value = 'userAlreadySignedUp'.tr;
              CommonSnackbar.error(mobileError.value);
              formKey.currentState?.validate();
            } else {
              debugPrint(
                'ℹ️ Admin exists but full name is empty → proceeding to OTP',
              );

              final otpCode = await _authRepo.generateOTP(normalizedPhone);

              debugPrint(
                '📨 OTP response (existing admin without name): $otpCode',
              );

              isValidating.value = false;

              if (otpCode != null) {
                debugPrint('✅ OTP generated successfully for existing admin');

                Get.toNamed(
                  Routes.VERIFY_CODE,
                  parameters: {
                    'phoneNumber': normalizedPhone,
                    'source': 'signup',
                  },
                );
              } else {
                debugPrint(
                  '❌ OTP generation failed for existing admin without name',
                );
                debugPrint('⚠️ Repo error: ${_authRepo.errorMessage.value}');

                mobileError.value = _authRepo.errorMessage.value.isNotEmpty
                    ? _authRepo.errorMessage.value
                    : 'failedToGenerateVerificationCode'.tr;
                CommonSnackbar.error(mobileError.value);
                formKey.currentState?.validate();
              }
            }
          } else {
            debugPrint('❌ User is NOT admin');

            isValidating.value = false;
            mobileError.value = 'userNotAdmin'.tr;
            CommonSnackbar.error(mobileError.value);
            formKey.currentState?.validate();
          }
        } else {
          debugPrint('🆕 No user found → Creating admin user');

          final createResult = await _authRepo.createAdminUser(normalizedPhone);

          debugPrint('📨 Create admin result: $createResult');

          if (createResult.isSuccess) {
            debugPrint('✅ Admin user created successfully');
            debugPrint('📩 Generating OTP');

            final otpCode = await _authRepo.generateOTP(normalizedPhone);

            debugPrint('📨 OTP response: $otpCode');

            if (otpCode != null) {
              debugPrint('✅ OTP generated successfully');

              isValidating.value = false;
              Get.toNamed(
                Routes.VERIFY_CODE,
                parameters: {
                  'phoneNumber': normalizedPhone,
                  'source': 'signup',
                },
              );
            } else {
              debugPrint('❌ OTP generation failed after user creation');
              debugPrint('⚠️ Repo error: ${_authRepo.errorMessage.value}');

              isValidating.value = false;
              mobileError.value = _authRepo.errorMessage.value.isNotEmpty
                  ? _authRepo.errorMessage.value
                  : 'failedToGenerateVerificationCode'.tr;
              CommonSnackbar.error(mobileError.value);
              formKey.currentState?.validate();
            }
          } else {
            debugPrint('❌ Failed to create admin user');
            debugPrint('⚠️ Create error: ${createResult.errorOrNull}');

            isValidating.value = false;
            mobileError.value =
                createResult.errorOrNull ?? 'failedToCreateAdminAccount'.tr;
            CommonSnackbar.error(mobileError.value);
            formKey.currentState?.validate();
          }
        }
      } catch (e, stackTrace) {
        debugPrint('🔥 Exception in handleSignUp');
        debugPrint('❌ Error: $e');
        debugPrint('📚 StackTrace: $stackTrace');

        isValidating.value = false;
        mobileError.value = 'genericErrorTryAgain'.tr;
        CommonSnackbar.error(mobileError.value);
        formKey.currentState?.validate();
      } finally {
        debugPrint('🔄 handleSignUp() finally block');
        isValidating.value = false;
        hasValidated.value = false;
      }
    } else {
      debugPrint('❌ Form validation failed');
    }

    debugPrint('🔴 handleSignUp() completed');
  }
}

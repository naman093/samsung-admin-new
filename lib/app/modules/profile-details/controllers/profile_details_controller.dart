import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/repository/auth_repo/auth_repo.dart';
import 'package:samsung_admin_main_new/app/routes/app_pages.dart';

class ProfileDetailsController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  final _authRepo = Get.find<AuthRepo>();

  final isSubmitting = false.obs;
  final hasValidated = false.obs;
  final nameError = ''.obs;
  final _firstNameText = ''.obs;
  final _lastNameText = ''.obs;

  final String? phoneNumber = Get.parameters['phoneNumber'];

  /// Reactive getter to check if form is valid (both fields have length > 0)
  bool get isFormValid {
    return _firstNameText.value.trim().isNotEmpty &&
        _lastNameText.value.trim().isNotEmpty;
  }

  @override
  void onInit() {
    super.onInit();
    // Add listeners to text controllers to update reactive variables
    firstNameController.addListener(() {
      _firstNameText.value = firstNameController.text;
    });
    lastNameController.addListener(() {
      _lastNameText.value = lastNameController.text;
    });
  }

  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'firstNameRequired'.tr;
    }
    if (value.trim().length < 2) {
      return 'firstNameTooShort'.tr;
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'lastNameRequired'.tr;
    }
    if (value.trim().length < 2) {
      return 'lastNameTooShort'.tr;
    }
    return null;
  }

  Future<void> handleSubmit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (phoneNumber == null || phoneNumber!.trim().isEmpty) {
      nameError.value = 'mobileNumberRequired'.tr;
      Get.snackbar(
        'error'.tr,
        nameError.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    hasValidated.value = true;
    nameError.value = '';
    isSubmitting.value = true;

    final normalizedPhone = phoneNumber!.replaceAll(RegExp(r'\D'), '');
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final fullName = '$firstName $lastName';

    try {
      // Save profile details
      final success = await _authRepo.saveProfile(
        phoneNumber: normalizedPhone,
        profileData: {'fullName': fullName},
      );

      if (!success) {
        nameError.value = _authRepo.errorMessage.value.isNotEmpty
            ? _authRepo.errorMessage.value
            : 'genericErrorTryAgain'.tr;
        Get.snackbar(
          'error'.tr,
          nameError.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      // Enroll user (create auth session and mark as enrolled)
      final enrollResult = await _authRepo.enrollUser(
        phoneNumber: normalizedPhone,
      );

      if (enrollResult.isSuccess) {
        isSubmitting.value = false;
        Get.offAllNamed(Routes.HOME);
      } else {
        nameError.value = _authRepo.errorMessage.value.isNotEmpty
            ? _authRepo.errorMessage.value
            : 'genericErrorTryAgain'.tr;
        Get.snackbar(
          'error'.tr,
          nameError.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('🔥 Exception in handleSubmit (ProfileDetails)');
      debugPrint('❌ Error: $e');
      debugPrint('📚 StackTrace: $stackTrace');

      nameError.value = 'genericErrorTryAgain'.tr;
      Get.snackbar(
        'error'.tr,
        nameError.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      hasValidated.value = false;
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.onClose();
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/repository/auth_repo/auth_repo.dart';

import '../../../models/user_model.dart';

class EditProfileController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  final hasValidated = false.obs;
  final selectedImageUrlValue = ''.obs;
  final selectedImageBytes = Rxn<Uint8List>();

  final authRepo = Get.find<AuthRepo>();

  final isLoadingValue = true.obs;
  final isSaveBtnValue = false.obs;

  final firstNameError = ''.obs;
  final lastNameError = ''.obs;

  final isEdited = false.obs;

  late String _originalFirstName;
  late String _originalLastName;
  late String _originalImageUrl;

  final userId = Get.parameters['userId'];

  @override
  Future<void> onInit() async {
    super.onInit();
    isLoadingValue.value = true;
    print('isLoadingValue.value::  ${isLoadingValue.value}');
    await setData();
    firstNameController.addListener(_checkChanges);
    lastNameController.addListener(_checkChanges);
    selectedImageBytes.listen((_) => _checkChanges());
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // void setData() {
  //   UserModel? user = Get.parameters['userId'] != null
  //       ? authRepo.getUserDetailsByUserId(Get.parameters['userId'] ?? '')
  //       : authRepo.currentUser.value;
  //   if (user != null) {
  //     firstNameController.text = user.fullName?.split(' ').first ?? '';
  //     lastNameController.text = user.fullName?.split(' ').last ?? '';
  //     _originalFirstName = firstNameController.text;
  //     _originalLastName = lastNameController.text;
  //     if (user.profilePictureUrl != null) {
  //       selectedImageUrlValue.value = user.profilePictureUrl ?? '';
  //       _originalImageFile.value = File(user.profilePictureUrl!);
  //     }
  //     else {
  //       selectedImageUrlValue.value = '';
  //       selectedImageFile.value = null;
  //       _originalImageFile.value = null;
  //     }
  //     selectedImageBytes.value = null;
  //     _originalImageBytes.value = null;
  //   }
  //   isEdited.value = false;
  // }

  Future<void> setData() async {
    try {
      isLoadingValue.value = true;
      UserModel? user;

      if (userId != null) {
        user = await authRepo.getUserDetailsByUserId(userId ?? '');
      } else {
        user = authRepo.currentUser.value;
      }

      if (user != null) {
        firstNameController.text = user.fullName?.split(' ').first ?? '';
        lastNameController.text = user.fullName?.split(' ').last ?? '';

        _originalFirstName = firstNameController.text;
        _originalLastName = lastNameController.text;

        selectedImageBytes.value = null;

        if (user.profilePictureUrl != null &&
            user.profilePictureUrl!.isNotEmpty) {
          final url = user.profilePictureUrl!;
          _originalImageUrl = url;
          selectedImageUrlValue.value =
              '$url?t=${DateTime.now().millisecondsSinceEpoch}';
        } else {
          selectedImageUrlValue.value = '';
          _originalImageUrl = '';
        }
      }
    } finally {
      isEdited.value = false;
      isLoadingValue.value = false;
    }
  }

  void _checkChanges() {
    final nameChanged = firstNameController.text.trim() != _originalFirstName;
    final lastNameChanged = lastNameController.text.trim() != _originalLastName;
    final imageChanged = selectedImageBytes.value != null;

    isEdited.value = nameChanged || lastNameChanged || imageChanged;
  }

  Future<void> pickProfileImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;

        selectedImageUrlValue.value = '';

        if (kIsWeb) {
          selectedImageBytes.value = platformFile.bytes;
        } else {
          if (platformFile.bytes != null) {
            selectedImageBytes.value = platformFile.bytes;
          } else if (platformFile.path != null) {
            try {
              final file = File(platformFile.path!);
              selectedImageBytes.value = await file.readAsBytes();
            } catch (e) {
              debugPrint('Error reading file bytes: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
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

  void undoChanges() {
    firstNameController.text = _originalFirstName;
    lastNameController.text = _originalLastName;
    selectedImageBytes.value = null;
    selectedImageUrlValue.value = _originalImageUrl;
    isEdited.value = false;
  }

  bool hasError = false;
  Future<void> updateAuthUserData() async {
    firstNameError.value = '';
    lastNameError.value = '';
    hasError = false;
    if (firstNameController.text.isEmpty) {
      firstNameError.value = 'firstNameIsRequired'.tr;
      hasError = true;
    }

    if (lastNameController.text.isEmpty) {
      lastNameError.value = 'lastNameIsRequired'.tr;
      hasError = true;
    }

    if (hasError == true) return;
    try {
      if (!isEdited.value) return;
      isSaveBtnValue.value = true;
      final success = await authRepo.editProfile(
        name: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        fileBytes: selectedImageBytes.value,
      );

      if (success) {
        _originalFirstName = firstNameController.text.trim();
        _originalLastName = lastNameController.text.trim();

        UserModel? updatedUser;
        if (userId != null) {
          updatedUser = await authRepo.getUserDetailsByUserId(userId!);
        } else {
          updatedUser = authRepo.currentUser.value;
        }

        if (updatedUser?.profilePictureUrl != null &&
            updatedUser!.profilePictureUrl!.isNotEmpty) {
          final newUrl = updatedUser.profilePictureUrl!;
          _originalImageUrl = newUrl;

          selectedImageBytes.value = null;
          selectedImageUrlValue.value =
              '$newUrl?t=${DateTime.now().millisecondsSinceEpoch}';
        } else {
          selectedImageUrlValue.value = '';
          selectedImageBytes.value = null;
          _originalImageUrl = '';
        }
      }

      isEdited.value = false;
    } finally {
      isSaveBtnValue.value = false;
    }
  }
}

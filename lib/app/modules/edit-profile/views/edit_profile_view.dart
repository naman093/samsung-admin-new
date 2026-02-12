import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/gradient_text_field.dart';
import 'package:samsung_admin_main_new/app/common/widgets/profile_widget.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonWidget.commonCardView(
      title: 'profile'.tr,
      subTitle: 'editProfileDescription'.tr,
      child: Obx(
        () => CommonWidget.isLoadingAndEmptyWidget(
          isLoadingValue: controller.isLoadingValue.value,
          isEmpty: false,
          widget: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  spacing: 73,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GradientTextField(
                            labelText: 'firstName'.tr,
                            hintText: 'typeHere'.tr,
                            errorText: controller.firstNameError.value,
                            controller: controller.firstNameController,
                            keyboardType: TextInputType.name,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^[a-zA-Z]+$'),
                              ),
                            ],
                            validator: (value) {
                              if (!controller.hasValidated.value) return null;
                              return controller.validateFirstName(value);
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: GradientTextField(
                            labelText: 'lastName'.tr,
                            hintText: 'typeHere'.tr,
                            errorText: controller.lastNameError.value,
                            controller: controller.lastNameController,
                            keyboardType: TextInputType.name,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^[a-zA-Z]+$'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => ProfilePictureWidget(
                        onTap: () => controller.pickProfileImage(),
                        imageFile: null,
                        imageBytes: controller.selectedImageBytes.value,
                        imageUrl: controller.selectedImageUrlValue.value,
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => SizedBox(
                    width: 500,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 21,
                      children: [
                        _cmnButton(
                          text: 'undoChanges'.tr,
                          textColor: AppColors.redColor,
                          onTap: controller.isEdited.value
                              ? controller.undoChanges
                              : () {},
                          borderColor: AppColors.redColor,
                          backgroundColor: controller.isEdited.value
                              ? null
                              : Colors.grey.withOpacity(0.3),
                        ),
                        _cmnButton(
                          text: 'saveChanges'.tr,
                          onTap:
                              controller.isEdited.value &&
                                  !controller.isSaveBtnValue.value
                              ? controller.updateAuthUserData
                              : () {},
                          // backgroundColor: controller.isEdited.value
                          //     ? AppColors.gradientColor2
                          //     : Colors.grey,
                          textColor: AppColors.blue400,
                          borderColor: AppColors.blue400,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cmnButton({
    required final String text,
    final Color? borderColor,
    final Color? backgroundColor,
    final Color? textColor = Colors.white,
    required final VoidCallback onTap,
  }) {
    return Obx(
      () => Opacity(
        opacity: controller.isEdited.value ? 1 : 0.2,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 60),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  width: 1,
                  color: borderColor ?? AppColors.whiteOpacity60,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7.86, sigmaY: 7.86),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'samsungsharpsans',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            letterSpacing: 0,
                            color: textColor ?? Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

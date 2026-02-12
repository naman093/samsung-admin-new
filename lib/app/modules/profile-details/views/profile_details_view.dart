import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app_theme/app_colors.dart';
import '../../../common/common_button.dart';
import '../../../common/widgets/gradient_text_field.dart';
import '../../login/local_widget/auth_card.dart';
import '../controllers/profile_details_controller.dart';

class ProfileDetailsView extends GetView<ProfileDetailsController> {
  const ProfileDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: AuthCard(
            showBackButton: true,
            child: Form(
              key: controller.formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                spacing: 60,
                children: [
                  SizedBox(
                    width: 480,
                    child: Column(
                      spacing: 20,
                      children: [
                        GradientTextField(
                          labelText: 'firstName'.tr,
                          hintText: 'enterFirstName'.tr,
                          controller: controller.firstNameController,
                          keyboardType: TextInputType.name,
                          inputFormatters: [
                            FilteringTextInputFormatter.singleLineFormatter,
                          ],
                          validator: (value) {
                            if (!controller.hasValidated.value) return null;

                            final validationError = controller
                                .validateFirstName(value);
                            if (validationError != null) {
                              return validationError;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (controller.hasValidated.value) {
                              controller.nameError.value = '';
                              controller.formKey.currentState?.validate();
                            }
                          },
                        ),
                        GradientTextField(
                          labelText: 'lastName'.tr,
                          hintText: 'enterLastName'.tr,
                          controller: controller.lastNameController,
                          keyboardType: TextInputType.name,
                          inputFormatters: [
                            FilteringTextInputFormatter.singleLineFormatter,
                          ],
                          validator: (value) {
                            if (!controller.hasValidated.value) return null;

                            final validationError = controller.validateLastName(
                              value,
                            );
                            if (validationError != null) {
                              return validationError;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (controller.hasValidated.value) {
                              controller.nameError.value = '';
                              controller.formKey.currentState?.validate();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 480,
                    child: Column(
                      spacing: 20,
                      children: [
                        Obx(
                          () => CommonButton(
                            borderRadius: 100,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            text: controller.isSubmitting.value
                                ? 'submitting'.tr
                                : 'continue'.tr,
                            onTap: controller.handleSubmit,
                            isEnabled:
                                !controller.isSubmitting.value &&
                                controller.isFormValid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

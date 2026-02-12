import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app_theme/app_colors.dart';
import '../../../common/common_button.dart';
import '../../../common/widgets/gradient_text_field.dart';
import '../../login/local_widget/auth_card.dart';
import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(
          () => Center(
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
                      child: GradientTextField(
                        labelText: 'mobileNumber'.tr,
                        hintText: 'typeHere'.tr,
                        controller: controller.mobileController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (!controller.hasValidated.value) return null;

                          final validationError = controller.validatePhone(
                            value,
                          );
                          if (validationError != null) {
                            return validationError;
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (controller.hasValidated.value) {
                            controller.mobileError.value = '';
                            controller.formKey.currentState?.validate();
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 480,
                      child: Column(
                        spacing: 20,
                        children: [
                          CommonButton(
                            borderRadius: 100,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            text: controller.isValidating.value
                                ? 'generatingOtp'.tr
                                : 'sendVerificationCode'.tr,
                            onTap: controller.handleSignUp,
                            isEnabled:
                                !controller.isValidating.value &&
                                controller.isFormValid.value,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'alreadyHaveAnAccount'.tr,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => Get.back(),
                                  child: Text(
                                    'login'.tr,
                                    style: const TextStyle(
                                      color: AppColors.authSpansColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}

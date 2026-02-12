import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/routes/app_pages.dart';
import '../../../app_theme/app_colors.dart';
import '../../../common/common_button.dart';
import '../../../common/widgets/gradient_text_field.dart';
import '../controllers/login_controller.dart';
import '../local_widget/auth_card.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

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
                                ? 'checking'.tr
                                : 'sendVerificationCode'.tr,
                            onTap: controller.handleLogin,
                            isEnabled: !controller.isValidating.value,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'noAccountYet'.tr,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 4),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed(Routes.SIGNUP);
                                  },
                                  child: Text(
                                    'createAccount'.tr,
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

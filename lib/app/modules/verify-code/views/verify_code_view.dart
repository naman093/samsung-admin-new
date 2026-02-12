import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../app_theme/app_colors.dart';
import '../../../common/common_button.dart';
import '../../../common/widgets/gradient_text_field.dart';
import '../../login/local_widget/auth_card.dart';
import '../controllers/verify_code_controller.dart';

class VerifyCodeView extends GetView<VerifyCodeController> {
  const VerifyCodeView({super.key});
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
                  children: [
                    SizedBox(
                      width: 480,
                      child: GradientTextField(
                        labelText: 'verificationCode'.tr,
                        hintText: 'enterVerificationCode'.tr,
                        controller: controller.verificationCodeController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '${'verificationCode'.tr} ${'cantBeEmpty'.tr}';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (controller.otpError.value.isNotEmpty) {
                            controller.otpError.value = '';
                            controller.formKey.currentState?.validate();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    controller.resendCountdown.value > 0
                        ? Text(
                            '${'otpSent'.tr} ${controller.resendCountdown.value} ${'seconds'.tr}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.authSpansColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          )
                        : MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap:
                                  (controller.isResending.value ||
                                      controller.resendCountdown.value > 0)
                                  ? null
                                  : controller.handleResendCode,
                              child: Opacity(
                                opacity:
                                    (controller.isResending.value ||
                                        controller.resendCountdown.value > 0)
                                    ? 0.5
                                    : 1.0,
                                child: Text(
                                  'resendVerificationCode'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.authSpansColor,
                                    fontFamily: 'Samsung Sharp Sans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    height: 1.5,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: 480,
                      child: Column(
                        children: [
                          CommonButton(
                            borderRadius: 100,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            text: controller.isVerifying.value
                                ? 'verifying'.tr
                                : 'confirmation'.tr,
                            onTap: controller.handleApproval,
                            isEnabled:
                                !controller.isVerifying.value &&
                                controller.isFormValid,
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

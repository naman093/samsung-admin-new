import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/common/common_button.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/file_upload_field.dart';
import 'package:samsung_admin_main_new/app/common/widgets/gradient_text_field.dart';
import 'package:samsung_admin_main_new/app/modules/community/controllers/community_controller.dart';

class WordLimitFormatter extends TextInputFormatter {
  final int maxWords;

  WordLimitFormatter(this.maxWords);

  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  String _truncateToWordLimit(String text) {
    if (text.trim().isEmpty) return text;

    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= maxWords) {
      return text;
    }

    // Take only the first maxWords words
    final truncatedWords = words.take(maxWords).toList();
    return truncatedWords.join(' ');
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final wordCount = _countWords(newValue.text);

    if (wordCount > maxWords) {
      // Truncate to first maxWords words
      final truncatedText = _truncateToWordLimit(newValue.text);

      // Calculate the new cursor position
      // If the text was truncated, place cursor at the end
      final newSelection = TextSelection.collapsed(
        offset: truncatedText.length,
      );

      return TextEditingValue(text: truncatedText, selection: newSelection);
    }

    return newValue;
  }
}

class CreateEditFeed extends StatelessWidget {
  final CommunityController controller;
  const CreateEditFeed({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Obx(
            () => SizedBox(
              width: 298,
              child: GradientTextField(
                labelText: 'title'.tr,
                hintText: 'typeHere'.tr,
                errorText: controller.titleError.value,
                keyboardType: TextInputType.text,
                readOnly: controller.isCreating.value,
                controller: controller.titleController,
                maxLines: 1,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                validator: (value) {
                  if (!controller.hasValidated.value) return null;

                  final validationError = controller.validateTitle(value);
                  if (validationError != null) {
                    return validationError;
                  }
                  return null;
                },
                onChanged: (value) {
                  if (controller.hasValidated.value) {
                    controller.titleError.value = '';
                    controller.formKey.currentState?.validate();
                  }
                },
              ),
            ),
          ),
          Obx(
            () => GradientTextField(
              labelText: 'description'.tr,
              hintText: 'typeHere'.tr,
              keyboardType: TextInputType.text,
              errorText: controller.descriptionError.value,
              readOnly: controller.isCreating.value,
              controller: controller.descriptionController,
              maxLines: 3,
              minLines: 3,
              onChanged: (value) {
                if (controller.hasValidated.value) {
                  controller.titleError.value = '';
                  controller.formKey.currentState?.validate();
                }
              },
            ),
          ),
          Obx(
            () => SizedBox(
              width: 298,
              child: FileUploadField(
                fileType: FileType.image,
                labelText: 'uploadAPicture'.tr,
                errorText: controller.imageError.value,
                enabled: !controller.isCreating.value,
                hintText: controller.isAlreadyFileUploaded.value
                    ? 'File Already Uploaded'
                    : 'noFileSelected'.tr,
                suffix: AssetImageWidget(
                  imagePath: AppAssets.imagesIcUploadIcon,
                  width: 20,
                  height: 20,
                ).marginAll(8),
                onFileSelected: (file) {
                  controller.setSelectedFile(file);
                },
              ),
            ),
          ),
          Obx(
            () => Row(
              children: [
                Checkbox(
                  activeColor: AppColors.authSpansColor,
                  side: BorderSide(color: AppColors.white),
                  value: controller.checkboxValue.value,
                  onChanged: controller.isCreating.value
                      ? null
                      : (value) {
                          controller.checkboxValue.value = value ?? false;
                        },
                ),
                Text('sharePostAlsoInTheCommunityFeed'.tr),
              ],
            ),
          ),

          Obx(
            () => CommonButton(
              text: controller.isEditing.value ? 'update'.tr : 'create'.tr,
              onTap: controller.isCreating.value
                  ? null
                  : () async {
                      if (controller.formKey.currentState?.validate() ??
                          false) {
                        if (controller.isEditing.value) {
                          await controller.updateFeed();
                        } else {
                          await controller.createFeed();
                        }
                      }
                    },
              isEnabled: !controller.isCreating.value,
              isLoading: controller.isCreating.value,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import 'package:samsung_admin_main_new/app/common/common_button.dart';
import 'package:samsung_admin_main_new/app/common/common_radio.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/constant/types.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/file_upload_field.dart';
import 'package:samsung_admin_main_new/app/common/widgets/gradient_text_field.dart';
import 'package:samsung_admin_main_new/app/modules/vod-podcasts/controllers/vod_podcasts_controller.dart';

class CreateEditContent extends StatelessWidget {
  final VodPodcastsController controller;
  final bool isEditing;
  const CreateEditContent({
    super.key,
    required this.controller,
    this.isEditing = false,
  });

  Widget _uploadFileTextField({
    required final FileType fileType,
    final String? errorText,
  }) {
    return SingleChildScrollView(
      child: Obx(
        () => SizedBox(
          width: 298,
          child: FileUploadField(
            fileType: fileType,
            errorText: errorText,
            enabled: !controller.isCreateContentBtnValue.value,
            labelText: 'uploadAFile'.tr,
            hintText: controller.isAlreadyFileUploaded.value
                ? 'File Already Uploaded'
                : 'noFileSelected'.tr,
            suffix: AssetImageWidget(
              imagePath: AppAssets.imagesIcUploadIcon,
              width: 20,
              height: 20,
            ).marginAll(8),
            maxFileSizeBytes: fileType == FileType.video
                ? 49 * 1024 * 1024
                : null,
            onFileSelected: (file) => controller.setSelectedFile(file),
          ),
        ),
      ),
    );
  }

  Widget _uploadBackgroundImageTextField({final String? errorText}) {
    return Obx(
      () => SizedBox(
        width: 298,
        child: FileUploadField(
          fileType: FileType.image,
          labelText: 'uploadABackgroundImage'.tr,
          errorText: errorText,
          enabled: !controller.isCreateContentBtnValue.value,
          hintText: controller.isAlreadyThumbnailUrlUploaded.value
              ? 'File Already Uploaded'
              : 'noFileSelected'.tr,
          suffix: AssetImageWidget(
            imagePath: AppAssets.imagesIcUploadIcon,
            width: 20,
            height: 20,
          ).marginAll(8),
          onFileSelected: controller.setSelectedThumbnailUrlFile,
        ),
      ),
    );
  }

  Widget _titleTextField() {
    return Obx(
      () => Expanded(
        child: GradientTextField(
          labelText: 'title'.tr,
          hintText: 'typeHere'.tr,
          errorText: controller.titleError.value,
          maxLines: 1,
          keyboardType: TextInputType.text,
          readOnly: controller.isCreateContentBtnValue.value,
          controller: controller.titleController,
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
    );
  }

  Widget _descriptionTextField() {
    return Obx(
      () => GradientTextField(
        labelText: 'description'.tr,
        hintText: 'typeHere'.tr,
        minLines: 3,
        maxLines: 3,
        errorText: controller.descriptionErrorValue.value,
        readOnly: controller.isCreateContentBtnValue.value,
        controller: controller.descriptionController,
        onChanged: (value) {
          if (controller.descriptionController.text.isNotEmpty) {
            controller.formKey.currentState?.validate();
          }
        },
      ).marginOnly(top: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'selectTheTypeOfFileYouWant'.tr,
              style: AppTextStyles.rubik14w400(),
            ),
            SizedBox(height: 8),
            Obx(
              () => Row(
                spacing: 24,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonRadio<ContentType>(
                    value: ContentType.vod,
                    groupValue: controller.selectedContentType.value,
                    label: 'vod'.tr,
                    onChanged: (value) {
                      if (value == null ||
                          controller.isEditing.value ||
                          controller.isCreateContentBtnValue.value) {
                        return;
                      }
                      controller.selectedContentType.value = value;
                      controller.formKey.currentState?.validate();
                    },
                  ),
                  CommonRadio<ContentType>(
                    value: ContentType.podcast,
                    groupValue: controller.selectedContentType.value,
                    label: 'podcast'.tr,
                    onChanged: (value) {
                      if (value == null ||
                          controller.isEditing.value ||
                          controller.isCreateContentBtnValue.value) {
                        return;
                      }
                      controller.selectedContentType.value = value;
                      controller.formKey.currentState?.validate();
                    },
                  ),
                ],
              ),
            ),
            Row(
              spacing: 24,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleTextField(),
                Expanded(
                  child: controller.selectedContentType.value == ContentType.vod
                      ? _uploadFileTextField(
                          fileType: FileType.video,
                          errorText: controller.videoFileError.value,
                        )
                      : _uploadBackgroundImageTextField(
                          errorText: controller.thumbnailUrlFileError.value,
                        ),
                ),
              ],
            ).marginOnly(top: 16),
            _descriptionTextField(),
            controller.selectedContentType.value != ContentType.vod
                ? _uploadFileTextField(
                    fileType: FileType.audio,
                    errorText: controller.videoFileError.value,
                  ).marginOnly(top: 16)
                : Container(),
            Obx(
              () => Container(
                margin: EdgeInsets.only(top: 16),
                child: CommonButton(
                  text: controller.isEditing.value ? 'update'.tr : 'create'.tr,
                  isEnabled: !controller.isCreateContentBtnValue.value,
                  isLoading: controller.isCreateContentBtnValue.value,
                  onTap: controller.isCreateContentBtnValue.value
                      ? null
                      : () {
                          if (controller.formKey.currentState?.validate() ??
                              false) {
                            if (controller.isEditing.value) {
                              controller.updateFile();
                            } else {
                              controller.createFile();
                            }
                          }
                        },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

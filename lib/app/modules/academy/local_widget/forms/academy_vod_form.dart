import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/modules/academy/controllers/academy_controller.dart';

import '../../../../common/common_button.dart';
import '../../../../common/constant/app_assets.dart';
import '../../../../common/widgets/asset_image_widget.dart';
import '../../../../common/widgets/file_upload_field.dart';
import '../../../../common/widgets/gradient_text_field.dart';

class AcademyVodForm extends GetView<AcademyController> {
  const AcademyVodForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 20),
      child: Column(
        spacing: 30,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            spacing: 30,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 24,
                children: [
                  Expanded(
                    child: _inputTextField(
                      'nameOfVideo'.tr,
                      'typeHere'.tr,
                      textEditController: controller.videoNameController,
                      errorText: controller.videoNameError.value.isEmpty
                          ? null
                          : controller.videoNameError.value,
                    ),
                  ),
                  Expanded(child: _uploadFileTextField()),
                ],
              ),
              _inputTextField(
                'description'.tr,
                'typeHere'.tr,
                minLines: 3,
                maxLines: 3,
                textEditController: controller.descriptionController,
                errorText: controller.descriptionError.value.isEmpty
                    ? null
                    : controller.descriptionError.value,
              ),
              Row(
                spacing: 24,
                children: [
                  Expanded(
                    child: _inputTextField(
                      'totalPointsToWin(optional)'.tr,
                      '00'.tr,
                      isNumberField: true,
                      textEditController: controller.totalPointController,
                      errorText: controller.totalPointError.value.isEmpty
                          ? null
                          : controller.totalPointError.value,
                    ),
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
          Obx(
            () => CommonButton(
              isEnabled: !controller.isCreateContentBtnValue.value,
              isLoading: controller.isCreateContentBtnValue.value,
              onTap: () {
                if (controller.isEditMode.value) {
                  controller.updateAcademyContentVOD();
                } else {
                  controller.createAcademyContentVOD();
                }
              },
              text: controller.isEditMode.value ? 'update'.tr : 'create'.tr,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputTextField(
    String label,
    String hintText, {
    int minLines = 1,
    int maxLines = 1,
    TextEditingController? textEditController,
    bool isNumberField = false,
    String? errorText,
  }) {
    return Obx(() {
      final isDisabled = controller.isCreateContentBtnValue.value;
      return GradientTextField(
        labelText: label,
        hintText: hintText,
        minLines: minLines,
        maxLines: maxLines,
        readOnly: isDisabled,
        controller: textEditController,
        errorText: errorText,
        inputFormatters: [
          if (isNumberField) FilteringTextInputFormatter.digitsOnly,
        ],
      );
    });
  }

  Widget _uploadFileTextField() {
    return Obx(
      () => SizedBox(
        width: 298,
        child: FileUploadField(
          fileType: FileType.video,
          maxFileSizeBytes: 49 * 1024 * 1024,
          enabled: !controller.isCreateContentBtnValue.value,
          labelText: 'uploadAFile'.tr,
          errorText: controller.vodFileError.value.isEmpty
              ? null
              : controller.vodFileError.value,
          hintText: controller.selectedVodUrl.value.isNotEmpty
              ? 'File Already Uploaded'
              : 'noFileSelected'.tr,
          suffix: AssetImageWidget(
            imagePath: AppAssets.imagesIcUploadIcon,
            width: 20,
            height: 20,
          ).marginAll(8),
          onFileSelected: (file) {
            controller.selectedVODFile.value = file;
            if (file == null) {
              // File was removed - clear the URL and show validation error
              controller.selectedVodUrl.value = '';
            } else {
              // New file selected - clear any existing error
              controller.vodFileError.value = '';
            }
          },
        ),
      ),
    );
  }
}

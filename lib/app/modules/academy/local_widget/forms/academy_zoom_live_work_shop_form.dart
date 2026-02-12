import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/widgets/custom_time_picker.dart';
import 'package:samsung_admin_main_new/app/modules/academy/controllers/academy_controller.dart';

import '../../../../common/common_button.dart';
import '../../../../common/constant/app_assets.dart';
import '../../../../common/widgets/asset_image_widget.dart';
import '../../../../common/widgets/custom_date_picker.dart';
import '../../../../common/widgets/file_upload_field.dart';
import '../../../../common/widgets/gradient_text_field.dart';

class AcademyZoomLiveWorkShopForm extends GetView<AcademyController> {
  const AcademyZoomLiveWorkShopForm({super.key});

  bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 20),
      child: Column(
        spacing: 40,
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
                    child: Obx(
                      () => _inputTextField(
                        'workshopDate'.tr,
                        '00/00/0000'.tr,
                        textEditController: controller.workshopDateController,
                        readOnly: true,
                        errorText: controller.workshopDateError.value.isEmpty
                            ? null
                            : controller.workshopDateError.value,
                        onTap: () => CustomDatePicker.pickDate(
                          controller: controller.workshopDateController,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => _inputTextField(
                        'startTime'.tr,
                        '00:00'.tr,
                        textEditController: controller.startTimeController,
                        readOnly: true,
                        errorText: controller.startTimeError.value.isEmpty
                            ? null
                            : controller.startTimeError.value,
                        onTap: () => CustomTimePicker.pickTime(
                          controller: controller.startTimeController,
                          is24HourFormat: false,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => _inputTextField(
                        'endTime'.tr,
                        '00:00'.tr,
                        textEditController: controller.endTimeController,
                        readOnly: true,
                        errorText: controller.endTimeError.value.isEmpty
                            ? null
                            : controller.endTimeError.value,
                        onTap: () => CustomTimePicker.pickTime(
                          controller: controller.endTimeController,
                          is24HourFormat: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 24,
                children: [
                  Expanded(
                    child: _inputTextField(
                      'costOfParticipationInPoints'.tr,
                      '00'.tr,
                      isNumberField: true,
                      textEditController:
                          controller.costOfParticipationInPointsController,
                    ),
                  ),
                  Expanded(
                    child: _inputTextField(
                      'costOfParticipationInCredit(optional)'.tr,
                      '00'.tr,
                      isNumberField: true,
                      textEditController:
                          controller.costOfParticipationInCreditController,
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 24,
                children: [
                  Expanded(
                    child: Obx(
                      () => _inputTextField(
                        'nameOfWorkshop'.tr,
                        'typeHere'.tr,
                        textEditController: controller.nameOfWorkshopController,
                        errorText: controller.nameOfWorkshopError.value.isEmpty
                            ? null
                            : controller.nameOfWorkshopError.value,
                      ),
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
              Obx(() {
                final isDisabled = controller.isCreateContentBtnValue.value;
                return GradientTextField(
                  labelText: 'zoomLink'.tr,
                  hintText: 'typeHere'.tr,
                  minLines: 1,
                  maxLines: 1,
                  controller: controller.zoomLinkController,
                  readOnly: isDisabled,
                  keyboardType: TextInputType.url,
                  errorText: controller.zoomLinkError.value.isNotEmpty
                      ? controller.zoomLinkError.value
                      : null,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'zoomLinkIsRequired'.tr.isEmpty
                          ? 'Zoom link is required'
                          : 'zoomLinkIsRequired'.tr;
                    }
                    if (!_isValidUrl(value.trim())) {
                      return 'invalidUrl'.tr.isEmpty
                          ? 'Please enter a valid URL'
                          : 'invalidUrl'.tr;
                    }
                    return null;
                  },
                );
              }),
            ],
          ),
          Obx(
            () => CommonButton(
              isEnabled: !controller.isCreateContentBtnValue.value,
              isLoading: controller.isCreateContentBtnValue.value,
              onTap: () {
                if (controller.isEditMode.value) {
                  controller.updateAcademyContentZoomWorkshop();
                } else {
                  controller.createAcademyContentZoomWorkshop();
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
    bool readOnly = false,
    GestureTapCallback? onTap,
    String? errorText,
  }) {
    return Obx(() {
      final isDisabled = controller.isCreateContentBtnValue.value;
      return GradientTextField(
        labelText: label,
        hintText: hintText,
        minLines: minLines,
        maxLines: maxLines,
        controller: textEditController,
        readOnly: readOnly || isDisabled,
        onTap: isDisabled ? null : onTap,
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
          fileType: FileType.image,
          enabled: !controller.isCreateContentBtnValue.value,
          labelText: 'uploadABackgroundImage'.tr,
          errorText: controller.zoomFileError.value.isEmpty
              ? null
              : controller.zoomFileError.value,
          hintText: controller.selectedVodUrl.value.isNotEmpty
              ? 'File Already Uploaded'
              : 'noFileSelected'.tr,
          suffix: AssetImageWidget(
            imagePath: AppAssets.imagesIcUploadIcon,
            width: 20,
            height: 20,
          ).marginAll(8),
          onFileSelected: (file) {
            controller.selectedZoomFile.value = file;
            if (file == null) {
              // File was removed - clear the URL and show validation error
              controller.selectedVodUrl.value = '';
            } else {
              // New file selected - clear any existing error
              controller.zoomFileError.value = '';
            }
          },
        ),
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/common_button.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/custom_date_picker.dart';
import 'package:samsung_admin_main_new/app/common/widgets/file_upload_field.dart';
import 'package:samsung_admin_main_new/app/common/widgets/gradient_text_field.dart';
import 'package:samsung_admin_main_new/app/modules/events/controllers/events_controller.dart';

class CreateEditEvent extends StatelessWidget {
  final EventsController controller;
  final bool? isEdit;
  const CreateEditEvent({super.key, required this.controller, this.isEdit});

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
      final isDisabled = controller.isCreateEventBtnValue.value;
      return GradientTextField(
        labelText: label,
        errorText: errorText,
        hintText: hintText,
        minLines: minLines,
        maxLines: maxLines,
        controller: textEditController,
        readOnly: readOnly || isDisabled,
        onTap: isDisabled ? null : onTap,
        inputFormatters: [
          if (isNumberField) FilteringTextInputFormatter.digitsOnly,
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Obx(
        () => Column(
          spacing: 20,
          children: [
            Row(
              spacing: 20,
              children: [
                Expanded(
                  child: _inputTextField(
                    'theDateOfTheEvent'.tr,
                    '00/00/0000'.tr,
                    readOnly: true,
                    errorText: controller.eventDateError.value,
                    textEditController: controller.eventDate,
                    onTap: () => CustomDatePicker.pickDate(
                      controller: controller.eventDate,
                      firstDate: DateTime.now(),
                      lastDate: controller.endDate.text.isEmpty
                          ? null
                          : CustomDatePicker.parseDate(controller.endDate.text),
                    ),
                  ),
                ),
                Expanded(
                  child: _inputTextField(
                    'validity'.tr,
                    '00/00/0000'.tr,
                    textEditController: controller.endDate,
                    readOnly: true,
                    errorText: controller.endDateError.value,
                    onTap: () => CustomDatePicker.pickDate(
                      controller: controller.endDate,
                      firstDate: DateTime.now(),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 20,
              children: [
                Expanded(
                  child: _inputTextField(
                    'costPoints'.tr,
                    'typeHere'.tr,
                    errorText: controller.costInPointsError.value,
                    isNumberField: true,
                    textEditController: controller.costInPoints,
                  ),
                ),
                Expanded(
                  child: _inputTextField(
                    'creditCost'.tr,
                    'typeHere'.tr,
                    errorText: controller.creditCostError.value,
                    isNumberField: true,
                    readOnly: true,
                    textEditController: controller.creditCost,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 20,
              children: [
                Expanded(
                  child: _inputTextField(
                    'maxTickets'.tr,
                    'typeHere'.tr,
                    errorText: controller.maxTicketsError.value,
                    isNumberField: true,
                    textEditController: controller.maxTickets,
                  ),
                ),
                const Spacer(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Expanded(
                  child: _inputTextField(
                    'title'.tr,
                    'typeHere'.tr,
                    errorText: controller.titleError.value,
                    textEditController: controller.title,
                  ),
                ),
                Obx(
                  () => Expanded(
                    child: FileUploadField(
                      labelText: 'backgroundImage'.tr,
                      enabled: !controller.isCreateEventBtnValue.value,
                      hintText: controller.isAlreadyFileUploaded.value
                          ? 'File Already Uploaded'
                          : 'exampleJpgPng'.tr,
                      errorText: controller.imageError.value,
                      fileType: FileType.image,
                      suffix: AssetImageWidget(
                        imagePath: AppAssets.imagesIcUploadIcon,
                        width: 20,
                        height: 20,
                      ).marginAll(8),
                      onFileSelected: controller.setSelectedFile,
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => GradientTextField(
                controller: controller.description,
                labelText: 'description'.tr,
                hintText: 'typeHere'.tr,
                readOnly: controller.isCreateEventBtnValue.value,
                minLines: 3,
                errorText: controller.descriptionError.value,
                maxLines: 3,
              ),
            ),
            Obx(
              () => FileUploadField(
                enabled: !controller.isCreateEventBtnValue.value,
                labelText: 'explanatoryVideoOptional'.tr,
                maxFileSizeBytes: 49 * 1024 * 1024,
                hintText:
                    controller
                        .isAlreadyExplanatoryVideoOptionalFileUploaded
                        .value
                    ? 'File Already Uploaded'
                    : 'exampleMp4'.tr,
                fileType: FileType.video,
                suffix: AssetImageWidget(
                  imagePath: AppAssets.imagesIcUploadIcon,
                  width: 20,
                  height: 20,
                ).marginAll(8),
                onFileSelected: controller.setExplanatoryVideoOptionalFile,
              ),
            ),
            SizedBox(height: 20),
            Obx(
              () => CommonButton(
                text: isEdit == true ? 'updateEvent'.tr : 'createAnEvent'.tr,
                onTap: () => {
                  isEdit == true
                      ? controller.updateEvent()
                      : controller.createEvent(),
                },
                isEnabled: !controller.isCreateEventBtnValue.value,
                isLoading: controller.isCreateEventBtnValue.value,
              ).marginOnly(bottom: 20),
            ),
          ],
        ),
      ),
    );
  }
}

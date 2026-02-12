import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/common_button.dart';
import 'package:samsung_admin_main_new/app/common/common_radio.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/custom_time_interval_picker.dart';
import 'package:samsung_admin_main_new/app/common/widgets/file_upload_field.dart';
import 'package:samsung_admin_main_new/app/common/widgets/gradient_text_field.dart';
import 'package:samsung_admin_main_new/app/modules/promotions/controllers/promotions_controller.dart';

class CreateEditPromotion extends StatelessWidget {
  final PromotionsController controller;
  final bool isEdit;

  const CreateEditPromotion({
    super.key,
    required this.controller,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Obx(
        () => Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GradientTextField(
              labelText: 'title'.tr,
              hintText: 'typeHere'.tr,
              maxLines: 1,
              minLines: 1,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
              controller: controller.titleController,
              errorText: controller.titleError.value,
              readOnly: controller.isCreating.value,
            ),
            GradientTextField(
              labelText: 'description'.tr,
              hintText: 'typeHere'.tr,
              controller: controller.descriptionController,
              errorText: controller.descriptionError.value,
              readOnly: controller.isCreating.value,
              minLines: 3,
              maxLines: 3,
            ),
            Obx(
              () => FileUploadField(
                labelText: 'uploadABackgroundImage'.tr,
                enabled: !controller.isCreating.value,
                hintText: controller.isAlreadyFileUploaded.value
                    ? 'fileAlreadyUploaded'.tr
                    : 'exampleJpgPng'.tr,
                errorText: controller.imageError.value,
                fileType: FileType.image,
                suffix: AssetImageWidget(
                  imagePath: AppAssets.imagesIcUploadIcon,
                  width: 20,
                  height: 20,
                ).marginAll(8),
                onFileSelected: (value) {
                  controller.selectedBackgroundImage.value = value;
                  if (value == null) {
                    controller.isAlreadyFileUploaded.value = false;
                    controller.imageError.value = '';
                  } else {
                    controller.imageError.value = '';
                  }
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'frequency'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 8),
                Obx(
                  () => Row(
                    spacing: 24,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CommonRadio<PromotionFrequencyType>(
                        value: PromotionFrequencyType.oneTime,
                        groupValue: controller.selectedFrequencyType.value,
                        label: 'oneTime'.tr,
                        onChanged:
                            controller.isCreating.value ||
                                controller.isEditing.value
                            ? null
                            : (value) {
                                if (value != null) {
                                  controller.selectedFrequencyType.value =
                                      value;
                                  if (value == PromotionFrequencyType.oneTime) {
                                    controller.intervalController.clear();
                                    controller.intervalError.value = '';
                                  }
                                }
                              },
                      ),
                      CommonRadio<PromotionFrequencyType>(
                        value: PromotionFrequencyType.setInterval,
                        groupValue: controller.selectedFrequencyType.value,
                        label: 'setInterval'.tr,
                        onChanged:
                            controller.isCreating.value ||
                                controller.isEditing.value
                            ? null
                            : (value) {
                                if (value != null) {
                                  controller.selectedFrequencyType.value =
                                      value;
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Obx(
              () =>
                  controller.selectedFrequencyType.value ==
                      PromotionFrequencyType.setInterval
                  ? GradientTextField(
                      labelText: 'interval'.tr,
                      hintText: 'selectInterval'.tr,
                      controller: controller.intervalDisplayController,
                      errorText: controller.intervalError.value,
                      readOnly: true,
                      onTap: controller.isCreating.value
                          ? null
                          : () async {
                              await CustomTimeIntervalPicker.pickInterval(
                                controller: controller.intervalController,
                              );
                              controller.updateFormattedIntervalDisplay();
                            },
                    )
                  : const SizedBox.shrink(),
            ),
            SizedBox(height: 20),
            Obx(
              () => CommonButton(
                text: controller.isEditing.value
                    ? 'updatePromotion'.tr
                    : 'createPromotion'.tr,
                onTap: controller.isCreating.value
                    ? null
                    : () => controller.createOrUpdatePromotion(),
                isEnabled: !controller.isCreating.value,
                isLoading: controller.isCreating.value,
              ).marginOnly(bottom: 20),
            ),
          ],
        ),
      ),
    );
  }
}

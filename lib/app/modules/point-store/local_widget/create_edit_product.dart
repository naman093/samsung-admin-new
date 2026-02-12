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
import 'package:samsung_admin_main_new/app/modules/point-store/controllers/point_store_controller.dart';

class CreateEditProduct extends StatelessWidget {
  final PointStoreController controller;
  const CreateEditProduct({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    Widget inputTextField(
      String label,
      String hintText, {
      int minLines = 1,
      int maxLines = 1,
      TextEditingController? textEditController,
      bool isNumberField = false,
      bool readOnly = false,
      String? errorText,
      GestureTapCallback? onTap,
    }) {
      return Obx(() {
        final isDisabled = controller.isLoading.value;
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        spacing: 20,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 26,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(
                  () => inputTextField(
                    'costInPointsProd'.tr,
                    '00'.tr,
                    isNumberField: true,
                    textEditController: controller.costInPointsController,
                    errorText: controller.costInPointsError.value.isEmpty
                        ? null
                        : controller.costInPointsError.value,
                  ),
                ),
              ),
              Expanded(
                child: Obx(
                  () => inputTextField(
                    'validityProduct'.tr,
                    '00/00/0000'.tr,
                    textEditController: controller.endDateController,
                    readOnly: true,
                    errorText: controller.endDateError.value.isEmpty
                        ? null
                        : controller.endDateError.value,
                    onTap: () => CustomDatePicker.pickDate(
                      controller: controller.endDateController,
                      firstDate: DateTime.now(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            spacing: 26,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(
                  () => inputTextField(
                    'titleProduct'.tr,
                    'typeHere'.tr,
                    textEditController: controller.titleController,
                    errorText: controller.titleError.value.isEmpty
                        ? null
                        : controller.titleError.value,
                  ),
                ),
              ),
              Obx(
                () => Expanded(
                  child: FileUploadField(
                    labelText: 'backgroundImageProduct'.tr,
                    enabled: !controller.isLoading.value,
                    initialFile: controller.selectedFile.value,
                    hintText: controller.existingImageUrl.value.isNotEmpty
                        ? 'File Already Uploaded'
                        : null,
                    errorText: controller.imageError.value.isEmpty
                        ? null
                        : controller.imageError.value,
                    onFileSelected: controller.setSelectedFile,
                    suffix: AssetImageWidget(
                      imagePath: AppAssets.imagesIcUploadIcon,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          inputTextField(
            'descriptionProduct'.tr,
            'typeHere'.tr,
            minLines: 5,
            maxLines: 5,
            textEditController: controller.descriptionController,
            errorText: controller.descriptionError.value.isEmpty
                ? null
                : controller.descriptionError.value,
          ),
          Obx(
            () => FileUploadField(
              labelText: 'explanatoryVideoOptional'.tr,
              enabled: !controller.isLoading.value,
              fileType: FileType.video,
              maxFileSizeBytes: 49 * 1024 * 1024,
              hintText: controller.existingVideoUrl.value.isNotEmpty
                  ? 'fileAlreadyUploaded'.tr
                  : null,
              suffix: AssetImageWidget(
                imagePath: AppAssets.imagesIcUploadIcon,
                width: 20,
                height: 20,
              ),
              initialFile: controller.explanatoryVideoOptionalFile.value,
              onFileSelected: controller.setExplanatoryVideoOptionalFile,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.11),
          Obx(
            () => CommonButton(
              onTap: () => controller.isEditing.value
                  ? controller.updateProduct()
                  : controller.createProduct(),
              text: controller.isEditing.value
                  ? 'updateProduct'.tr
                  : 'createProduct'.tr,
              isLoading: controller.isLoading.value,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/common/common_button.dart';
import 'package:samsung_admin_main_new/app/common/common_flyout.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/custom_date_picker.dart';
import 'package:samsung_admin_main_new/app/common/widgets/custom_time_picker.dart';
import 'package:samsung_admin_main_new/app/common/widgets/file_upload_field.dart';
import 'package:samsung_admin_main_new/app/common/widgets/gradient_text_field.dart';
import 'package:samsung_admin_main_new/app/common/widgets/task_type_dropdown.dart';
import 'package:samsung_admin_main_new/app/modules/weekly-riddle/controllers/weekly_riddle_controller.dart';

class CreateEditRiddle extends StatelessWidget {
  const CreateEditRiddle({super.key, required this.controller});

  final WeeklyRiddleController controller;

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
      bool useExpanded = true,
    }) {
      return Obx(() {
        final isDisabled = controller.isCreateContentBtnValue.value;
        final textField = GradientTextField(
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

        return useExpanded ? Expanded(child: textField) : textField;
      });
    }

    Widget taskTypeDropdown() {
      return Obx(
        () => TaskTypeDropdown(
          selectedValue: controller.selectedTaskTypeValue,
          items: controller.taskTypeList,
          labelMap: controller.taskTypeLabelMap,
          labelText: 'taskType'.tr,
          width: 300,
          onSelected: controller.isCreateContentBtnValue.value
              ? null
              : (value) {
                  controller.selectedTaskTypeValue.value = value;
                },
        ),
      );
    }

    return CommonFlyout(
      onClose: () => Get.back(),
      title: 'uploadANewPuzzle'.tr,
      description: 'systemActivity'.tr,
      canDismiss: () => !controller.isCreateContentBtnValue.value,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 30,
              children: [
                taskTypeDropdown(),
                Row(
                  spacing: 26,
                  children: [
                    inputTextField(
                      'taskStartDate'.tr,
                      '00/00/0000'.tr,
                      textEditController: controller.startDateController,
                      errorText: controller.startDateError.value,
                      onTap: () => CustomDatePicker.pickDate(
                        controller: controller.startDateController,
                        firstDate: DateTime.now(),
                        lastDate: controller.endDateController.text.isNotEmpty
                            ? CustomDatePicker.parseDate(
                                controller.endDateController.text,
                              )
                            : null,
                      ),
                    ),
                    inputTextField(
                      'taskCompletionDateR'.tr,
                      '00/00/0000'.tr,
                      textEditController: controller.endDateController,
                      errorText: controller.endDateError.value,
                      onTap: () => CustomDatePicker.pickDate(
                        controller: controller.endDateController,
                        firstDate: CustomDatePicker.parseDate(
                          controller.startDateController.text,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 26,
                  children: [
                    inputTextField(
                      'missionEndTime'.tr,
                      '00:00'.tr,
                      errorText: controller.missionEndTimeError.value,
                      textEditController: controller.missionEndTimeController,
                      onTap: () => CustomTimePicker.pickTime(
                        controller: controller.missionEndTimeController,
                      ),
                    ),
                    inputTextField(
                      'totalPointsToWin'.tr,
                      '00'.tr,
                      errorText: controller.totalPointsError.value,
                      textEditController: controller.totalPointsController,
                      isNumberField: true,
                    ),
                  ],
                ),
                Row(
                  spacing: 26,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    inputTextField(
                      'missionName'.tr,
                      'typeHere'.tr,
                      errorText: controller.missionNameError.value,
                      textEditController: controller.missionNameController,
                    ),
                    if (controller.selectedTaskTypeValue.value == 'Audio')
                      Obx(
                        () => SizedBox(
                          width: 298,
                          child: FileUploadField(
                            fileType: FileType.audio,
                            labelText: 'uploadAFile'.tr,
                            enabled: !controller.isCreateContentBtnValue.value,
                            hintText: controller.isAlreadyAudioSelected.value
                                ? 'fileAlreadyUploaded'.tr
                                : 'noFileSelected'.tr,
                            errorText: controller.titleError.value.isNotEmpty
                                ? controller.titleError.value
                                : null,
                            suffix: AssetImageWidget(
                              imagePath: AppAssets.imagesIcUploadIcon,
                              width: 20,
                              height: 20,
                            ).marginAll(8),
                            onFileSelected:
                                controller.setSelectedThumbnailUrlFile,
                          ),
                        ),
                      ),
                  ],
                ),
                inputTextField(
                  'description'.tr,
                  'typeHere'.tr,
                  textEditController: controller.descriptionController,
                  errorText: controller.descriptionError.value,
                  minLines: 3,
                  maxLines: 3,
                  useExpanded: false,
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fieldWidth = constraints.maxWidth * 0.47;
                    return Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 26,
                            runSpacing: 26,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            children: [
                              if (controller.selectedTaskTypeValue.value !=
                                  'Audio')
                                SizedBox(
                                  width: fieldWidth,
                                  child: inputTextField(
                                    'correctAnswer'.tr,
                                    'typeHere'.tr,
                                    errorText:
                                        controller.correctAnswerError.value,
                                    textEditController:
                                        controller.correctAnswerController,
                                    minLines: 1,
                                    maxLines: 1,
                                    useExpanded: false,
                                  ),
                                ),
                              if (controller.selectedTaskTypeValue.value ==
                                  'MCQ')
                                ...List.generate(
                                  controller.optionControllers.length,
                                  (index) => Stack(
                                    children: [
                                      SizedBox(
                                        width: fieldWidth,
                                        child: inputTextField(
                                          'option'.tr,
                                          'typeHere'.tr,
                                          textEditController: controller
                                              .optionControllers[index],
                                          minLines: 1,
                                          maxLines: 1,
                                          useExpanded: false,
                                        ),
                                      ),
                                      if (controller.optionControllers.length >
                                          1)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () => controller
                                                  .removeOption(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withValues(
                                                    alpha: 0.1,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () =>
                                controller.selectedTaskTypeValue.value == 'MCQ'
                                ? MouseRegion(
                                    cursor:
                                        controller.isCreateContentBtnValue.value
                                        ? SystemMouseCursors.basic
                                        : SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap:
                                          controller
                                              .isCreateContentBtnValue
                                              .value
                                          ? null
                                          : controller.addOption,
                                      child: Opacity(
                                        opacity:
                                            controller
                                                .isCreateContentBtnValue
                                                .value
                                            ? 0.5
                                            : 1.0,
                                        child: Text(
                                          '+ ${'addOption'.tr}',
                                          style: const TextStyle(
                                            color: AppColors.authSpansColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 100),
                Obx(
                  () => CommonButton(
                    text: controller.isEditing.value
                        ? 'update'.tr
                        : 'create'.tr,
                    onTap: controller.isEditing.value
                        ? controller.updateRiddle
                        : controller.createWeeklyRiddle,
                    isEnabled: !controller.isCreateContentBtnValue.value,
                    isLoading: controller.isCreateContentBtnValue.value,
                  ).marginOnly(bottom: 20),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

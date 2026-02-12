import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/widgets/custom_time_picker.dart';
import 'package:samsung_admin_main_new/app/modules/academy/controllers/academy_controller.dart';
import '../../../../app_theme/app_colors.dart';
import '../../../../common/common_button.dart';
import '../../../../common/constant/app_assets.dart';
import '../../../../common/widgets/asset_image_widget.dart';
import '../../../../common/widgets/custom_date_picker.dart';
import '../../../../common/widgets/file_upload_field.dart';
import '../../../../common/widgets/gradient_text_field.dart';

enum MissionTaskType { mcq, text, audio }

extension MissionTaskTypeX on MissionTaskType {
  static MissionTaskType fromApiValue(String? value) {
    switch (value) {
      case 'MCQ':
        return MissionTaskType.mcq;
      case 'Text':
        return MissionTaskType.text;
      case 'Audio':
        return MissionTaskType.audio;
      default:
        return MissionTaskType.mcq;
    }
  }

  String get apiValue {
    switch (this) {
      case MissionTaskType.mcq:
        return 'MCQ';
      case MissionTaskType.text:
        return 'Text';
      case MissionTaskType.audio:
        return 'Audio';
    }
  }

  String get label {
    switch (this) {
      case MissionTaskType.mcq:
        return 'MCQ';
      case MissionTaskType.text:
        return 'Text Submission';
      case MissionTaskType.audio:
        return 'Audio Submission';
    }
  }
}

class AcademyMissionChallengeForm extends GetView<AcademyController> {
  const AcademyMissionChallengeForm({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.selectedMissionTaskType.value == MissionTaskType.mcq &&
        controller.listMissionChallengeAnotherField.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.listMissionChallengeAnotherField.add(
          AcademyMissionChallengeAnotherFieldModel(
            title: 'Option',
            textEditingController: TextEditingController(),
          ),
        );
      });
    }

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
                children: [
                  // Expanded(
                  //   child: _inputTextField(
                  //     'taskType'.tr,
                  //     'fileSubmissionTask'.tr,
                  //   ),
                  // ),
                  Expanded(child: _taskTypeDropdown()),
                  Expanded(child: SizedBox()),
                ],
              ),
              Row(
                spacing: 24,
                children: [
                  Expanded(
                    child: Obx(
                      () => _inputTextField(
                        'taskStartDate'.tr,
                        '00/00/0000'.tr,
                        readOnly: true,
                        textEditController: controller.taskStartDateController,
                        errorText: controller.taskStartDateError.value.isEmpty
                            ? null
                            : controller.taskStartDateError.value,
                        onTap: () => CustomDatePicker.pickDate(
                          controller: controller.taskStartDateController,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => _inputTextField(
                        'taskCompletionDate'.tr,
                        '00/00/0000'.tr,
                        readOnly: true,
                        textEditController:
                            controller.taskCompletionDateController,
                        errorText:
                            controller.taskCompletionDateError.value.isEmpty
                            ? null
                            : controller.taskCompletionDateError.value,
                        onTap: () => CustomDatePicker.pickDate(
                          controller: controller.taskCompletionDateController,
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
                      'totalPointsToWin(optional)'.tr,
                      '00',
                      isNumberField: true,
                      textEditController: controller.totalPointController,
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => _inputTextField(
                        'missionEndTime'.tr,
                        '00:00'.tr,
                        readOnly: true,
                        textEditController: controller.missionEndTimeController,
                        errorText: controller.missionEndTimeError.value.isEmpty
                            ? null
                            : controller.missionEndTimeError.value,
                        onTap: () => CustomTimePicker.pickTime(
                          controller: controller.missionEndTimeController,
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
                    child: Obx(
                      () => _inputTextField(
                        'nameOfTask'.tr,
                        'typeHere'.tr,
                        textEditController: controller.missionNameController,
                        errorText: controller.missionNameError.value.isEmpty
                            ? null
                            : controller.missionNameError.value,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (controller.selectedMissionTaskType.value ==
                          MissionTaskType.audio) {
                        return _uploadFileTextField();
                      } else {
                        return SizedBox();
                      }
                    }),
                  ),
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

              LayoutBuilder(
                builder: (context, constraints) {
                  final fieldWidth = constraints.maxWidth * 0.47;
                  return Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 30,
                          runSpacing: 30,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            if (controller.selectedMissionTaskType.value !=
                                MissionTaskType.audio)
                              SizedBox(
                                width: fieldWidth,
                                child: Obx(
                                  () => _inputTextField(
                                    'correctAnswer'.tr,
                                    'typeHere'.tr,
                                    textEditController:
                                        controller.correctAnswerController,
                                    errorText:
                                        controller
                                            .correctAnswerError
                                            .value
                                            .isEmpty
                                        ? null
                                        : controller.correctAnswerError.value,
                                  ),
                                ),
                              ),
                            if (controller.selectedMissionTaskType.value ==
                                    MissionTaskType.mcq &&
                                controller
                                    .listMissionChallengeAnotherField
                                    .isNotEmpty)
                              ...List.generate(
                                controller
                                    .listMissionChallengeAnotherField
                                    .length,
                                (index) {
                                  final item = controller
                                      .listMissionChallengeAnotherField[index];
                                  return Stack(
                                    children: [
                                      SizedBox(
                                        width: fieldWidth,
                                        child: Obx(
                                          () => _inputTextField(
                                            item.title ?? 'option'.tr,
                                            'typeHere'.tr,
                                            textEditController:
                                                item.textEditingController,
                                            errorText:
                                                controller
                                                        .missionOptionErrors[index]
                                                        ?.isEmpty ??
                                                    true
                                                ? null
                                                : controller
                                                      .missionOptionErrors[index],
                                          ),
                                        ),
                                      ),
                                      if (controller
                                              .listMissionChallengeAnotherField
                                              .length >
                                          1)
                                        Positioned(
                                          right:
                                              (Get.locale?.languageCode == 'he')
                                              ? null
                                              : 0,
                                          left:
                                              (Get.locale?.languageCode == 'he')
                                              ? 0
                                              : null,
                                          top: 0,
                                          child: GestureDetector(
                                            onTap:
                                                controller
                                                    .isCreateContentBtnValue
                                                    .value
                                                ? null
                                                : () {
                                                    item.textEditingController
                                                        ?.dispose();
                                                    controller
                                                        .listMissionChallengeAnotherField
                                                        .removeAt(index);
                                                  },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
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
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Obx(() {
                          if (controller.selectedMissionTaskType.value ==
                              MissionTaskType.mcq) {
                            return Align(
                              alignment: Alignment.centerRight,
                              child: MouseRegion(
                                cursor: controller.isCreateContentBtnValue.value
                                    ? SystemMouseCursors.basic
                                    : SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap:
                                      controller.isCreateContentBtnValue.value
                                      ? null
                                      : () => controller
                                            .listMissionChallengeAnotherField
                                            .add(
                                              AcademyMissionChallengeAnotherFieldModel(
                                                title: 'option'.tr,
                                                textEditingController:
                                                    TextEditingController(),
                                              ),
                                            ),
                                  child: Opacity(
                                    opacity:
                                        controller.isCreateContentBtnValue.value
                                        ? 0.5
                                        : 1.0,
                                    child: Text(
                                      '+ ${'addAnotherField'.tr}',
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        color: AppColors.authSpansColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox();
                          }
                        }),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          Obx(
            () => CommonButton(
              isEnabled: !controller.isCreateContentBtnValue.value,
              isLoading: controller.isCreateContentBtnValue.value,
              onTap: () {
                if (controller.isEditMode.value) {
                  controller.updateAcademyContentMissionChallenge();
                } else {
                  controller.createAcademyContentMissionChallenge();
                }
              },
              text: controller.isEditMode.value ? 'update'.tr : 'create'.tr,
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'taskType'.tr,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Obx(
          () => PopupMenuButton<MissionTaskType>(
            onSelected: (value) {
              controller.selectedMissionTaskType.value = value;
              if (value == MissionTaskType.mcq &&
                  controller.listMissionChallengeAnotherField.isEmpty) {
                controller.listMissionChallengeAnotherField.add(
                  AcademyMissionChallengeAnotherFieldModel(
                    title: 'option'.tr,
                    textEditingController: TextEditingController(),
                  ),
                );
              }
            },
            enabled:
                !controller.isEditMode.value &&
                !controller.isCreateContentBtnValue.value,
            itemBuilder: (context) {
              return controller.missionTaskTypes.map((type) {
                return PopupMenuItem<MissionTaskType>(
                  value: type,
                  child: Text(
                    type.label,
                    style: const TextStyle(
                      fontFamily: 'samsungsharpsans',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 24 / 14,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList();
            },
            offset: Offset(0, 50),
            color: Color(0xFF1D2024),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7.86, sigmaY: 7.86),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientColor1.withValues(alpha: 0.2),
                          AppColors.gradientColor2.withValues(alpha: 0.2),
                        ],
                        stops: const [0.0, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.selectedMissionTaskType.value.label,
                          style: const TextStyle(
                            fontFamily: 'samsungsharpsans',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 24 / 14,
                            color: Colors.white,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
          fileType: FileType.audio,
          enabled: !controller.isCreateContentBtnValue.value,
          labelText: 'uploadAudioFile'.tr,
          errorText: controller.audioFileError.value.isEmpty
              ? null
              : controller.audioFileError.value,
          hintText: controller.selectedVodUrl.value.isNotEmpty
              ? 'File Already Uploaded'
              : 'noFileSelected'.tr,
          suffix: AssetImageWidget(
            imagePath: AppAssets.imagesIcUploadIcon,
            width: 20,
            height: 20,
          ).marginAll(8),
          onFileSelected: (file) {
            controller.selectedAudioFile.value = file;
            if (file == null) {
              // Trash icon pressed or file cleared – remove existing value
              controller.selectedVodUrl.value = '';
              controller.audioFileError.value = '';
            } else {
              // New file selected – clear any existing error
              controller.audioFileError.value = '';
            }
          },
        ),
      ),
    );
  }
}

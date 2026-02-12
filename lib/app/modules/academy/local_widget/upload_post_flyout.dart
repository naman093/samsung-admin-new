import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import 'package:samsung_admin_main_new/app/common/common_flyout.dart';
import 'package:samsung_admin_main_new/app/common/common_radio.dart';
import 'package:samsung_admin_main_new/app/modules/academy/controllers/academy_controller.dart';

import '../../../models/academy_content_model.dart';
import 'forms/academy_mission_challenge_form.dart';
import 'forms/academy_vod_form.dart';
import 'forms/academy_zoom_live_work_shop_form.dart';

class UploadPostFlyout extends GetView<AcademyController> {
  const UploadPostFlyout({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CommonFlyout(
        title: controller.isEditMode.value
            ? 'editThisPost'.tr
            : 'uploadANewFile'.tr,
        description: 'academyDescription'.tr,
        onClose: () {
          controller.selectedType.value = AcademyPostType.vod;
          controller.resetAllFormControllers();
          Get.back();
        },
        canDismiss: () => !controller.isCreateContentBtnValue.value,
        children: [
          _buildAcademyPostTypeRadio().paddingSymmetric(horizontal: 30),
          SizedBox(height: 30),
          if (controller.selectedType.value == AcademyPostType.vod)
            AcademyVodForm(),
          if (controller.selectedType.value == AcademyPostType.assignment)
            AcademyMissionChallengeForm(),
          if (controller.selectedType.value == AcademyPostType.zoomWorkshop)
            AcademyZoomLiveWorkShopForm(),
        ],
      );
    });
  }

  Widget _buildAcademyPostTypeRadio() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'selectTheTypeOfFileYouWant'.tr,
            style: AppTextStyles.rubik14w400(),
          ),
          SizedBox(height: 8),
          Row(
            spacing: 24,
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonRadio<AcademyPostType>(
                value: AcademyPostType.vod,
                groupValue: controller.selectedType.value,
                label: 'video'.tr,
                onChanged: (value) {
                  if (value == null ||
                      controller.isEditMode.value ||
                      controller.isCreateContentBtnValue.value)
                    return;
                  controller.selectedType.value = value;
                  controller.resetAllFormControllers();
                },
              ),
              CommonRadio<AcademyPostType>(
                value: AcademyPostType.assignment,
                groupValue: controller.selectedType.value,
                label: 'skillChallenge'.tr,
                onChanged: (value) {
                  if (value == null ||
                      controller.isEditMode.value ||
                      controller.isCreateContentBtnValue.value)
                    return;
                  controller.selectedType.value = value;
                  controller.resetAllFormControllers();
                },
              ),
              CommonRadio<AcademyPostType>(
                value: AcademyPostType.zoomWorkshop,
                groupValue: controller.selectedType.value,
                label: 'zoomLiveWorkshop'.tr,
                onChanged: (value) {
                  if (value == null ||
                      controller.isEditMode.value ||
                      controller.isCreateContentBtnValue.value)
                    return;
                  controller.selectedType.value = value;
                  controller.resetAllFormControllers();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

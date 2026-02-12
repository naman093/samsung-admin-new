import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_svg_widget.dart';
import 'package:samsung_admin_main_new/app/modules/academy/controllers/academy_controller.dart';

import '../../../app_theme/app_colors.dart';
import '../../../app_theme/textstyles.dart';
import '../../../common/common_flyout.dart';
import '../../../common/constant/app_assets.dart';
import '../../../common/widgets/asset_image_widget.dart';
import '../../../common/widgets/common_widget.dart';
import '../../../models/academy_content_view_model.dart';

class AssignmentSubmissionsList extends GetView<AcademyController> {
  final AcademyContentViewModel academyContentViewModel;
  const AssignmentSubmissionsList({
    super.key,
    required this.academyContentViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CommonFlyout(
        title: academyContentViewModel.title,
        onClose: () => Get.back(),
        description:
            '${'totalAnswersToTheTask'.tr} ${controller.assignmentSubmissionList.length}',
        children: [submissionsList()],
      );
    });
  }

  Widget headingText({String? title, Color? color}) {
    return Expanded(
      child: Text(
        title ?? "",
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.rubik14w400().copyWith(
          color: color ?? Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget submissionsList() {
    return Obx(() {
      final submissions = controller.assignmentSubmissionList;
      return CommonWidget.isLoadingAndEmptyWidget(
        isLoadingValue: controller.isLoadingSubmissions.value,
        isEmpty: submissions.isEmpty,
        emptyMsgText: 'noData'.tr,
        widget: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: controller.downloadAssignmentSubmissionsCsv,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(7.2, 6, 7.2, 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromRGBO(214, 214, 214, 0.2),
                                Color.fromRGBO(112, 112, 112, 0.2),
                              ],
                              stops: [-0.4925, 1.2388],
                            ),
                            border: Border.all(
                              width: 1,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(0, 3.57),
                                blurRadius: 7.97,
                                color: Color(0x1A000000),
                              ),
                            ],
                          ),
                          child: AssetSvgWidget(
                            svgPath: AppAssets.downloadExcel,
                            height: 20,
                            width: 20,
                          ),
                        ),
                        Text(
                          'downloadToExcelFile'.tr,
                          style: AppTextStyles.rubik14w400().copyWith(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).marginOnly(top: 24, bottom: 12),
              Row(
                spacing: 2,
                children: [
                  headingText(title: 'userName'.tr, color: AppColors.greyColor),
                  headingText(
                    title: 'Submission date',
                    color: AppColors.greyColor,
                  ),
                  headingText(title: 'Answers', color: AppColors.greyColor),
                  headingText(
                    title: 'View the answers',
                    color: AppColors.greyColor,
                  ),
                ],
              ).marginOnly(top: 30),
              Divider(color: AppColors.dashboardContainerBorder, height: 30),
              ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final submission = submissions[index];
                  final username =
                      submission.submittedByName ?? submission.submittedByPhone;
                  final submissionDate = DateFormat(
                    'dd/MM/yyyy',
                  ).format(submission.submissionCreatedAt);
                  String answerStatus;
                  if (submission.isCorrect == null) {
                    answerStatus = 'answerStatusPending'.tr;
                  } else if (submission.isCorrect == true) {
                    answerStatus = 'answerStatusCorrect'.tr;
                  } else {
                    answerStatus = 'answerStatusWrong'.tr;
                  }
                  return Column(
                    children: [
                      Row(
                        spacing: 2,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (submission.submittedByProfilePicture !=
                                        null &&
                                    submission
                                        .submittedByProfilePicture!
                                        .isNotEmpty)
                                  CommonWidget.commonNetworkImageView(
                                    imageUrl:
                                        submission.submittedByProfilePicture ??
                                        '',
                                    height: 24,
                                    width: 24,
                                    borderRadius: BorderRadius.circular(12),
                                  ).paddingOnly(right: 6),
                                Flexible(
                                  child: Text(
                                    username ?? '-',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.rubik14w400().copyWith(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          headingText(title: submissionDate),
                          headingText(title: answerStatus),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () => controller.showImagePreviewDialog(submission),
                                child: RotatedBox(
                                  quarterTurns: 2,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 8.63,
                                        sigmaY: 8.63,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          left: 12,
                                          right: 12,
                                          top: 10,
                                          bottom: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color.fromRGBO(
                                                214,
                                                214,
                                                214,
                                                0.2,
                                              ),
                                              Color.fromRGBO(
                                                112,
                                                112,
                                                112,
                                                0.2,
                                              ),
                                            ],
                                            stops: [-0.49, 1.23],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                          border: Border.all(
                                            width: 1.1,
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(0, 8.15),
                                              blurRadius: 18.21,
                                              color: Color(0x1A000000),
                                            ),
                                            BoxShadow(
                                              offset: Offset(0, 33.07),
                                              blurRadius: 33.07,
                                              color: Color(0x17000000),
                                            ),
                                            BoxShadow(
                                              offset: Offset(0, 74.76),
                                              blurRadius: 45.05,
                                              color: Color(0x0D000000),
                                            ),
                                            BoxShadow(
                                              offset: Offset(0, 132.74),
                                              blurRadius: 53.19,
                                              color: Color(0x03000000),
                                            ),
                                            BoxShadow(
                                              offset: Offset(2.19, -2.19),
                                              blurRadius: 2.19,
                                              color: Color(0x40000000),
                                            ),
                                          ],
                                        ),
                                        child: AssetImageWidget(
                                          imagePath: AppAssets.rightArrow,
                                          height: 11,
                                          width: 6,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: AppColors.dashboardContainerBorder,
                        height: 30,
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemCount: submissions.length,
              ),
            ],
          ),
        ),
      );
    });
  }
}

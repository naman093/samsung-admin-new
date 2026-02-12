import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/create_upload_button.dart';
import 'package:samsung_admin_main_new/app/common/widgets/search_text_field.dart';
import 'package:samsung_admin_main_new/app/common/widgets/sort_by_dropdown.dart';
import 'package:samsung_admin_main_new/app/modules/academy/controllers/academy_controller.dart';
import 'package:samsung_admin_main_new/app/modules/academy/local_widget/upload_post_flyout.dart';

import '../../../common/widgets/custom_date_range_picker.dart';
import '../../../models/academy_content_model.dart';
import '../../../models/academy_content_view_model.dart';
import '../local_widget/assignment_submissions_list.dart';

class AcademyView extends GetView<AcademyController> {
  const AcademyView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonWidget.commonCardView(
      title: 'monthlyTasksTitle'.tr,
      subTitle: 'academyDescription'.tr,
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _newUploadButton(),
                Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSortByDropdown(),
                    SizedBox(width: 16),
                    _buildDateRangeView(),
                    SizedBox(width: 16),
                    SizedBox(width: 260, child: _voidSearchField()),
                  ],
                ),
              ],
            ),
          ),
          _usersListView(),
        ],
      ),
    );
  }

  _openFlyout(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Obx(
          () => PopScope(
            canPop: !controller.isCreateContentBtnValue.value,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: UploadPostFlyout(),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  Widget _newUploadButton() {
    controller.isEditMode.value = false;
    return CreateUploadButton(
      title: 'newUpload'.tr,
      description: 'academyDescription'.tr,
      onTap: () {
        controller.selectedType.value = AcademyPostType.vod;
        controller.resetAllFormControllers();
        _openFlyout(Get.context!);
      },
    );
  }

  Widget _buildSortByDropdown() {
    return SortByDropdown(
      selectedValue: controller.selectedShortByValue,
      items: controller.shortByList,
      labelMap: controller.shortByLabelMap,
      onSelected: (value) {
        controller.resetPage();
        controller.searchController.clear();
        controller.fetchAcademyList(shortBy: value);
      },
    );
  }

  Widget _buildDateRangeView() {
    return CustomDateRangePickerField(
      startDate: controller.startDate,
      endDate: controller.endDate,
      onSaveDates: (start, end) async {
        await controller.fetchAcademyList(startDate: start, endDate: end);
      },
      onClearDates: () async {
        await controller.fetchAcademyList();
      },
    );
  }

  Widget _voidSearchField() {
    return SearchTextField(
      hintText: 'search'.tr,
      controller: controller.searchController,
      onChanged: (value) {
        controller.resetPage();
        controller.fetchAcademyList(searchTerm: value);
      },
    );
  }

  Widget _headingText({String? title, Color? color}) {
    return Expanded(
      child: Text(
        title ?? "",
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.rubik14w400().copyWith(
          color: color ?? Colors.white,
        ),
      ),
    );
  }

  Widget _usersListView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          final isLoadingMore = controller.isLoadingMore.value;
          return CommonWidget.isLoadingAndEmptyWidget(
            isLoadingValue:
                controller.isLoading.value && controller.academyList.isEmpty,
            isEmpty:
                controller.academyList.isEmpty && !controller.isLoading.value,
            emptyMsgText: 'noAcademyFound'.tr,
            widget: SizedBox(
              height:
                  constraints.maxHeight.isFinite && constraints.maxHeight > 0
                  ? constraints.maxHeight - 200
                  : MediaQuery.of(context).size.height * 0.7,
              child: SingleChildScrollView(
                controller: controller.scrollController,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _headingText(
                          title: 'fileType'.tr,
                          color: AppColors.greyColor,
                        ),
                        _headingText(
                          title: 'title'.tr,
                          color: AppColors.greyColor,
                        ),
                        _headingText(
                          title: 'creationDate'.tr,
                          color: AppColors.greyColor,
                        ),
                        _headingText(
                          title: 'dates'.tr,
                          color: AppColors.greyColor,
                        ),
                        _headingText(
                          title: 'hours'.tr,
                          color: AppColors.greyColor,
                        ),

                        _headingText(
                          title: 'numberOfPoints'.tr,
                          color: AppColors.greyColor,
                        ),
                        _headingText(
                          title: 'totalParticipants'.tr,
                          color: AppColors.greyColor,
                        ),
                        SizedBox(width: 30, height: 30),
                      ],
                    ).marginOnly(top: 30),
                    Divider(
                      color: AppColors.dashboardContainerBorder,
                      height: 30,
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final academy = controller.academyList[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: CommonWidget.commonNetworkImageView(
                                      imageUrl:
                                          academy.creatorProfilePictureUrl ??
                                          '',
                                      errorImageUrl: AppAssets.dummyImg,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      academy.fileType,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: AppTextStyles.rubik14w400()
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _headingText(title: academy.title),
                            _headingText(
                              title: DateFormat(
                                'dd/MM/yyyy',
                              ).format(academy.createdAt),
                            ),
                            _headingText(
                              title: formatStartEndDate(
                                startDate: academy.taskStartDate,
                                endDate: academy.taskEndDate,
                              ),
                            ),
                            _headingText(
                              title: formatTimeOrDateDisplay(academy),
                            ),
                            _headingText(title: '${academy.pointsToEarn}'),
                            _headingText(
                              title:
                                  "${academy.submissionUserIds?.length ?? 0}",
                            ),
                            PopupMenuButton<String>(
                              color: AppColors.darkGreyColor,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  controller.isEditMode.value = true;
                                  controller.clickOnEditAcademyBtn(academy);
                                } else if (value == 'delete') {
                                  controller.clickOnDeleteBtn(
                                    academy.academyContentId,
                                  );
                                } else if (value == 'view') {
                                  debugPrint('view  ${academy.title}');
                                  controller.fetchAssignmentSubmissions(
                                    assignmentId: academy.assignmentId ?? '',
                                  );
                                  _openViewAllSubmissionsFlyout(academy);
                                }
                              },
                              itemBuilder: (context) => [
                                popUpMenuBtnView(
                                  value: 'delete',
                                  title: 'delete'.tr,
                                  imagePath: AppAssets.trashIcon,
                                ),
                                popUpMenuBtnView(
                                  value: 'edit',
                                  title: 'edit'.tr,
                                  imagePath: AppAssets.editIcon,
                                ),
                                popUpMenuBtnView(
                                  value: 'view',
                                  title: 'viewSubmissions'.tr,
                                  imagePath: AppAssets.viewIcon,
                                ),
                              ],
                              child: AssetImageWidget(
                                imagePath: AppAssets.imagesIcMoreIcon,
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 40),
                      itemCount: controller.academyList.length,
                    ),
                    if (isLoadingMore)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(child: CupertinoActivityIndicator()),
                      ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  String formatStartEndDate({DateTime? startDate, DateTime? endDate}) {
    if (startDate == null && endDate == null) {
      return '00 - 00/00/0000';
    }

    final start = startDate != null ? _twoDigits(startDate.day) : '00';
    final end = endDate != null ? _formatDate(endDate) : '00/00/0000';

    return '$start - $end';
  }

  String formatTimeOrDateDisplay(AcademyContentViewModel academy) {
    if (academy.isZoomWorkshop) {
      final startTime = academy.zoomStartTime ?? '00:00';
      final endTime = academy.zoomEndTime ?? '00:00';
      return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
    }

    if (academy.isAssignment) {
      final endTime = academy.taskEndTime;
      if (endTime == null || endTime.isEmpty) {
        return '00:00';
      }
      return _formatTime(endTime);
    }

    return '00:00 - 00:00';
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '00:00';

    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(timeStr)) {
      return timeStr;
    }

    final match = RegExp(
      r'(\d+):(\d+)\s?(AM|PM)',
      caseSensitive: false,
    ).firstMatch(timeStr);
    if (match != null) {
      int hours = int.parse(match.group(1)!);
      final minutes = match.group(2)!;
      final period = match.group(3)!.toUpperCase();

      if (period == 'PM' && hours != 12) hours += 12;
      if (period == 'AM' && hours == 12) hours = 0;

      return '${hours.toString().padLeft(2, '0')}:$minutes';
    }

    if (RegExp(r'^\d{2}:\d{2}:\d{2}').hasMatch(timeStr)) {
      return timeStr.substring(0, 5);
    }

    return '00:00';
  }

  String _formatDate(DateTime date) {
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  PopupMenuItem<String> popUpMenuBtnView({
    required String value,
    required String title,
    required String imagePath,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        spacing: 8,
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
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
                color: Color.fromRGBO(242, 242, 242, 0.2),
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  offset: Offset(0, 3.57),
                  blurRadius: 7.97,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Image.asset(
              imagePath,
              width: 10,
              color: AppColors.white,
              height: 10,
              fit: BoxFit.fitHeight,
            ),
          ),
          Text(title, style: AppTextStyles.rubik12w400()),
        ],
      ),
    );
  }

  _openViewAllSubmissionsFlyout(
    AcademyContentViewModel academyContentViewModel,
  ) {
    showGeneralDialog(
      context: Get.context!,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: AssignmentSubmissionsList(
              academyContentViewModel: academyContentViewModel,
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }
}

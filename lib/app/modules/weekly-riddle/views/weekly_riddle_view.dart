import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import 'package:samsung_admin_main_new/app/common/common_button.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/search_text_field.dart';
import 'package:samsung_admin_main_new/app/common/widgets/sort_by_dropdown.dart';
import 'package:samsung_admin_main_new/app/models/weekly_riddle_model.dart';
import 'package:samsung_admin_main_new/app/modules/weekly-riddle/local_widget/create_edit_riddle.dart';
import 'package:samsung_admin_main_new/app/modules/weekly-riddle/local_widget/view_all_submissions.dart';
import '../../../common/widgets/common_widget.dart';
import '../controllers/weekly_riddle_controller.dart';

class WeeklyRiddleView extends GetView<WeeklyRiddleController> {
  const WeeklyRiddleView({super.key});

  Widget _voidSearchField() {
    return SearchTextField(
      hintText: 'search'.tr,
      // controller: controller.searchController,
      onChanged: (value) {
        // controller.resetPage();
        controller.fetchWeeklyRiddleList(searchTerm: value);
      },
    );
  }

  _openViewAllSubmissionsFlyout(
    BuildContext context,
    WeeklyRiddleModel riddleModel,
    WeeklyRiddleController controller,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: ViewAllSubmissions(
              riddleModel: riddleModel,
              controller: controller,
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

  _openFlyout(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Obx(
          () => PopScope(
            canPop: !controller.isCreateContentBtnValue.value,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: CreateEditRiddle(controller: controller),
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

  Widget _buildSortByDropdown() {
    return SortByDropdown(
      selectedValue: controller.selectedShortByValue,
      items: controller.shortByList,
      labelMap: controller.shortByLabelMap,
      onSelected: (value) {
        // controller.resetPage();
        // controller.searchController.clear();
        controller.fetchWeeklyRiddleList(shortBy: value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget headingText({String? title, Color? color}) {
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

    PopupMenuItem<String> popUpMenuBtnView({
      required String value,
      required String title,
      required String icon,
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
              child: AssetImageWidget(
                imagePath: icon,
                width: 10,
                height: 10,
                color: AppColors.white,
              ),
            ),
            Text(title, style: AppTextStyles.rubik12w400()),
          ],
        ),
      );
    }

    Widget weeklyRiddleList() {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Obx(() {
            final isLoadingMore = controller.isLoadingMore.value;
            return CommonWidget.isLoadingAndEmptyWidget(
              isLoadingValue:
                  controller.isLoading.value &&
                  controller.weeklyRiddleList.isEmpty,
              isEmpty:
                  controller.weeklyRiddleList.isEmpty &&
                  !controller.isLoading.value,
              emptyMsgText: 'noWeeklyRiddleFound'.tr,
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
                        spacing: 2,
                        children: [
                          headingText(
                            title: 'nameOfRiddle'.tr,
                            color: AppColors.greyColor,
                          ),
                          headingText(
                            title: 'typeOfPuzzle'.tr,
                            color: AppColors.greyColor,
                          ),
                          headingText(
                            title: 'creationDate'.tr,
                            color: AppColors.greyColor,
                          ),
                          headingText(
                            title: 'dates'.tr,
                            color: AppColors.greyColor,
                          ),
                          headingText(
                            title: 'endTime'.tr,
                            color: AppColors.greyColor,
                          ),
                          headingText(
                            title: 'amountOfPoints'.tr,
                            color: AppColors.greyColor,
                          ),
                          headingText(
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
                          final weeklyRiddle =
                              controller.weeklyRiddleList[index];
                          return Row(
                            spacing: 2,
                            children: [
                              headingText(title: weeklyRiddle.title),
                              headingText(
                                title: weeklyRiddle.solutionType.toString(),
                              ),
                              headingText(
                                title: DateFormat(
                                  'dd/MM/yyyy',
                                ).format(weeklyRiddle.createdAt),
                              ),
                              headingText(
                                title:
                                    '${DateFormat('dd').format(weeklyRiddle.startDate)} - ${DateFormat('dd/MM/yyyy').format(weeklyRiddle.endDate)}',
                              ),
                              headingText(
                                title: weeklyRiddle.endTime != null
                                    ? DateFormat(
                                        'HH:mm',
                                      ).format(weeklyRiddle.endTime!)
                                    : '-',
                              ),
                              headingText(
                                title: weeklyRiddle.pointsToEarn.toString(),
                              ),
                              headingText(
                                title: '${weeklyRiddle.totalParticipants}',
                              ),
                              PopupMenuButton<String>(
                                color: AppColors.darkGreyColor,
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    controller.isEditing.value = true;
                                    controller.prefillFormForEdit(weeklyRiddle);
                                    controller.clearError();
                                    _openFlyout(context);
                                  } else if (value == 'delete') {
                                    debugPrint('delete');
                                    controller.clickOnDeleteBtn(
                                      weeklyRiddle.id,
                                    );
                                  } else if (value == 'view') {
                                    debugPrint('view');
                                    controller.fetchWeeklyRiddleSubmissions(
                                      riddleId: weeklyRiddle.id,
                                    );
                                    _openViewAllSubmissionsFlyout(
                                      context,
                                      weeklyRiddle,
                                      controller,
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  popUpMenuBtnView(
                                    value: 'delete',
                                    title: 'delete'.tr,
                                    icon: AppAssets.trashIcon,
                                  ),
                                  popUpMenuBtnView(
                                    value: 'edit',
                                    title: 'edit'.tr,
                                    icon: AppAssets.editIcon,
                                  ),
                                  popUpMenuBtnView(
                                    value: 'view',
                                    title: 'viewSubmissions'.tr,
                                    icon: AppAssets.viewIcon,
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
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 40);
                        },
                        itemCount: controller.weeklyRiddleList.length,
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

    return CommonWidget.commonCardView(
      title: 'weeklyRiddle'.tr,
      subTitle: 'systemActivity'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 500, child: _voidSearchField()),
                    GetBuilder<WeeklyRiddleController>(
                      builder: (controller) {
                        return _buildSortByDropdown();
                      },
                    ),
                    Obx(() {
                      if (controller.shouldOpenFlyout.value) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (controller.shouldOpenFlyout.value) {
                            _openFlyout(context);
                            controller.shouldOpenFlyout.value = false;
                          }
                        });
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
                SizedBox(
                  width: 200,
                  child: CommonButton(
                    text: '+   ${'newUpload'.tr}',
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    onTap: () {
                      controller.clearAllFields();
                      controller.clearError();
                      _openFlyout(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          weeklyRiddleList(),
        ],
      ),
    );
  }
}

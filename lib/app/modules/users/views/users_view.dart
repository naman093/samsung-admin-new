import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/gradient_text_field.dart';
import 'package:samsung_admin_main_new/app/common/widgets/filter_dropdown.dart';
import 'package:samsung_admin_main_new/app/common/widgets/search_text_field.dart';
import 'package:samsung_admin_main_new/app/common/widgets/sort_by_dropdown.dart';
import '../../../app_theme/app_colors.dart';
import '../../../app_theme/textstyles.dart';
import 'dart:math' as math;
import '../../../common/common_button.dart';
import '../../../common/common_flyout.dart';
import '../../../common/constant/app_assets.dart';
import '../../../common/widgets/asset_image_widget.dart';
import '../../../common/widgets/network_image_widget.dart';
import '../../../models/user_model.dart';
import '../controllers/users_controller.dart';
import '../local_widget/action_card_painter.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});
  @override
  Widget build(BuildContext context) {
    return CommonWidget.commonCardView(
      title: 'users'.tr,
      subTitle: 'systemActivity'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 260, child: _voidSearchField()),
                GetBuilder<UsersController>(
                  builder: (controller) {
                    return Row(
                      spacing: 16,
                      children: [
                        _buildSortByDropdown(controller),
                        _buildStatusFilterDropdown(controller),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          _usersListView(),
        ],
      ),
    );
  }

  _headingText({String? title, Color? color}) {
    return Expanded(
      child: Text(
        title ?? "",
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.rubik14w400().copyWith(
          color: color ?? Colors.white,
        ),
      ),
    );
  }

  _modelType({String? modelType}) {
    if (modelType == null) {
      return Text(
        'N/A',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.rubik14w400().copyWith(color: AppColors.greyColor),
      );
    }
    return Container(
      margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.greyColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        modelType
            .split('_')
            .map(
              (str) => str.isNotEmpty
                  ? str[0].toUpperCase() + str.substring(1)
                  : str,
            )
            .join(' '),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.rubik14w400().copyWith(color: AppColors.greyColor),
      ),
    );
  }

  _statusView({String? status, bool isExpanded = true}) {
    if (isExpanded) {
      return Expanded(
        child: Align(
          alignment: Alignment.center,
          widthFactor: 0,
          child: Container(
            margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'awaitingApproval'.tr
                  ? AppColors.yellowColor.withValues(alpha: 0.10)
                  : status == 'happiness'.tr
                  ? AppColors.greenColor.withValues(alpha: 0.10)
                  : AppColors.redColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              status ?? "",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.rubik12w400().copyWith(
                color: status == 'awaitingApproval'.tr
                    ? AppColors.yellowColor
                    : status == 'happiness'.tr
                    ? AppColors.greenColor
                    : AppColors.redColor,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: status == 'awaitingApproval'.tr
              ? AppColors.yellowColor.withValues(alpha: 0.10)
              : status == 'happiness'.tr
              ? AppColors.greenColor.withValues(alpha: 0.10)
              : AppColors.redColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          status ?? "",
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.rubik12w400().copyWith(
            color: status == 'awaitingApproval'.tr
                ? AppColors.yellowColor
                : status == 'happiness'.tr
                ? AppColors.greenColor
                : AppColors.redColor,
          ),
        ),
      );
    }
  }

  Widget _usersListView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          final isLoadingMore = controller.isLoadingMore.value;
          return CommonWidget.isLoadingAndEmptyWidget(
            isLoadingValue:
                controller.isLoading.value && controller.users.isEmpty,
            emptyMsgText: 'noData'.tr,
            isEmpty: controller.users.isEmpty && !controller.isLoading.value,
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
                          title: 'userName'.tr,
                          color: AppColors.greyColor,
                        ),
                        _headingText(
                          title: 'dateOfBirth'.tr,
                          color: AppColors.greyColor,
                        ),
                        _headingText(
                          title: 'userGender'.tr,
                          color: AppColors.greyColor,
                        ),
                        _headingText(
                          title: 'userCity'.tr,
                          color: AppColors.greyColor,
                        ),
                        _headingText(
                          title: 'userPoints'.tr,
                          color: AppColors.greyColor,
                        ),
                        _headingText(
                          title: 'userSocialLink'.tr,
                          color: AppColors.greyColor,
                        ),
                        _headingText(
                          title: 'userStatus'.tr,
                          color: AppColors.greyColor,
                        ),
                        Container(width: 30, height: 30),
                      ],
                    ).marginOnly(top: 50),
                    Divider(
                      color: AppColors.dashboardContainerBorder,
                      height: 30,
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final user = controller.users[index];
                        return _buildUserRow(context, user);
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 40);
                      },
                      itemCount: controller.users.length,
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

  Widget _buildUserRow(BuildContext context, UserModel user) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              user.profilePictureUrl != null &&
                      user.profilePictureUrl!.isNotEmpty
                  ? NetworkImageWidget(
                      imageUrl: user.profilePictureUrl!,
                      height: 24,
                      width: 24,
                      radius: 14,
                    )
                  : Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(214, 214, 214, 0.2),
                            Color.fromRGBO(112, 112, 112, 0.2),
                          ],
                        ),
                        border: Border.all(
                          width: 1.1,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            offset: Offset(0, 8.15),
                            blurRadius: 18.21,
                          ),
                          BoxShadow(
                            color: Color(0x17000000),
                            offset: Offset(0, 33.07),
                            blurRadius: 33.07,
                          ),
                          BoxShadow(
                            color: Color(0x0D000000),
                            offset: Offset(0, 74.76),
                            blurRadius: 45.05,
                          ),
                          BoxShadow(
                            color: Color(0x03000000),
                            offset: Offset(0, 132.74),
                            blurRadius: 53.19,
                          ),
                          BoxShadow(
                            color: Color(0x00000000),
                            offset: Offset(0, 207.50),
                            blurRadius: 57.99,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person_outline,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
              Flexible(
                child: Text(
                  user.fullName ?? user.phoneNumber,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.rubik14w400().copyWith(
                    color: Colors.white,
                  ),
                ).marginOnly(left: 8),
              ),
            ],
          ),
        ),
        _headingText(title: controller.formatDOB(user.birthday)),
        _headingText(title: controller.getGenderDisplayText(user.gender)),
        _headingText(title: user.city ?? '-'),
        _headingText(title: user.pointsBalance.toString()),
        _headingText(
          title: controller.getSocialMediaLink(user.socialMediaLinks),
        ),
        _statusView(status: controller.getStatusDisplayText(user.status)),
        _buildUserMenu(context, user),
      ],
    );
  }

  Widget _buildUserMenu(BuildContext context, UserModel user) {
    final currentUserId = controller.authController.currentUser.value?.id ?? '';

    return PopupMenuButton<String>(
      color: AppColors.darkGreyColor,
      onSelected: (value) {
        if (value == 'view') {
          controller.selectUser(user);
          _openFlyout(context, user);
        } else if (value == 'confirm') {
          controller.confirmUser(user.id, currentUserId);
        } else if (value == 'reject') {
          controller.rejectUser(user.id, currentUserId);
        } else if (value == 'block') {
          controller.blockUser(user.id, currentUserId);
        } else if (value == 'unblock') {
          controller.unblockUser(user.id);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, user);
        }
      },
      itemBuilder: (context) {
        // Build menu items dynamically based on user status
        List<PopupMenuEntry<String>> menuItems = [
          // View Profile - always available
          PopupMenuItem(
            value: 'view',
            child: Row(
              spacing: 8,
              children: [
                Icon(Icons.visibility, color: Colors.white, size: 20),
                Text('viewProfile'.tr, style: AppTextStyles.rubik12w400()),
              ],
            ),
          ),
        ];

        // Status-specific actions
        if (user.status == UserStatus.pending) {
          // Pending users: show Confirm and Reject
          menuItems.addAll([
            PopupMenuItem(
              value: 'confirm',
              child: Row(
                spacing: 8,
                children: [
                  AssetImageWidget(
                    imagePath: AppAssets.userTickIcon,
                    color: AppColors.greenColor,
                    width: 20,
                    height: 20,
                  ),
                  Text(
                    'userConfirmation'.tr,
                    style: AppTextStyles.rubik12w400(),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'reject',
              child: Row(
                spacing: 8,
                children: [
                  AssetImageWidget(
                    imagePath: AppAssets.userCrossIcon,
                    width: 18,
                    height: 18,
                  ),
                  Text('userRejection'.tr, style: AppTextStyles.rubik12w400()),
                ],
              ),
            ),
          ]);
        } else if (user.status == UserStatus.rejected) {
          // Rejected users: show Re-approve option
          menuItems.add(
            PopupMenuItem(
              value: 'confirm',
              child: Row(
                spacing: 8,
                children: [
                  AssetImageWidget(
                    imagePath: AppAssets.userTickIcon,
                    width: 20,
                    height: 20,
                    color: AppColors.greenColor,
                  ),
                  Text('reapproveUser'.tr, style: AppTextStyles.rubik12w400()),
                ],
              ),
            ),
          );
        } else if (user.status == UserStatus.approved) {
          // Approved users: show Block option
          menuItems.add(
            PopupMenuItem(
              value: 'block',
              child: Row(
                spacing: 8,
                children: [
                  AssetImageWidget(
                    imagePath: AppAssets.imagesIcBlockUser,
                    width: 20,
                    height: 20,
                  ),
                  Text(
                    'userBlockingAUser'.tr,
                    style: AppTextStyles.rubik12w400(),
                  ),
                ],
              ),
            ),
          );
        } else if (user.status == UserStatus.suspended) {
          // Suspended users: show Unblock option
          menuItems.add(
            PopupMenuItem(
              value: 'unblock',
              child: Row(
                spacing: 8,
                children: [
                  AssetImageWidget(
                    imagePath: AppAssets.imagesIcBlockUserUnfilled,
                    width: 20,
                    height: 20,
                  ),
                  Text('unblockUser'.tr, style: AppTextStyles.rubik12w400()),
                ],
              ),
            ),
          );
        }

        menuItems.add(
          PopupMenuItem(
            value: 'delete',
            child: Row(
              spacing: 8,
              children: [
                AssetImageWidget(
                  imagePath: AppAssets.trashIcon,
                  color: AppColors.white,
                  width: 20,
                  height: 20,
                ),
                Text('delete'.tr, style: AppTextStyles.rubik12w400()),
              ],
            ),
          ),
        );

        return menuItems;
      },
      child: AssetImageWidget(
        imagePath: AppAssets.imagesIcMoreIcon,
        width: 30,
        height: 30,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserModel user) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkGreyColor,
        title: Text('delete'.tr, style: TextStyle(color: Colors.white)),
        content: Text(
          '${'deleteConfirmation'.tr} ${user.fullName ?? user.phoneNumber}?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteUser(user.id);
            },
            child: Text(
              'delete'.tr,
              style: TextStyle(color: AppColors.redColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPointsDialog(String userId) {
    showGeneralDialog(
      context: Get.context!,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Obx(
          () => PopScope(
            canPop: !controller.isLoading.value,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: CommonFlyout(
                  icon: Transform.rotate(
                    angle: math.pi,
                    child: AssetImageWidget(
                      imagePath: AppAssets.rightArrow2,
                      width: 18,
                      height: 18,
                    ),
                  ),
                  title: 'userAddingPoints'.tr,
                  description:
                      'selectTheAmountOfPointsYouWouldLikeToSendToMaiBozo'.tr,
                  onClose: () => Navigator.of(context).pop(),
                  canDismiss: () => !controller.isLoading.value,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: SizedBox(
                        width: 500,
                        child: Obx(() {
                          return Column(
                            children: [
                              GradientTextField(
                                labelText: 'numberOfPoints'.tr,
                                hintText: 'typeHere'.tr,
                                controller: controller.numberOfPoints,
                                errorText: controller.pointError.value,
                                keyboardType: TextInputType.number,
                                readOnly: controller.isLoading.value,
                              ),
                              const SizedBox(height: 50),
                              Row(
                                children: [
                                  Expanded(
                                    child: CommonButton(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 16,
                                      ),
                                      text: 'send'.tr,
                                      isLoading: controller.isLoading.value,
                                      isEnabled: !controller.isLoading.value,
                                      onTap: controller.isLoading.value
                                          ? null
                                          : () {
                                              controller.pointError.value = '';
                                              controller.addPoints(userId);
                                            },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: CommonButton(
                                      bgColor: AppColors.transparentColor,
                                      borderColor: AppColors.redColor2,
                                      textColor: AppColors.redColor2,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 16,
                                      ),
                                      text: 'cancel'.tr,
                                      isEnabled: !controller.isLoading.value,
                                      onTap: controller.isLoading.value
                                          ? null
                                          : () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
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

  Widget _userDetailCont({required String iconPath, required String title}) {
    return Row(
      spacing: 5,
      children: [
        Image.asset(iconPath, width: 16, height: 16),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.userDetailIconColor,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'samsungsharpsans',
          ),
        ),
      ],
    );
  }

  Widget _tasksDetailCont() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Text(
            'tasks'.tr,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w400,
              fontFamily: 'samsungsharpsans',
            ),
          ),
          Obx(() {
            if (controller.isLoadingTaskSubmissions.value) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.white),
              );
            }

            if (controller.totalSubmissions.value == 0) {
              return Text(
                'noTasksSubmittedYet'.tr,
                style: const TextStyle(
                  color: AppColors.userDetailIconColor,
                  fontSize: 14,
                  fontFamily: 'samsungsharpsans',
                ),
              );
            }

            return Column(
              spacing: 20,
              children: [
                // Assignment submissions
                ...controller.assignmentSubmissions.map((submission) {
                  return _taskCard(
                    type: 'Assignment',
                    totalPoints:
                        submission['assignments']?['total_points_to_win']
                            ?.toString(),
                    riddleId: null,
                    createdAt: submission['created_at']?.toString(),
                    submission: submission,
                  );
                }).toList(),
                // Riddle submissions
                ...controller.riddleSubmissions.map((submission) {
                  return _taskCard(
                    type: 'Riddle',
                    totalPoints: submission['weekly_riddles']?['points_to_earn']
                        ?.toString(),
                    riddleId: submission['riddle_id']?.toString(),
                    createdAt: submission['submitted_at']?.toString(),
                    submission: submission,
                  );
                }).toList(),
              ],
            );
          }),
        ],
      ),
    );
  }

  _detailItemCol({required String title, required String value}) {
    return Column(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(
            color: AppColors.userDetailIconColor,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'samsungsharpsans',
          ),
        ),
      ],
    );
  }

  _detailItem({
    required String title,
    required String value,
    required Widget? widget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), widget ?? Text(value)],
    );
  }

  Widget _accountDetailCont(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Text(
            'accountDetails'.tr,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w400,
              fontFamily: 'samsungsharpsans',
            ),
          ),
          _detailItem(
            title: 'accountStatus'.tr,
            value: controller.getStatusDisplayText(user.status),
            widget: _statusView(
              status: controller.getStatusDisplayText(user.status),
              isExpanded: false,
            ),
          ),
          _detailItem(
            title: 'phoneModelType'.tr,
            value: user.deviceModel ?? '-',
            widget: _modelType(modelType: user.deviceModel),
          ),
          _detailItem(
            title: 'profession'.tr,
            value: user.profession ?? '-',
            widget: null,
          ),
          _detailItem(
            title: 'mobileNumber'.tr,
            value: user.phoneNumber,
            widget: null,
          ),
          if (user.bio != null && user.bio!.isNotEmpty)
            _detailItemCol(title: 'bio'.tr, value: user.bio!),
        ],
      ),
    );
  }

  Widget _actionCard({required String title, required String value}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: const Alignment(0, -0.4925),
          end: const Alignment(0, 1.2388),
          colors: [
            const Color(0xFFD6D6D6).withValues(alpha: 0.1),
            const Color(0xFF707070).withValues(alpha: 0.1),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000), // 0px 4.38px 9.79px 0px #0000001A
            offset: Offset(0, 4.38),
            blurRadius: 9.79,
          ),
          BoxShadow(
            color: Color(0x17000000), // 0px 17.78px 17.78px 0px #00000017
            offset: Offset(0, 17.78),
            blurRadius: 17.78,
          ),
          BoxShadow(
            color: Color(0x0D000000), // 0px 40.19px 24.22px 0px #0000000D
            offset: Offset(0, 40.19),
            blurRadius: 24.22,
          ),
          BoxShadow(
            color: Color(0x03000000), // 0px 71.36px 28.6px 0px #00000003
            offset: Offset(0, 71.36),
            blurRadius: 28.6,
          ),
          BoxShadow(
            color: Color(0x00000000), // 0px 111.56px 31.17px 0px #00000000
            offset: Offset(0, 111.56),
            blurRadius: 31.17,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.64, sigmaY: 4.64),
          child: CustomPaint(
            painter: ActionCardPainter(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.userDetailIconColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'samsungsharpsans',
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'samsungsharpsans',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionsCont(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Text(
            'action'.tr,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w400,
              fontFamily: 'samsungsharpsans',
            ),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                Expanded(
                  child: Obx(
                    () => _actionCard(
                      title: 'totalPoints'.tr,
                      value:
                          (controller.selectedUser.value?.id == user.id
                                  ? controller.selectedUser.value?.pointsBalance
                                  : user.pointsBalance)
                              ?.toString() ??
                          '0',
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => _actionCard(
                      title: 'zoomParticipation'.tr,
                      value: controller.isLoadingActivityStats.value
                          ? '...'
                          : controller.zoomParticipations.value.toString(),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => _actionCard(
                      title: 'watchingVideos'.tr,
                      value: controller.isLoadingActivityStats.value
                          ? '...'
                          : controller.watchingVideos.value.toString(),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => _actionCard(
                      title: 'academicTasks'.tr,
                      value: controller.isLoadingActivityStats.value
                          ? '...'
                          : controller.academicTasks.value.toString(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard({
    required String type,
    String? totalPoints,
    String? riddleId,
    String? createdAt,
    Map<String, dynamic>? submission,
  }) {
    // Format submitted date
    String formattedDate = '-';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (e) {
        formattedDate = createdAt;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AssetImageWidget(
              imagePath: AppAssets.taskIcon,
              height: 39,
              width: 53,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'samsungsharpsans',
                  ),
                ),
                Text(
                  '${'createdAt'.tr}: $formattedDate',
                  style: const TextStyle(
                    color: AppColors.userDetailIconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'samsungsharpsans',
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          spacing: 26,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'totalPoints'.tr,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'samsungsharpsans',
                  ),
                ),
                Text(
                  totalPoints ?? '',
                  style: const TextStyle(
                    color: AppColors.userDetailIconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'samsungsharpsans',
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: submission != null
                  ? () =>
                        controller.showSubmissionPreviewDialog(submission, type)
                  : null,
              child: RotatedBox(
                quarterTurns: 2, // 180°
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.63, sigmaY: 8.63),
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: 9,
                        bottom: 9,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(214, 214, 214, 0.2),
                            Color.fromRGBO(112, 112, 112, 0.2),
                          ],
                          stops: [-0.49, 1.23],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          width: 1.1,
                          color: Colors.white.withOpacity(0.2),
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
                          // inset-like shadow approximation
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
          ],
        ),
      ],
    );
  }

  Widget _userDetailCard(UserModel user) {
    final currentUserId = controller.authController.currentUser.value?.id ?? '';

    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
      child: Column(
        spacing: 24,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User profile image
              user.profilePictureUrl != null &&
                      user.profilePictureUrl!.isNotEmpty
                  ? NetworkImageWidget(
                      imageUrl: user.profilePictureUrl!,
                      height: 130,
                      width: 130,
                      radius: 10,
                    )
                  : AssetImageWidget(
                      imagePath: AppAssets.sidebarUser,
                      height: 130,
                      width: 130,
                      radius: 10,
                    ),
              Expanded(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? user.phoneNumber,
                      style: const TextStyle(
                        fontFamily: 'samsungsharpsans',
                        fontWeight: FontWeight.w400,
                        fontSize: 24,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      controller.getSocialMediaLink(user.socialMediaLinks),
                      style: const TextStyle(
                        fontFamily: 'samsungsharpsans',
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        height: 22 / 14,
                        letterSpacing: 0,
                        color: AppColors.userDetailIconColor,
                      ),
                    ),
                    Row(
                      spacing: 30,
                      children: [
                        _userDetailCont(
                          iconPath: AppAssets.flashIcon,
                          title:
                              '${'gender'.tr}: ${controller.getGenderDisplayText(user.gender)}',
                        ),
                        _userDetailCont(
                          iconPath: AppAssets.locationIcon,
                          title: '${'residence'.tr}: ${user.city ?? '-'}',
                        ),
                        _userDetailCont(
                          iconPath: AppAssets.calendarIcon,
                          title:
                              '${'dob'.tr}: ${controller.formatDOB(user.birthday)}',
                        ),
                      ],
                    ),
                    Row(
                      spacing: 20,
                      children: [
                        if (user.status == UserStatus.pending) ...[
                          SizedBox(
                            width: 200,
                            child: CommonButton(
                              text: 'userConfirmation'.tr,
                              icon: AppAssets.userTickIcon,
                              iconColor: AppColors.greenColor,
                              onTap: () {
                                controller.confirmUser(user.id, currentUserId);
                                Get.back();
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: CommonButton(
                              text: 'userRejection'.tr,
                              icon: AppAssets.userCrossIcon,
                              onTap: () {
                                controller.rejectUser(user.id, currentUserId);
                                Get.back();
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                            ),
                          ),
                        ] else if (user.status == UserStatus.rejected)
                          SizedBox(
                            width: 180,
                            child: CommonButton(
                              text: 'reapproveUser'.tr,
                              icon: AppAssets.userTickIcon,
                              iconColor: AppColors.greenColor,
                              onTap: () {
                                controller.confirmUser(user.id, currentUserId);
                                Get.back();
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                            ),
                          )
                        else if (user.status == UserStatus.approved) ...[
                          SizedBox(
                            width: 180,
                            child: CommonButton(
                              text: 'userBlockingAUser'.tr,
                              icon: AppAssets.imagesIcBlockUserUnfilled,
                              onTap: () {
                                controller.blockUser(user.id, currentUserId);
                                Get.back();
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: CommonButton(
                              text: 'userAddingPoints'.tr,
                              icon: AppAssets.pointStoreIcon,
                              onTap: () {
                                _showAddPointsDialog(user.id);
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                            ),
                          ),
                        ] else if (user.status == UserStatus.suspended)
                          SizedBox(
                            width: 180,
                            child: CommonButton(
                              text: 'unblockUser'.tr,
                              icon: AppAssets.imagesIcBlockUserUnfilled,
                              onTap: () {
                                controller.unblockUser(user.id);
                                Get.back();
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          _accountDetailCont(user),
          _actionsCont(user),
          _tasksDetailCont(),
        ],
      ),
    );
  }

  void _openFlyout(BuildContext context, UserModel user) {
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
            child: CommonFlyout(
              title: 'viewProfile'.tr,
              onClose: () => Navigator.of(context).pop(),
              children: [_userDetailCard(user)],
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

  _voidSearchField() {
    return SearchTextField(
      hintText: 'search'.tr,
      onChanged: (value) {
        controller.searchUsers(value);
      },
    );
  }

  Widget _buildSortByDropdown(UsersController controller) {
    return SortByDropdown(
      selectedValue: controller.sortBy,
      items: controller.shortByList,
      labelMap: controller.shortByLabelMap,
      onSelected: (value) {
        controller.changeSortBy(value);
      },
    );
  }

  Widget _buildStatusFilterDropdown(UsersController controller) {
    return FilterDropdown(
      hint: 'filterBy'.tr,
      selectedValue: controller.statusFilter,
      items: controller.statusList,
      labelMap: controller.statusLabelMap,
      onSelected: (value) {
        controller.changeStatusFilter(value);
      },
    );
  }
}

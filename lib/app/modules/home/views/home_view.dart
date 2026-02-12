import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/network_image_widget.dart';
import 'package:samsung_admin_main_new/app/models/user_model.dart';
import 'package:samsung_admin_main_new/app/modules/home/local_widget/dashboard_bar_chart.dart';
import 'package:samsung_admin_main_new/app/routes/app_pages.dart';
import 'package:samsung_admin_main_new/app/common/widgets/dashboard_table.dart';

import '../controllers/home_controller.dart';
import '../local_widget/dashboard_stat_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return CommonWidget.commonCardView(
      title: '${'goodAfternoon'.tr}, ${'may'.tr}',
      subTitle: 'systemActivity'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              double maxWidth = constraints.maxWidth;
              double itemWidth = maxWidth > 1100
                  ? maxWidth / 4 - 16
                  : maxWidth > 800
                  ? maxWidth / 3 - 16
                  : maxWidth > 360
                  ? maxWidth / 2 - 16
                  : maxWidth;
              return Obx(() {
                final counts = controller.dashboardCounts.value;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _statCard(
                      itemWidth,
                      'totalLessons'.tr,
                      counts?.lessons ?? 0,
                      AppAssets.lessonDashboardStat,
                    ),
                    _statCard(
                      itemWidth,
                      'totalTasks'.tr,
                      counts?.tasks ?? 0,
                      AppAssets.sidebarAcademy,
                    ),
                    _statCard(
                      itemWidth,
                      'totalEvents'.tr,
                      counts?.events ?? 0,
                      AppAssets.eventDashboardStat,
                    ),
                    _statCard(
                      itemWidth,
                      'totalUsers'.tr,
                      counts?.users ?? 0,
                      AppAssets.multiUserDashboard,
                    ),
                  ],
                );
              });
            },
          ),
          SizedBox(height: 24),
          SizedBox(height: 420, child: DashboardBarChart()),
          _usersListView(),
          SizedBox(height: 26),
        ],
      ),
    );
  }

  Widget _statCard(double width, String label, int count, String icon) {
    return SizedBox(
      width: width,
      child: DashboardStatCard(label: label, count: count, iconAsset: icon),
    );
  }

  _usersListView() {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final displayUsers = controller.filteredUsers.toList();

      return DashboardTable(
        title: 'newUsers'.tr,
        subtitle: 'newUsersDescription'.tr,
        actionLabel: 'viewAllUsers'.tr,
        onActionTap: () => Get.toNamed(Routes.USERS),
        headerCells: [
          _headingText(title: 'userName'.tr, color: AppColors.greyColor),
          _headingText(
            title: 'registrationDate'.tr,
            color: AppColors.greyColor,
          ),
          _headingText(title: 'gender'.tr, color: AppColors.greyColor),
          _headingText(title: 'city'.tr, color: AppColors.greyColor),
          _headingText(title: 'points'.tr, color: AppColors.greyColor),
          _headingText(title: 'socialLink'.tr, color: AppColors.greyColor),
          _headingText(title: 'status'.tr, color: AppColors.greyColor),
          SizedBox(width: 30, height: 30),
        ],
        isLoading: isLoading,
        itemCount: displayUsers.length,
        maxVisibleItems: 7,
        itemBuilder: (context, index) {
          final user = displayUsers[index];
          return _buildUserRow(context, user);
        },
        emptyWidget: Center(
          child: Text(
            'noData'.tr,
            style: AppTextStyles.rubik14w400().copyWith(
              color: AppColors.greyColor,
            ),
          ),
        ),
        margin: const EdgeInsets.only(top: 24),
      );
    });
  }

  Widget _buildUserRow(BuildContext context, UserModel user) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
        _headingText(title: DateFormat("dd/MM/yyyy").format(user.createdAt)),
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
        if (value == 'confirm') {
          controller.confirmUser(user.id, currentUserId);
        } else if (value == 'reject') {
          controller.rejectUser(user.id, currentUserId);
        } else if (value == 'block') {
          controller.blockUser(user.id, currentUserId);
        } else if (value == 'unblock') {
          controller.unblockUser(user.id);
        }
      },
      itemBuilder: (context) {
        // Build menu items dynamically based on user status
        List<PopupMenuEntry<String>> menuItems = [];

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
                    imagePath: AppAssets.imagesIcConfirmUser,
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
                    imagePath: AppAssets.imagesIcRejectUser,
                    width: 20,
                    height: 20,
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
                    imagePath: AppAssets.imagesIcConfirmUser,
                    width: 20,
                    height: 20,
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

        return menuItems;
      },
      child: AssetImageWidget(
        imagePath: AppAssets.imagesIcMoreIcon,
        width: 30,
        height: 30,
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

  _statusView({String? status}) {
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
  }
}

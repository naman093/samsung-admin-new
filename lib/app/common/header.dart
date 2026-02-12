import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import 'package:samsung_admin_main_new/app/common/common_button.dart';
import 'package:samsung_admin_main_new/app/common/common_flyout.dart';
import 'package:samsung_admin_main_new/app/common/common_modal.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/services/user_service.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import 'package:samsung_admin_main_new/app/models/notification_model.dart';
import 'package:samsung_admin_main_new/app/repository/auth_repo/auth_repo.dart';

import '../controllers/header_controller.dart';
import '../localization/language_controller.dart';
import '../routes/app_pages.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key});
  static String getButtonTextForNotificationType(NotificationType type) {
    switch (type) {
      case NotificationType.riddleNew:
        return 'View Riddle';
      case NotificationType.zoomStarting:
        return 'Join Zoom';
      case NotificationType.eventReminder:
        return 'View Event';
      case NotificationType.orderUpdate:
        return 'viewOrders'.tr;
      case NotificationType.follow:
        return 'viewProfile'.tr;
      case NotificationType.comment:
        return 'View Comment';
      case NotificationType.like:
        return 'View Post';
      case NotificationType.pointsEarned:
        return 'View Points';
      case NotificationType.welcome:
        return 'continue'.tr;
      case NotificationType.riddleSubmissionCreated:
        return 'viewSubmissions'.tr;
      case NotificationType.riddleSubmissionResult:
        return 'viewSubmissions'.tr;
    }
  }

  static String getButtonIconForNotificationType(NotificationType type) {
    switch (type) {
      case NotificationType.riddleNew:
        return AppAssets.sidebarWeeklyRiddle;
      case NotificationType.zoomStarting:
        return AppAssets.imagesIcPlay;
      case NotificationType.eventReminder:
        return AppAssets.calendarIcon;
      case NotificationType.orderUpdate:
        return AppAssets.creditIcon;
      case NotificationType.follow:
        return AppAssets.verifiedProfileIcon;
      case NotificationType.comment:
        return AppAssets.commentIcon;
      case NotificationType.like:
        return AppAssets.userTickIcon;
      case NotificationType.pointsEarned:
        return AppAssets.pointStoreIcon;
      case NotificationType.welcome:
        return AppAssets.rightArrow;
      case NotificationType.riddleSubmissionCreated:
        return AppAssets.taskIcon;
      case NotificationType.riddleSubmissionResult:
        return AppAssets.checkIc;
    }
  }

  static VoidCallback? getNavigationHandlerForNotificationType(
    NotificationType type,
    BuildContext context,
  ) {
    return () {
      // Close the notification flyout
      Navigator.of(context).pop();

      // Navigate to the appropriate screen based on notification type
      switch (type) {
        case NotificationType.riddleNew:
        case NotificationType.riddleSubmissionCreated:
        case NotificationType.riddleSubmissionResult:
          Get.offAllNamed(Routes.WEEKLY_RIDDLE);
          break;
        case NotificationType.zoomStarting:
          Get.offAllNamed(Routes.ACADEMY);
          break;
        case NotificationType.eventReminder:
          Get.offAllNamed(Routes.EVENTS);
          break;
        case NotificationType.orderUpdate:
          Get.offAllNamed(Routes.PRODUCT_ORDERS);
          break;
        case NotificationType.follow:
          Get.offAllNamed(Routes.USERS);
          break;
        case NotificationType.comment:
        case NotificationType.like:
          Get.offAllNamed(Routes.COMMUNITY);
          break;
        case NotificationType.pointsEarned:
          Get.offAllNamed(Routes.POINT_STORE);
          break;
        case NotificationType.welcome:
          // No navigation for welcome notification
          break;
      }
    };
  }

  Widget _alertCard({
    required String title,
    required String date,
    required NotificationType notificationType,
    VoidCallback? onButtonTap,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AvatarCircle(),
                Column(
                  spacing: 7,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.rubik16w400().copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      date,
                      style: AppTextStyles.rubik14w400().copyWith(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (notificationType != NotificationType.welcome)
              SizedBox(
                width: 180,
                child: CommonButton(
                  text: getButtonTextForNotificationType(notificationType),
                  onTap: onButtonTap ?? () {},
                  icon: getButtonIconForNotificationType(notificationType),
                  borderRadius: 100,
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _blockedUsersCard({
    required String title,
    required String date,
    String? profileUrl,
    Widget? onButton,
    VoidCallback? onTapEditProfile,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AvatarCircle(
                profileUrl: profileUrl,
                onTapEditProfile: onTapEditProfile,
                isProfileClicked: false,
              ),
              Column(
                spacing: 7,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.rubik16w400().copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    date,
                    style: AppTextStyles.rubik14w400().copyWith(
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (onButton != null) onButton,
        ],
      ),
    );
  }

  void _openSettingsModal(BuildContext context) {
    if (!Get.isRegistered<UserService>()) {
      Get.put(UserService());
    }
    showCommonModal(
      context,
      title: 'blockedUsers'.tr,
      description: 'whenAUserIsBlocked'.tr,
      width: 700,
      barrierDismissible: false,
      child: GetBuilder(
        init: CommonHeaderController(),
        builder: (CommonHeaderController controller) {
          return Obx(() {
            return CommonWidget.isLoadingAndEmptyWidget(
              isLoadingValue: controller.isLoading.value,
              isEmpty: controller.blockedUser.isEmpty,
              widget: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...controller.blockedUser.map(
                      (record) => _blockedUsersCard(
                        title: record.fullName ?? '-',
                        date: DateFormat(
                          'MMM d, yyyy',
                        ).format(record.updatedAt),
                        profileUrl: record.profilePictureUrl,
                        onButton: SizedBox(
                          width: 180,
                          child: CommonButton(
                            text: 'unblock'.tr,
                            isEnabled: !controller.isUnblockBtnLoading.value,
                            onTap: controller.isUnblockBtnLoading.value
                                ? () {}
                                : () => controller.clickOnUnblockUserBtn(
                                    record.id,
                                  ),
                            borderRadius: 100,
                          ),
                        ),
                        onTapEditProfile: () =>
                            controller.clickOnEditProfileBtn(record),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  void _openNotificationsFlyout(BuildContext context) {
    final authRepo = Get.find<AuthRepo>();
    final currentUserId = authRepo.currentUser.value?.id;

    if (currentUserId == null) {
      return;
    }

    if (!Get.isRegistered<CommonHeaderController>()) {
      Get.put(CommonHeaderController());
    }
    final controller = Get.find<CommonHeaderController>();

    // Fetch notifications before opening the flyout
    controller.fetchNotifications(userId: currentUserId, limit: 20);

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
              title: 'alerts'.tr,
              onClose: () => Navigator.of(context).pop(),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Obx(() {
                    if (controller.isLoadingNotifications.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.notifications.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'No notifications',
                            style: AppTextStyles.rubik16w400().copyWith(
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        ...controller.notifications.map(
                          (notification) => _alertCard(
                            title: notification.title,
                            date: DateFormat(
                              'MMM d, yyyy',
                            ).format(notification.createdAt),
                            notificationType: notification.notificationType,
                            onButtonTap:
                                getNavigationHandlerForNotificationType(
                                  notification.notificationType,
                                  context,
                                ),
                            onTap: () {
                              if (!notification.isRead) {
                                controller.markNotificationAsRead(
                                  notification.id,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(flex: 2, child: _SearchField()),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SizedBox(width: 16),
                Spacer(),
                GlassCircle(
                  icon: Icons.chat,
                  onTap: () {
                    _openNotificationsFlyout(context);
                  },
                ),
                SizedBox(width: 8),
                GlassCircle(
                  icon: Icons.notifications_none_outlined,
                  onTap: () {
                    _openNotificationsFlyout(context);
                  },
                ),
                SizedBox(width: 8),
                GlassCircle(
                  icon: Icons.settings_outlined,
                  onTap: () => _openSettingsModal(context),
                ),
                SizedBox(width: 8),
                _LanguageBadge(),
                SizedBox(width: 8),
                _AvatarCircle(
                  onTapEditProfile: () {
                    Get.offAllNamed(Routes.EDIT_PROFILE);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageBadge extends StatelessWidget {
  const _LanguageBadge();

  static const double _size = 38;

  void _showLanguageMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      color: const Color(0xFF1D2024),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: LanguageController.languages.map((lang) {
        return PopupMenuItem(
          onTap: () {
            final controller = Get.find<LanguageController>();
            controller.changeLanguage(lang.locale);
          },
          child: GetBuilder<LanguageController>(
            builder: (controller) {
              final isSelected = controller.currentLocale == lang.locale;
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF20AEFE)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        lang.boxText,
                        style: const TextStyle(
                          fontFamily: 'samsungsharpsans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      lang.translationKey.tr,
                      style: TextStyle(
                        fontFamily: 'samsungsharpsans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Color(0xFF20AEFE),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (controller) {
        final currentLang = (LanguageController.languages.isNotEmpty)
            ? LanguageController.languages.firstWhere(
                (lang) => lang.locale == controller.currentLocale,
                orElse: () => LanguageController.languages.first,
              )
            : LanguageOption(
                id: 'en_US',
                name: 'English',
                locale: 'en_US',
                boxText: 'EN',
                translationKey: 'english',
              );

        return InkWell(
          onTap: () => _showLanguageMenu(context),
          borderRadius: BorderRadius.circular(_size / 2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_size / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.63, sigmaY: 8.63),
              child: Container(
                width: _size,
                height: _size,
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
                  child: Text(
                    currentLang.boxText,
                    style: const TextStyle(
                      fontFamily: 'samsungsharpsans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  String? profileUrl;
  VoidCallback? onTapEditProfile;
  bool isProfileClicked;
  _AvatarCircle({
    this.profileUrl,
    this.onTapEditProfile,
    this.isProfileClicked = true,
  });

  static const double _size = 38;

  void _showProfileMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final offset = Offset(0, 48);
    final RelativeRect adjustedPosition = RelativeRect.fromLTRB(
      position.left,
      position.top + offset.dy,
      position.right,
      position.bottom - offset.dy,
    );

    showMenu(
      context: context,
      position: adjustedPosition,
      color: const Color(0xFF1D2024),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: [
        PopupMenuItem(
          onTap: onTapEditProfile,
          child: _buildMenuItem(text: 'editProfile'.tr),
        ),
        PopupMenuItem(
          onTap: () {
            // Logout after the menu closes
            Future.delayed(const Duration(milliseconds: 100), () async {
              final authController = Get.find<AuthRepo>();
              await authController.signOut();
            });
          },
          child: _buildMenuItem(
            // icon: Icons.logout_outlined,
            text: 'logout'.tr,
            isDestructive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    IconData? icon,
    required String text,
    bool isDestructive = false,
  }) {
    return Container(
      width: 192,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 20,
              color: isDestructive ? const Color(0xFFFE6D73) : Colors.white70,
            ),
          if (icon != null) const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isDestructive ? const Color(0xFFFE6D73) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isProfileClicked ? () => _showProfileMenu(context) : () {},
      borderRadius: BorderRadius.circular(_size / 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.63, sigmaY: 8.63),
          child: Container(
            width: _size,
            height: _size,
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
              child: profileUrl != null && profileUrl!.isNotEmpty
                  ? ClipOval(
                      child: CommonWidget.commonNetworkImageView(
                        imageUrl: profileUrl ?? '',
                        width: _size,
                        height: _size,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Icon(Icons.person_outline, size: 20, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final bool isRtl = languageController.currentLocale == 'he_IL';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 39, sigmaY: 39),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1D2024),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 1, color: const Color(0x1AFFFFFF)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.center,
          child: TextField(
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            cursorColor: Colors.white70,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: 'search'.tr,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.white70,
                size: 20,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const GlassCircle({super.key, required this.icon, this.onTap});

  static const double _size = 38;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_size / 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.63, sigmaY: 8.63),
          child: Container(
            width: _size,
            height: _size,
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
            child: Center(child: Icon(icon, size: 18, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

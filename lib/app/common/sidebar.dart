import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/routes/app_pages.dart';
import 'widgets/sidebar_controller.dart';
import '../app_theme/app_colors.dart';
import '../app_theme/textstyles.dart';
import 'constant/app_assets.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;

    return SizedBox(
      width: 260,
      child: Container(
        width: 260,
        decoration: BoxDecoration(color: AppColors.backgroundColor),
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 41.0841,
                    height: 38.2984,
                    child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'sCommunity'.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18.55,
                      fontWeight: FontWeight.w700,
                      height: 53.01 / 18.55,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    _SidebarItem(
                      icon: Image.asset(AppAssets.sidebarDashboard),
                      label: 'dashboard'.tr,
                      isSelected: currentRoute == Routes.HOME,
                      onTap: () => onDestinationSelected(0),
                    ),
                    SizedBox(height: 8),
                    _SidebarItem(
                      icon: Image.asset(AppAssets.sidebarVod),
                      label: 'vodPodcasts'.tr,
                      isSelected: currentRoute == Routes.VOD_PODCASTS,
                      onTap: () => onDestinationSelected(1),
                    ),
                    SizedBox(height: 8),
                    _SidebarItem(
                      icon: Image.asset(AppAssets.sidebarAcademy),
                      label: 'monthlyTasks'.tr,
                      isSelected: currentRoute == Routes.ACADEMY,
                      onTap: () => onDestinationSelected(2),
                    ),
                    SizedBox(height: 8),
                    _SidebarItem(
                      icon: Image.asset(AppAssets.sidebarAcademy),
                      label: 'chat'.tr,
                      isSelected: currentRoute == Routes.CHAT,
                      onTap: () => onDestinationSelected(9),
                    ),
                    SizedBox(height: 8),
                    _SidebarItem(
                      icon: Image.asset(AppAssets.sidebarCommunity),
                      label: 'community'.tr,
                      isSelected: currentRoute == Routes.COMMUNITY,
                      onTap: () => onDestinationSelected(3),
                    ),
                    SizedBox(height: 8),
                    _SidebarItem(
                      icon: Image.asset(AppAssets.sidebarEvents),
                      label: 'events'.tr,
                      isSelected: currentRoute == Routes.EVENTS,
                      onTap: () => onDestinationSelected(4),
                    ),
                    SizedBox(height: 8),
                    _SidebarItem(
                      icon: Image.asset(AppAssets.sidebarPointStore),
                      label: 'pointStore'.tr,
                      isSelected:
                          currentRoute == Routes.POINT_STORE ||
                          currentRoute.contains(Routes.PRODUCT_ORDERS) == true,
                      onTap: () => onDestinationSelected(5),
                    ),
                    SizedBox(height: 8),
                    _SidebarItem(
                      icon: Image.asset(AppAssets.sidebarUser),
                      label: 'users'.tr,
                      isSelected: currentRoute == Routes.USERS,
                      onTap: () => onDestinationSelected(6),
                    ),
                    SizedBox(height: 8),
                    _SidebarItem(
                      icon: Image.asset(AppAssets.sidebarWeeklyRiddle),
                      label: 'weeklyRiddle'.tr,
                      isSelected: currentRoute == Routes.WEEKLY_RIDDLE,
                      onTap: () => onDestinationSelected(7),
                    ),
                    _SidebarItem(
                      icon: Icon(
                        Icons.campaign_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: 'promotions'.tr,
                      isSelected: currentRoute == Routes.PROMOTIONS,
                      onTap: () => onDestinationSelected(8),
                    ),
                  ],
                ),
              ),
            ),
            GetBuilder<SidebarController>(
              init: Get.isRegistered<SidebarController>()
                  ? Get.find<SidebarController>()
                  : Get.put(SidebarController(), permanent: true),
              builder: (controller) {
                return Obx(() {
                  if (controller.hasWeeklyRiddle.value) {
                    return SizedBox.shrink();
                  } else {
                    return Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(
                            AppAssets.sidebarIconsIcWeeklyRiddleBg,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AssetImageWidget(
                            imagePath: AppAssets.imagesIcWeeklyRiddleBorder,
                            width: 30,
                            height: 30,
                          ),
                          Text(
                            'weeklyRiddle'.tr,
                            textAlign: TextAlign.left,
                            style: AppTextStyles.rubik16w400(context: context),
                          ),
                          Text(
                            'youHaventUploadedTheWeeklyPuzzle'.tr,
                            textAlign: TextAlign.left,
                            style: AppTextStyles.rubik14w500(
                              context: context,
                            ).copyWith(color: Color(0xFFBDBDBD)),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(62),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFF20AEFE),
                                    Color(0xFF135FFF),
                                  ],
                                ),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(62),
                                  ),
                                ),
                                onPressed: () {
                                  Get.toNamed(
                                    Routes.WEEKLY_RIDDLE,
                                    arguments: {'openFlyout': true},
                                  );
                                },
                                child: Text('Upload a puzzle'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void routesCalling(String routeName) {
    if (Get.currentRoute != routeName) {
      Get.offAllNamed(routeName);
    }
  }

  onDestinationSelected(int index) {
    switch (index) {
      case 0:
        routesCalling(Routes.HOME);
        break;
      case 1:
        routesCalling(Routes.VOD_PODCASTS);
        break;
      case 2:
        routesCalling(Routes.ACADEMY);
        break;
      case 3:
        routesCalling(Routes.COMMUNITY);
        break;
      case 4:
        routesCalling(Routes.EVENTS);
        break;
      case 5:
        routesCalling(Routes.POINT_STORE);
        break;
      case 6:
        routesCalling(Routes.USERS);
        break;
      case 7:
        routesCalling(Routes.WEEKLY_RIDDLE);
        break;
      case 8:
        routesCalling(Routes.PROMOTIONS);
        break;
      case 9:
        routesCalling(Routes.CHAT);
    }
  }
}

class _SidebarItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = isSelected
        ? AppColors.primaryColor
        : Colors.white70;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isSelected ? 7.86 : 0,
            sigmaY: isSelected ? 7.86 : 0,
          ),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x0FD6D6D6), Color(0x0F707070)],
                    )
                  : null,
              color: isSelected ? null : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      width: 0.7,
                      color: Colors.white.withOpacity(0.06),
                    )
                  : null,
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        offset: Offset(0, 7.43),
                        blurRadius: 16.6,
                      ),
                      BoxShadow(
                        color: Color(0x17000000),
                        offset: Offset(0, 30.15),
                        blurRadius: 30.15,
                      ),
                      BoxShadow(
                        color: Color(0x0D000000),
                        offset: Offset(0, 68.16),
                        blurRadius: 41.07,
                      ),
                      BoxShadow(
                        color: Color(0x03000000),
                        offset: Offset(0, 121.02),
                        blurRadius: 48.5,
                      ),
                      BoxShadow(
                        color: Color(0x00000000),
                        offset: Offset(0, 189.18),
                        blurRadius: 52.87,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 20, height: 20, child: icon),
                const SizedBox(width: 10),
                isSelected
                    ? ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFBEBEBE), Color(0xFFFFFFFF)],
                          ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          );
                        },
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontFamily: 'samsungsharpsans',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                                letterSpacing: -0.28,
                              ),
                        ),
                      )
                    : Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'samsungsharpsans',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                          letterSpacing: -0.28,
                          color: baseColor,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

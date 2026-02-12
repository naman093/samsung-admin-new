import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For DateFormat
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import 'package:samsung_admin_main_new/app/common/common_button.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/custom_date_range_picker.dart';
import 'package:samsung_admin_main_new/app/common/widgets/network_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/search_text_field.dart';
import '../controllers/prod_orders_controller.dart';

class ProdOrdersView extends GetView<ProdOrdersController> {
  const ProdOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildDateRangeView() {
      return CustomDateRangePickerField(
        startDate: controller.startDate,
        endDate: controller.endDate,
        onSaveDates: (start, end) async {
          await controller.fetchOrders(startDate: start, endDate: end);
        },
        onClearDates: () async {
          await controller.fetchOrders();
        },
      );
    }

    return CommonWidget.commonCardView(
      title: 'orders'.tr,
      subTitle: 'systemActivity'.tr,
      showBackButton: true,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 15,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 450,
                        child: SearchTextField(
                          hintText: 'search'.tr,
                          onChanged: (value) {
                            controller.fetchOrders(searchTerm: value);
                          },
                        ),
                      ),
                      buildDateRangeView(),
                    ],
                  ),
                  SizedBox(
                    width: 220,
                    child: CommonButton(
                      text: 'downloadToExcelFile'.tr,
                      icon: AppAssets.downloadIcon,
                      padding: EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 7,
                      ),
                      onTap: () {
                        controller.downloadCsv();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: buildOrdersTable()),
          ],
        ),
      ),
    );
  }

  Widget buildOrdersTable() {
    Widget headingText({String? title, Color? color, Widget? child}) {
      return Expanded(
        child:
            child ??
            Text(
              title ?? "",
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.rubik14w400().copyWith(
                color: color ?? Colors.white,
              ),
            ),
      );
    }

    return Obx(() {
      return CommonWidget.isLoadingAndEmptyWidget(
        isLoadingValue: controller.isLoading.value,
        isEmpty: controller.orders.isEmpty,
        emptyMsgText: 'noOrdersFound'.tr,
        widget: Column(
          children: [
            Row(
              children: [
                headingText(
                  title: 'nameOfOrder'.tr,
                  color: AppColors.greyColor,
                ),
                headingText(title: 'orderDate'.tr, color: AppColors.greyColor),
                headingText(title: 'city'.tr, color: AppColors.greyColor),
                headingText(title: 'address'.tr, color: AppColors.greyColor),
                headingText(title: 'zipCode'.tr, color: AppColors.greyColor),
                headingText(
                  title: 'mobileNumber'.tr,
                  color: AppColors.greyColor,
                ),
              ],
            ).marginOnly(top: 30),
            Divider(color: AppColors.dashboardContainerBorder, height: 30),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final order = controller.orders[index];
                  final user = order.user;
                  return Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            user?.profilePictureUrl != null &&
                                    user!.profilePictureUrl!.isNotEmpty
                                ? NetworkImageWidget(
                                    imageUrl: user.profilePictureUrl!,
                                    height: 24,
                                    width: 24,
                                    radius: 100,
                                  )
                                : AssetImageWidget(
                                    imagePath: AppAssets.dummyImg,
                                    height: 24,
                                    width: 24,
                                    radius: 100,
                                  ),
                            Flexible(
                              child: Text(
                                user?.fullName ?? user?.phoneNumber ?? '-',
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
                      headingText(
                        title: DateFormat('dd/MM/yyyy').format(order.orderedAt),
                      ),
                      headingText(title: '-'),
                      headingText(title: order.shippingAddress ?? '-'),
                      headingText(title: order.shippingZip ?? '-'),
                      headingText(title: order.shippingPhone ?? '-'),
                    ],
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: 40),
                itemCount: controller.orders.length,
              ),
            ),
          ],
        ),
      );
    });
  }
}

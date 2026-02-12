import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';

class DashboardTable extends StatelessWidget {
  const DashboardTable({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
    required this.headerCells,
    required this.itemCount,
    required this.itemBuilder,
    this.isLoading = false,
    this.emptyWidget,
    this.margin,
    this.padding,
    this.maxVisibleItems,
  });

  final String title;

  final String? subtitle;

  final String? actionLabel;

  final VoidCallback? onActionTap;

  final List<Widget> headerCells;

  final int itemCount;

  final Widget Function(BuildContext context, int index) itemBuilder;

  final bool isLoading;

  final Widget? emptyWidget;

  final EdgeInsetsGeometry? margin;

  final EdgeInsetsGeometry? padding;

  final int? maxVisibleItems;

  @override
  Widget build(BuildContext context) {
    final effectiveMargin = margin ?? const EdgeInsets.only(top: 24);
    final effectivePadding = padding ?? const EdgeInsets.all(24);

    final visibleCount = maxVisibleItems != null
        ? itemCount.clamp(0, maxVisibleItems!)
        : itemCount;

    return Container(
      margin: effectiveMargin,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: const Color(0xFF1D2024),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dashboardContainerBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 7.04),
            blurRadius: 15.73,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.rubik24w400()),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: AppTextStyles.rubik14w400().copyWith(
                        color: AppColors.greyColor,
                      ),
                    ).marginOnly(top: 16),
                ],
              ),
              if (actionLabel != null && actionLabel!.isNotEmpty)
                GestureDetector(
                  onTap: onActionTap,
                  child: Row(
                    children: [
                      Text(
                        actionLabel!,
                        style: AppTextStyles.rubik16w400().copyWith(
                          color: AppColors.lightBlueColor,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right_rounded,
                        color: AppColors.lightBlueColor,
                      ).marginOnly(left: 5),
                    ],
                  ),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: headerCells,
          ).marginOnly(top: 50),
          Divider(color: AppColors.dashboardContainerBorder, height: 30),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ).marginOnly(top: 20)
          else if (visibleCount == 0)
            (emptyWidget ??
                    Center(
                      child: Text(
                        'noData'.tr,
                        style: AppTextStyles.rubik14w400().copyWith(
                          color: AppColors.greyColor,
                        ),
                      ),
                    ))
                .marginOnly(top: 20)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => itemBuilder(context, index),
              separatorBuilder: (context, index) => const SizedBox(height: 40),
              itemCount: visibleCount,
            ),
        ],
      ),
    );
  }
}

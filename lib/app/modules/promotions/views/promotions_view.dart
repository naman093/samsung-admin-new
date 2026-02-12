import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/search_text_field.dart';
import 'package:samsung_admin_main_new/app/common/common_button.dart';
import 'package:samsung_admin_main_new/app/common/common_flyout.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/custom_time_interval_picker.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import '../../../models/promotions_model.dart';
import '../controllers/promotions_controller.dart';
import '../local_widget/create_edit_promotion.dart';

class PromotionsView extends GetView<PromotionsController> {
  const PromotionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonWidget.commonCardView(
      title: 'promotions'.tr,
      subTitle: 'systemActivity'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              spacing: 16,
              children: [
                Expanded(
                  child: SearchTextField(
                    hintText: 'search'.tr,
                    onChanged: (value) {
                      controller.fetchPromotions(searchTerm: value.trim());
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: CommonButton(
                    text: '+  ${'createPromotion'.tr}',
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    onTap: () {
                      controller.clearAllFields();
                      _openCreatePromotionFlyout(context, controller);
                    },
                  ),
                ),
              ],
            ),
          ),
          _promotionsTableView(),
        ],
      ),
    );
  }

  Widget _headingText({
    String? title,
    Color? color,
    TextAlign textAlign = TextAlign.left,
  }) {
    return Expanded(
      child: Text(
        title ?? "",
        textAlign: textAlign,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.rubik14w400().copyWith(
          color: color ?? Colors.white,
        ),
      ),
    );
  }

  Widget _promotionsTableView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          return CommonWidget.isLoadingAndEmptyWidget(
            isLoadingValue: controller.isLoading.value,
            emptyMsgText: 'noData'.tr,
            isEmpty: controller.promotionsList.isEmpty,
            widget: SingleChildScrollView(
              controller: controller.scrollController,
              child: Column(
                children: [
                  Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _headingText(
                        title: 'title'.tr,
                        color: AppColors.greyColor,
                        textAlign: TextAlign.left,
                      ),
                      _headingText(
                        title: 'description'.tr,
                        color: AppColors.greyColor,
                        textAlign: TextAlign.left,
                      ),
                      _headingText(
                        title: 'frequency'.tr,
                        color: AppColors.greyColor,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(width: 30, height: 30),
                    ],
                  ).marginOnly(top: 50),
                  Divider(
                    color: AppColors.dashboardContainerBorder,
                    height: 30,
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final promotion = controller.promotionsList[index];
                      return _buildPromotionRow(context, promotion);
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 40),
                    itemCount: controller.promotionsList.length,
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildPromotionRow(BuildContext context, PromotionModel promotion) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: Text(
            promotion.title,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.rubik14w400().copyWith(color: Colors.white),
          ),
        ),
        Expanded(
          child: Text(
            promotion.description ?? '-',
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: AppTextStyles.rubik14w400().copyWith(color: Colors.white),
          ),
        ),
        Expanded(
          child: Text(
            _formatFrequencyDisplay(promotion),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.rubik14w400().copyWith(color: Colors.white),
          ),
        ),
        _buildPromotionMenu(context, promotion),
      ],
    );
  }

  Widget _buildPromotionMenu(BuildContext context, PromotionModel promotion) {
    return PopupMenuButton<String>(
      color: AppColors.darkGreyColor,
      onSelected: (value) {
        if (value == 'edit') {
          controller.prefillForEdit(promotion);
          _openCreatePromotionFlyout(context, controller);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, promotion);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            spacing: 8,
            children: [
              AssetImageWidget(
                imagePath: AppAssets.editIcon,
                width: 20,
                height: 20,
              ),
              Text('edit'.tr, style: AppTextStyles.rubik12w400()),
            ],
          ),
        ),
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
      ],
      child: AssetImageWidget(
        imagePath: AppAssets.imagesIcMoreIcon,
        width: 30,
        height: 30,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PromotionModel promotion) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkGreyColor,
        title: Text('delete'.tr, style: const TextStyle(color: Colors.white)),
        content: Text(
          '${'deleteConfirmation'.tr} "${promotion.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deletePromotion(promotion.id);
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

  String _formatFrequencyDisplay(PromotionModel promotion) {
    final frequency = promotion.frequency;
    final interval = promotion.intervalDuration ?? '';

    if (frequency == 'oneTime'.tr || interval.isEmpty) {
      return frequency.isNotEmpty ? frequency : 'oneTime'.tr;
    }

    // Parse and format interval
    final intervalData = CustomTimeIntervalPicker.parseInterval(interval);
    final days = intervalData['days'] ?? 0;
    final hours = intervalData['hours'] ?? 0;
    final minutes = intervalData['minutes'] ?? 0;

    final parts = <String>[];
    if (days > 0) {
      parts.add('$days ${days == 1 ? 'day'.tr : 'days'.tr}');
    }
    if (hours > 0) {
      parts.add('$hours ${hours == 1 ? 'hour'.tr : 'hours'.tr}');
    }
    if (minutes > 0) {
      parts.add('$minutes ${minutes == 1 ? 'minute'.tr : 'minutes'.tr}');
    }

    if (parts.isEmpty) {
      return 'setInterval'.tr;
    }

    return parts.join(', ');
  }

  void _openCreatePromotionFlyout(
    BuildContext context,
    PromotionsController controller,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Obx(
          () => PopScope(
            canPop: !controller.isCreating.value,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: CommonFlyout(
                  title: controller.isEditing.value
                      ? 'editPromotion'.tr
                      : 'createPromotion'.tr,
                  description: 'systemActivity'.tr,
                  onClose: () => Navigator.of(context).pop(),
                  canDismiss: () => !controller.isCreating.value,
                  children: [
                    CreateEditPromotion(
                      controller: controller,
                      isEdit: controller.isEditing.value,
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
}

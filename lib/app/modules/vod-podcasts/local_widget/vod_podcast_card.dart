import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/constant/types.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import 'package:samsung_admin_main_new/app/models/content_model.dart';

import '../../../common/common_modal.dart';
import '../controllers/vod_podcasts_controller.dart';
import 'create_edit_content.dart';
import 'video_thumbnail_widget.dart';

class VodPodcastCard extends GetView<VodPodcastsController> {
  final double itemWidth;
  final ContentModel contentModel;

  const VodPodcastCard({
    super.key,
    required this.itemWidth,
    required this.contentModel,
  });

  @override
  Widget build(BuildContext context) {
    final isClickedFileValue = false.obs;
    return Container(
      width: itemWidth,
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 7.43),
            blurRadius: 16.6,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(214, 214, 214, 0.14),
            Color.fromRGBO(112, 112, 112, 0.14),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              contentModel.contentType == ContentType.vod
                  ? VideoThumbnailWidget(
                      videoUrl: contentModel.mediaFileUrl ?? '',
                      width: itemWidth,
                      height: 170,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        topLeft: Radius.circular(16),
                      ),
                    )
                  : CommonWidget.commonNetworkImageView(
                      imageUrl: contentModel.thumbnailUrl ?? '',
                      width: itemWidth,
                      height: 170,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        topLeft: Radius.circular(16),
                      ),
                    ),
              Positioned(
                top: 8,
                right: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7.86, sigmaY: 7.86),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(214, 214, 214, 0.4),
                            Color.fromRGBO(156, 156, 156, 0.4),
                            Color.fromRGBO(112, 112, 112, 0.4),
                          ],
                        ),
                        border: Border.all(
                          width: 1,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            offset: Offset(0, 7.43),
                            blurRadius: 16.6,
                          ),
                          BoxShadow(
                            color: Color(0x17000000), // 0px 30.15px 30.15px
                            offset: Offset(0, 30.15),
                            blurRadius: 30.15,
                          ),
                          BoxShadow(
                            color: Color(0x0D000000), // 0px 68.16px 41.07px
                            offset: Offset(0, 68.16),
                            blurRadius: 41.07,
                          ),
                        ],
                      ),
                      child: Text(
                        contentModel.contentType.toJson().toUpperCase(),
                        style: AppTextStyles.rubik12w400().copyWith(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                child: Obx(
                  () => isClickedFileValue.value
                      ? Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: CommonWidget.isLoadingAndEmptyWidget(
                            isLoadingValue: true,
                          ),
                        )
                      : InkWell(
                          onTap: () async {
                            try {
                              if (!isClickedFileValue.value) {
                                isClickedFileValue.value = true;
                                await controller.playVideo(contentModel);
                              }
                            } finally {
                              isClickedFileValue.value = false;
                            }
                          },
                          child: AssetImageWidget(
                            imagePath: AppAssets.imagesIcPlay,
                            width: 50,
                            height: 50,
                          ),
                        ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                contentModel.title?.trim().isEmpty ?? true
                    ? 'Title'
                    : contentModel.title ?? '',
                style: AppTextStyles.rubik16w400().copyWith(
                  fontSize: 16,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                contentModel.description?.trim().isEmpty ?? true
                    ? 'No Description'
                    : contentModel.description ?? '',
                textAlign: TextAlign.left,
                style: AppTextStyles.rubik12w400().copyWith(
                  fontSize: 12,
                  height: 18 / 12,
                  letterSpacing: 0,
                  color: AppColors.labelTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => {
                        controller.prefillFormForEdit(contentModel),
                        controller.clearAllErrors(),
                        showCommonModal(
                          Get.context!,
                          width: 678,
                          title: 'editPost'.tr,
                          description: 'vodPodcastsDescription'.tr,
                          child: CreateEditContent(
                            controller: controller,
                            isEditing: true,
                          ),
                          canDismiss: () =>
                              !controller.isCreateContentBtnValue.value,
                        ),
                      },
                      child: Container(
                        height: 44,
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.2,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromRGBO(214, 214, 214, 0.2),
                              Color.fromRGBO(112, 112, 112, 0.2),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000), // #0000001A
                              offset: Offset(0, 3.57),
                              blurRadius: 7.97,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            AssetImageWidget(
                              imagePath: AppAssets.vodEdit,
                              color: AppColors.white,
                              width: 18,
                              height: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'edit'.tr,
                              style: TextStyle(
                                fontFamily: 'samsungsharpsans',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 18 / 12,
                                letterSpacing: 0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () => controller.clickOnDeleteBtn(contentModel.id),
                    child: Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(214, 214, 214, 0.2),
                            Color.fromRGBO(112, 112, 112, 0.2),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000), // #0000001A
                            offset: Offset(0, 3.57),
                            blurRadius: 7.97,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          AppAssets.trashIcon,
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ).paddingAll(12),
        ],
      ),
    );
  }
}

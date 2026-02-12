import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import 'dart:ui' as ui;

import '../../../common/constant/app_assets.dart';
import '../../../models/content_full_details_model.dart';
import '../controllers/community_controller.dart';

class FeedCard extends GetView<CommunityController> {
  final ContentFullDetailsModel contentModel;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onReadMore;
  final double itemWidth;
  final bool showFullContent;

  const FeedCard({
    super.key,
    required this.contentModel,
    this.onDelete,
    this.onEdit,
    required this.itemWidth,
    this.onReadMore,
    this.showFullContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: itemWidth,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cardColor1, AppColors.cardColor2],
          stops: [-0.4925, 1.2388],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadowFeed,
            offset: Offset(0, 7.43),
            blurRadius: 16.6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          userProfileView(),
          SizedBox(height: 20),
          Divider(color: AppColors.dividerLight, thickness: 1, height: 1),
          SizedBox(height: 20),
          titleView(),
          SizedBox(height: 8),
          descriptionWithReadMore(),
          if (contentModel.mediaFileUrl != null &&
              contentModel.mediaFileUrl!.isNotEmpty) ...[
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CommonWidget.commonNetworkImageView(
                imageUrl: contentModel.mediaFileUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorImageUrl: AppAssets.imageNotFound,
              ),
            ),
          ] else ...[
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                AppAssets.noImageAvailable,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
          // SizedBox(height: 05),
          // GestureDetector(
          //   onTap: onReadMore,
          //   child: Text(
          //     'readMore'.tr,
          //     style: TextStyle(
          //       fontFamily: 'Samsung Sharp Sans',
          //       fontSize: 14,
          //       color: AppColors.authSpansColor,
          //       fontWeight: FontWeight.w700,
          //       decoration: TextDecoration.underline,
          //     ),
          //   ),
          // ),
          SizedBox(height: 20),
          Divider(color: AppColors.dividerLight, thickness: 1, height: 1),
          SizedBox(height: 20),
          likedUsersListView(),
          SizedBox(height: 14),
          likeUnlikeBtnView(),
          SizedBox(height: 8),
          viewAllCommentBtnView(),
          SizedBox(height: 12),
          addCommentView(),
        ],
      ),
    );
  }

  Widget userProfileView() {
    return Row(
      spacing: 10,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: CommonWidget.commonNetworkImageView(
            imageUrl: contentModel.authorProfilePicture ?? '',
            errorImageUrl: AppAssets.sidebarUser,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (true) ...[
                    Image.asset(
                      AppAssets.verifiedProfileIcon,
                      width: 20,
                      height: 20,
                      fit: BoxFit.fitHeight,
                    ),
                    SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      contentModel.authorName ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        fontSize: 16,
                        letterSpacing: 0,
                        color: AppColors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                '${'datePublished'.tr}: ${DateFormat('MMM d, yyyy').format(contentModel.createdAt)}',
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontSize: 12,
                  // color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          color: AppColors.darkGreyColor,
          onSelected: (value) {
            if (value == 'edit') {
              onEdit?.call();
            } else if (value == 'confirm') {
              debugPrint('called: onDelete');
              onDelete?.call();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'confirm',
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
                      AppAssets.trashIcon,
                      width: 10,
                      color: AppColors.white,
                      height: 10,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Text('delete'.tr, style: AppTextStyles.rubik12w400()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
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
                      AppAssets.editIcon,
                      width: 10,
                      color: AppColors.white,
                      height: 10,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Text('edit'.tr, style: AppTextStyles.rubik12w400()),
                ],
              ),
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
  }

  Widget titleView() {
    return Text(
      contentModel.title ?? '',
      style: TextStyle(
        fontFamily: 'Samsung Sharp Sans',
        fontWeight: FontWeight.w700,
        fontSize: 16,
        // color: AppColors.white,
      ),
      maxLines: showFullContent ? null : 1,
      overflow: showFullContent ? null : TextOverflow.ellipsis,
    );
  }

  // Widget descriptionView() {
  //   return Text(
  //     contentModel.description ?? '',
  //     style: TextStyle(
  //       fontFamily: 'Samsung Sharp Sans',
  //       fontSize: 14,
  //       color: AppColors.white,
  //       height: 1.5,
  //       fontWeight: FontWeight.w700,
  //     ),
  //     maxLines: 1,
  //     overflow: TextOverflow.ellipsis,
  //   );
  // }

  bool _isTextOverflowing({
    required String text,
    required TextStyle style,
    required double maxWidth,
    int maxLines = 1,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return textPainter.didExceedMaxLines;
  }

  Widget descriptionWithReadMore() {
    final textStyle = TextStyle(
      fontFamily: 'Samsung Sharp Sans',
      fontSize: 14,
      color: AppColors.white,
      height: 1.5,
      fontWeight: FontWeight.w700,
    );

    if (showFullContent) {
      return Text(contentModel.description ?? '', style: textStyle);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isOverflowing = _isTextOverflowing(
          text: contentModel.description ?? '',
          style: textStyle,
          maxWidth: constraints.maxWidth,
          maxLines: 1,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contentModel.description ?? '',
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            !isOverflowing
                ? const SizedBox(height: 20)
                : const SizedBox.shrink(),
            if (isOverflowing) ...[
              const SizedBox(height: 5),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onReadMore,
                  child: Text(
                    'readMore'.tr,
                    style: const TextStyle(
                      fontFamily: 'Samsung Sharp Sans',
                      fontSize: 12,
                      color: AppColors.authSpansColor,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget likedUsersListView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (contentModel.likesCount > 0) ...[
          SizedBox(
            width:
                ((((contentModel.likedByUsers?.length ?? 0).clamp(0, 3)) * 12) +
                        12)
                    .toDouble(),
            height: 18,
            child: Stack(
              children: List.generate(
                (contentModel.likedByUsers?.length ?? 0).clamp(0, 3),
                (index) => Positioned(
                  left: (index * 12).toDouble(),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cardColor1, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CommonWidget.commonNetworkImageView(
                        imageUrl:
                            contentModel
                                .likedByUsers![index]
                                .profilePictureUrl ??
                            '',
                        errorImageUrl: AppAssets.Avatar,
                        fit: BoxFit.cover,
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        Expanded(
          child: SizedBox(
            // Reserve space for up to 2 lines of text so all cards in a row align
            height: 32,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: contentModel.likesCount == 0
                        ? 'Be The First To Like'.tr
                        : '${'likedBy'.tr} ',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (contentModel.likesCount > 0) ...[
                    TextSpan(
                      text:
                          contentModel.likedByUsers != null &&
                              contentModel.likedByUsers!.isNotEmpty
                          ? contentModel.likedByUsers!.first.fullName ?? 'User'
                          : '${contentModel.likesCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (contentModel.likesCount > 1) ...[
                      TextSpan(
                        text: ' ${'and'.tr} ',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: '${contentModel.likesCount - 1} ${'others'.tr}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget likeUnlikeBtnView() {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => controller.toggleLike(contentModel),
            child: Icon(
              contentModel.isLikedByMe ? Icons.favorite : Icons.favorite_border,
              color: contentModel.isLikedByMe
                  ? AppColors.likePink
                  : AppColors.labelTextColor,
              size: 20,
            ),
          ),
        ),
        SizedBox(width: 10),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => controller.showCommentsModal(contentModel.contentId),
            child: Image.asset(
              AppAssets.commentIcon,
              width: 20,
              height: 20,
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
      ],
    );
  }

  Widget viewAllCommentBtnView() {
    return GestureDetector(
      onTap: () => controller.showCommentsModal(contentModel.contentId),
      child: Text(
        '${'viewAll'.tr} ${contentModel.commentsCount} ${'comments'.tr}',
        style: TextStyle(
          fontFamily: 'Samsung Sharp Sans',
          fontSize: 12,
          color: AppColors.whiteOpacity60,
        ),
      ),
    );
  }

  Widget addCommentView() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Obx(() {
              return CommonWidget.commonNetworkImageView(
                imageUrl:
                    controller.authRepo.currentUser.value?.profilePictureUrl ??
                    '',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorImageUrl: AppAssets.Avatar,
              );
            }),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller.getCommentController(contentModel.contentId),
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontSize: 12,
              color: AppColors.gradientColor2,
            ),
            decoration: InputDecoration(
              hintText: 'addComment'.tr,
              hintStyle: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontSize: 12,
                color: AppColors.gradientColor2,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onSubmitted: (_) =>
                controller.submitComment(contentModel.contentId),
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          onPressed: () => controller.submitComment(contentModel.contentId),
          icon: Icon(Icons.send, color: AppColors.primaryColor, size: 16),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 24, minHeight: 24),
        ),
      ],
    );
  }
}

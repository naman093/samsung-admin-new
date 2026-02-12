import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import '../controllers/community_controller.dart';
import '../../../models/comment_model.dart';
import '../../../common/constant/app_assets.dart';

class CommentsModal extends GetView<CommunityController> {
  final String contentId;
  final TextEditingController _modalTextFieldController =
      TextEditingController();

  CommentsModal({super.key, required this.contentId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.8,
      decoration: BoxDecoration(
        // color: AppColors.cardColor1,
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'viewAllComments'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close, color: AppColors.white),
              ),
            ],
          ),
          Divider(color: AppColors.dividerLight),
          Expanded(
            child: Obx(() {
              return CommonWidget.isLoadingAndEmptyWidget(
                isLoadingValue: controller.isCommentsLoading.value,
                isEmpty: controller.comments.isEmpty,
                widget: ListView.builder(
                  itemCount: controller.comments.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final comment = controller.comments[index];
                    return CommentItem(
                      comment: comment,
                      contentId: contentId,
                      controller: controller,
                    );
                  },
                ),
              );
            }),
          ),
          Divider(color: AppColors.dividerLight),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _modalTextFieldController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'addComment'.tr,
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Obx(
                  () => controller.isSubmittingComment.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: Icon(Icons.send, color: AppColors.primaryColor),
                          onPressed: () async {
                            await controller.submitComment(
                              contentId,
                              modalText: _modalTextFieldController.text,
                            );
                            _modalTextFieldController.clear();
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentItem extends StatefulWidget {
  final ContentCommentViewModel comment;
  final String contentId;
  final CommunityController controller;

  const CommentItem({
    super.key,
    required this.comment,
    required this.contentId,
    required this.controller,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool isHovered = false;
  bool isDeleteIconHovered = false;
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        leading: CircleAvatar(
          backgroundImage: widget.comment.commentUserProfilePicture != null
              ? NetworkImage(widget.comment.commentUserProfilePicture!)
                    as ImageProvider
              : AssetImage(AppAssets.Avatar),
        ),
        title: Row(
          children: [
            Text(
              widget.comment.commentUserName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd/MM/yy').format(widget.comment.commentCreatedAt),
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.comment.commentText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                maxLines: isExpanded ? null : 2,
                overflow: isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
              if (widget.comment.commentText.length >
                  100) // Simple length check optimization
                GestureDetector(
                  onTap: () => setState(() => isExpanded = !isExpanded),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isExpanded ? 'readLess'.tr : 'readMore'.tr,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        trailing: isHovered
            ? MouseRegion(
                onEnter: (_) => setState(() => isDeleteIconHovered = true),
                onExit: (_) => setState(() => isDeleteIconHovered = false),
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: isDeleteIconHovered
                        ? Colors.redAccent
                        : Colors.white38,
                    size: 16,
                  ),
                  onPressed: () => widget.controller.clickOnDeleteComment(
                    widget.contentId,
                    widget.comment.commentId,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

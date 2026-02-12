import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/widgets/create_upload_button.dart';
import 'package:samsung_admin_main_new/app/common/widgets/custom_date_range_picker.dart';
import 'package:samsung_admin_main_new/app/common/widgets/search_text_field.dart';
import 'package:samsung_admin_main_new/app/modules/community/local_widget/create_edit_feed.dart';
import '../../../common/common_modal.dart';
import '../../../common/widgets/common_widget.dart';
import '../../../common/widgets/sort_by_dropdown.dart';
import '../controllers/community_controller.dart';
import '../local_widget/feed_card.dart';

class CommunityView extends GetView<CommunityController> {
  const CommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildDateRangeView() {
      return CustomDateRangePickerField(
        startDate: controller.startDate,
        endDate: controller.endDate,
        onSaveDates: (start, end) async {
          await controller.fetchFeeds(startDate: start, endDate: end);
        },
        onClearDates: () async {
          await controller.fetchFeeds();
        },
      );
    }

    return CommonWidget.commonCardView(
      title: 'community'.tr,
      subTitle: 'usersListDescription'.tr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double itemWidth = maxWidth > 1100
              ? maxWidth / 4 - 16
              : maxWidth > 800
              ? maxWidth / 3 - 16
              : maxWidth > 360
              ? maxWidth / 2 - 16
              : maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Row(
                      spacing: 16,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 260, child: _voidSearchField()),
                        _buildSortByDropdown(),
                        buildDateRangeView(),
                      ],
                    ),
                    Spacer(),
                    _uploadFileButton(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height:
                    constraints.maxHeight.isFinite && constraints.maxHeight > 0
                    ? constraints.maxHeight - 200
                    : MediaQuery.of(context).size.height * 0.7,
                child: Obx(() {
                  final isLoadingMore = controller.isLoadingMore.value;
                  return CommonWidget.isLoadingAndEmptyWidget(
                    isLoadingValue:
                        controller.isLoading.value && controller.feeds.isEmpty,
                    isEmpty:
                        controller.feeds.isEmpty && !controller.isLoading.value,
                    emptyMsgText: 'noPostsFound'.tr,
                    widget: SingleChildScrollView(
                      controller: controller.scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: List.generate(
                              controller.feeds.length,
                              (index) => FeedCard(
                                onDelete: () => controller.clickOnDeleteBtn(
                                  controller.feeds[index].contentId,
                                ),
                                onEdit: () {
                                  controller.prefillFormForEdit(
                                    controller.feeds[index],
                                  );
                                  showCommonModal(
                                    Get.context!,
                                    width: 678,
                                    title: 'editPost'.tr,
                                    description: 'communityDescription'.tr,
                                    child: CreateEditFeed(
                                      controller: controller,
                                    ),
                                    canDismiss: () =>
                                        !controller.isCreating.value,
                                  );
                                },
                                onReadMore: () => controller.clickReadMoreBtn(
                                  controller.feeds[index],
                                ),
                                itemWidth: itemWidth,
                                contentModel: controller.feeds[index],
                              ),
                            ),
                          ),
                          if (isLoadingMore)
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _uploadFileButton() {
    return CreateUploadButton(
      title: 'uploadANewPost'.tr,
      description: 'communityDescription'.tr,
      onTap: () {
        controller.clearAllFields();
        showCommonModal(
          Get.context!,
          width: 678,
          title: 'uploadANewPost'.tr,
          description: 'communityDescription'.tr,
          child: CreateEditFeed(controller: controller),
          canDismiss: () => !controller.isCreating.value,
        );
      },
    );
  }

  Widget _buildSortByDropdown() {
    return SortByDropdown(
      selectedValue: controller.selectedShortByValue,
      items: controller.shortByList,
      labelMap: controller.shortByLabelMap,
      onSelected: (value) {
        controller.resetPage();
        controller.searchController.clear();
        controller.fetchFeeds(orderBy: value);
      },
    );
  }

  Widget _voidSearchField() {
    return SearchTextField(
      hintText: 'search'.tr,
      controller: controller.searchController,
      onChanged: (value) {
        controller.resetPage();
        if (controller.startDate.value.isNotEmpty &&
            controller.endDate.value.isNotEmpty) {
          controller.fetchFeeds(
            searchTerm: value,
            startDate: controller.startDate.value,
            endDate: controller.endDate.value,
          );
        } else {
          controller.fetchFeeds(searchTerm: value);
        }
      },
    );
  }
}

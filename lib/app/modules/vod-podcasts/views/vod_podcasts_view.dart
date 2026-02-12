import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/common_modal.dart';
import 'package:samsung_admin_main_new/app/common/widgets/create_upload_button.dart';
import 'package:samsung_admin_main_new/app/common/widgets/custom_date_range_picker.dart';
import 'package:samsung_admin_main_new/app/common/widgets/sort_by_dropdown.dart';
import 'package:samsung_admin_main_new/app/common/widgets/search_text_field.dart';
import 'package:samsung_admin_main_new/app/common/widgets/vod_podcast_type_drpdwn.dart';
import 'package:samsung_admin_main_new/app/modules/vod-podcasts/controllers/vod_podcasts_controller.dart';
import 'package:samsung_admin_main_new/app/modules/vod-podcasts/local_widget/create_edit_content.dart';
import 'package:samsung_admin_main_new/app/modules/vod-podcasts/local_widget/vod_podcast_card.dart';
import '../../../common/widgets/common_widget.dart';

class VodPodcastsView extends GetView<VodPodcastsController> {
  const VodPodcastsView({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildDateRangeView() {
      return CustomDateRangePickerField(
        startDate: controller.startDate,
        endDate: controller.endDate,
        onSaveDates: (start, end) async {
          await controller.fetchFiles(startDate: start, endDate: end);
        },
        onClearDates: () async {
          await controller.fetchFiles();
        },
      );
    }

    return CommonWidget.commonCardView(
      title: 'vodPodcasts'.tr,
      subTitle:
          'manageAndReviewTheLatestVideoOnDemandAndPodcastContentInTheCommunityDescription'
              .tr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          // Calculate number of columns based on screen width
          int crossAxisCount = maxWidth > 1100
              ? 4
              : maxWidth > 800
              ? 4
              : maxWidth > 360
              ? 2
              : 1;
          double itemWidth =
              (maxWidth - (crossAxisCount - 1) * 20) / crossAxisCount;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _uploadFileButton(),
                    const Spacer(),
                    SizedBox(width: 10),
                    Row(
                      spacing: 16,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        vodPodcastTypeDropdown(),
                        buildDateRangeView(),
                        GetBuilder<VodPodcastsController>(
                          init: VodPodcastsController(),
                          builder: (controller) {
                            return _buildSortByDropdown();
                          },
                        ),
                        SizedBox(width: 260, child: _voidSearchField()),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                height:
                    constraints.maxHeight.isFinite && constraints.maxHeight > 0
                    ? constraints.maxHeight - 200
                    : MediaQuery.of(context).size.height * 0.65,
                child: Obx(() {
                  final isLoadingMore = controller.isLoadingMore.value;
                  final files = controller.files;
                  return CommonWidget.isLoadingAndEmptyWidget(
                    isLoadingValue: controller.isLoading.value && files.isEmpty,
                    emptyMsgText: 'noFilesFound'.tr,
                    isEmpty: files.isEmpty && !controller.isLoading.value,
                    widget: CustomScrollView(
                      controller: controller.scrollController,
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.zero,
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 20,
                                  childAspectRatio: itemWidth / 320,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final contentModel = files[index];
                                return VodPodcastCard(
                                  key: ValueKey(contentModel.id),
                                  itemWidth: itemWidth,
                                  contentModel: contentModel,
                                );
                              },
                              childCount: files.length,
                              addAutomaticKeepAlives: true,
                              addRepaintBoundaries: true,
                            ),
                          ),
                        ),
                        if (isLoadingMore)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: const Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            ),
                          ),
                      ],
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
      title: 'uploadANewFile'.tr,
      description: 'uploadANewFileDescription'.tr,
      onTap: () {
        controller.isEditing.value = false;
        controller.clearAllFields();
        showCommonModal(
          Get.context!,
          width: 678,
          title: 'uploadANewFile'.tr,
          description: 'uploadANewFileDescription'.tr,
          child: CreateEditContent(controller: controller),
          canDismiss: () => !controller.isCreateContentBtnValue.value,
        );
      },
    );
  }

  Widget vodPodcastTypeDropdown() {
    return VodPodcastTypeDropdown(
      width: 120,
      selectedValue: controller.selectedSortByValue,
      items: controller.sortByList,
      labelMap: controller.sortByLabelMap,
      // labelText: 'vodPodcastType'.tr,
      onSelected: (value) {
        // controller.selectedSortByValue.value = value;
        controller.resetPage();
        controller.fetchFiles(contentType: value);
      },
    );
  }

  Widget _voidSearchField() {
    return SearchTextField(
      hintText: 'search'.tr,
      controller: controller.searchController,
      onChanged: (value) {
        controller.resetPage();
        controller.fetchFiles(searchTerm: value);
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
        controller.fetchFiles(shortBy: value);
      },
    );
  }
}

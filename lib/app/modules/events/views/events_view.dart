import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/widgets/search_text_field.dart';
import 'package:samsung_admin_main_new/app/common/common_modal.dart';
import 'package:samsung_admin_main_new/app/modules/events/local_widget/create_edit_content.dart';
import 'package:samsung_admin_main_new/app/modules/events/local_widget/event_card.dart';
import 'package:samsung_admin_main_new/app/modules/events/local_widget/eventer_events_dialog.dart';
import '../../../common/widgets/common_widget.dart';
import '../../../common/common_button.dart';
import '../../../common/common_flyout.dart';
import '../controllers/events_controller.dart';

class EventsView extends GetView<EventsController> {
  const EventsView({super.key});
  @override
  Widget build(BuildContext context) {
    return CommonWidget.commonCardView(
      title: 'events'.tr,
      subTitle: 'systemActivity'.tr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight - 30 - 16 - 14 - 16 - 20 - 52
              : MediaQuery.of(context).size.height * 0.6;

          final scrollHeight = availableHeight > 0 ? availableHeight : 600.0;

          return Column(
            spacing: 10,
            children: [
              // Category Filter Buttons
              Obx(
                () => Row(
                  spacing: 10,
                  children: [
                    _CategoryFilterButton(
                      text: 'everything'.tr,
                      isSelected: controller.selectedCategory.value == 'All',
                      onTap: () {
                        controller.selectedCategory.value = 'All';
                        // Update selected event if list is not empty
                        if (controller.filteredEventList.isNotEmpty) {
                          controller.selectedEvent.value =
                              controller.filteredEventList.first;
                        } else {
                          controller.selectedEvent.value = null;
                        }
                      },
                    ),
                    _CategoryFilterButton(
                      text: 'externalEvents'.tr,
                      isSelected:
                          controller.selectedCategory.value ==
                          'External Events',
                      onTap: () {
                        controller.selectedCategory.value = 'External Events';
                        if (controller.filteredEventList.isNotEmpty) {
                          controller.selectedEvent.value =
                              controller.filteredEventList.first;
                        } else {
                          controller.selectedEvent.value = null;
                        }
                      },
                    ),
                    _CategoryFilterButton(
                      text: 'internalEvents'.tr,
                      isSelected:
                          controller.selectedCategory.value ==
                          'Internal Events',
                      onTap: () {
                        controller.selectedCategory.value = 'Internal Events';
                        if (controller.filteredEventList.isNotEmpty) {
                          controller.selectedEvent.value =
                              controller.filteredEventList.first;
                        } else {
                          controller.selectedEvent.value = null;
                        }
                      },
                    ),
                  ],
                ),
              ),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    // width: MediaQuery.of(context).size.width * 0.55,
                    child: SearchTextField(
                      hintText: 'search'.tr,
                      onChanged: (value) {
                        controller.resetPage();
                        controller.fetchEventList(searchTerm: value);
                      },
                    ),
                  ),
                  Obx(() {
                    final selectedCategory = controller.selectedCategory.value;

                    if (selectedCategory == 'All') {
                      return const SizedBox.shrink();
                    }

                    if (selectedCategory == 'External Events') {
                      return SizedBox(
                        width: 220,
                        child: CommonButton(
                          text: 'pullEventsFromEventer'.tr,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          onTap: () {
                            _openEventerEventsDialog(context, controller);
                            controller.pullEventsFromEventer();
                          },
                        ),
                      );
                    }

                    return SizedBox(
                      width: 200,
                      child: CommonButton(
                        text: '+  ${'createANewEvent'.tr}',
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        onTap: () {
                          controller.clearAllFields();
                          controller.clearErrors();
                          _openCreateEventFlyout(context, controller);
                        },
                      ),
                    );
                  }),
                ],
              ),
              Obx(() {
                controller.selectedCategory.value;
                controller.internalEvents.length;
                controller.externalEvents.length;

                final filteredList = controller.filteredEventList;
                return CommonWidget.isLoadingAndEmptyWidget(
                  isLoadingValue: controller.isLoading.value,
                  emptyMsgText: 'noFilesFound'.tr,
                  isEmpty: filteredList.isEmpty,
                  widget: Row(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: scrollHeight,
                          child: SingleChildScrollView(
                            controller: controller.scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            child: Column(
                              spacing: 20,
                              children: [
                                ...List.generate(filteredList.length, (index) {
                                  final eventModel = filteredList[index];
                                  return EventCard(
                                    onClick: () {
                                      controller.setSelectedEvent(eventModel);
                                    },
                                    selected:
                                        controller.selectedEvent.value?.id ==
                                        eventModel.id,
                                    onEdit: () {
                                      controller.prefillFormForEdit(eventModel);
                                      _openCreateEventFlyout(
                                        context,
                                        controller,
                                      );
                                    },
                                    onDelete: () => controller.clickOnDeleteBtn(
                                      eventModel.id,
                                    ),
                                    eventModel: eventModel,
                                    controller: controller,
                                  );
                                }),
                                if (controller.isLoadingMore.value)
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Obx(() {
                        return SizedBox(
                          height: scrollHeight,
                          child: CommonWidget.commonNetworkImageView(
                            imageUrl:
                                controller.selectedEvent.value?.imageUrl ?? '',
                            height: MediaQuery.of(context).size.height * 0.7,
                            width: 240,
                            borderRadius: BorderRadius.circular(16),
                            fit: BoxFit.fitWidth,
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  void _openCreateEventFlyout(
    BuildContext context,
    EventsController controller,
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
            canPop: !controller.isCreateEventBtnValue.value,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: CommonFlyout(
                  title: controller.isEditing.value
                      ? 'editEvent'.tr
                      : 'createEvent'.tr,
                  description: 'systemActivity'.tr,
                  onClose: () => Navigator.of(context).pop(),
                  canDismiss: () => !controller.isCreateEventBtnValue.value,
                  children: [
                    CreateEditEvent(
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

  void _openEventerEventsDialog(
    BuildContext context,
    EventsController controller,
  ) {
    showCommonModal(
      context,
      title: 'externalEvents'.tr,
      description: 'selectAnEventToImport'.tr,
      width: 800,
      height: 600,
      child: EventerEventsDialog(
        controller: controller,
        onImportEvent: () {
          _openCreateEventFlyout(context, controller);
        },
      ),
    );
  }
}

class _CategoryFilterButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryFilterButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(
          top: 16,
          right: 18,
          bottom: 16,
          left: 18,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF20AEFE), // #20AEFE
                    Color(0xFF135FFF), // #135FFF
                  ],
                )
              : const LinearGradient(
                  begin: Alignment(0, -0.4925), // -49.25%
                  end: Alignment(0, 1.2388), // 123.88%
                  colors: [
                    Color.fromRGBO(214, 214, 214, 0.1),
                    Color.fromRGBO(112, 112, 112, 0.1),
                  ],
                ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000), // 0px 7.43px 16.6px 0px #0000001A
              offset: Offset(0, 7.43),
              blurRadius: 16.6,
            ),
            BoxShadow(
              color: Color(0x17000000), // 0px 30.15px 30.15px 0px #00000017
              offset: Offset(0, 30.15),
              blurRadius: 30.15,
            ),
            BoxShadow(
              color: Color(0x0D000000), // 0px 68.16px 41.07px 0px #0000000D
              offset: Offset(0, 68.16),
              blurRadius: 41.07,
            ),
            BoxShadow(
              color: Color(0x03000000), // 0px 121.02px 48.5px 0px #00000003
              offset: Offset(0, 121.02),
              blurRadius: 48.5,
            ),
            BoxShadow(
              color: Color(0x00000000), // 0px 189.18px 52.87px 0px #00000000
              offset: Offset(0, 189.18),
              blurRadius: 52.87,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 7.864322662353516,
              sigmaY: 7.864322662353516,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF979797),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

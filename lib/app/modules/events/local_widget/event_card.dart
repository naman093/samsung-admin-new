import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import 'package:samsung_admin_main_new/app/models/event_model.dart';
import 'package:samsung_admin_main_new/app/modules/events/controllers/events_controller.dart';
import 'package:samsung_admin_main_new/app/modules/events/local_widget/event_details_flyout.dart';
import 'package:samsung_admin_main_new/app/modules/events/local_widget/event_chip.dart';

class EventCard extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool? selected;
  final EventModel eventModel;
  final EventsController controller;
  final VoidCallback onClick;

  const EventCard({
    super.key,
    this.onEdit,
    this.onDelete,
    this.selected,
    required this.eventModel,
    required this.controller,
    required this.onClick,
  });

  Widget _detailIcomCont({required String title, String? value, String? icon}) {
    return Row(
      spacing: 4,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF20AEFE), // #20AEFE
                Color(0xFF135FFF), // #135FFF
              ],
              stops: [0.0041, 1.0],
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: AssetImageWidget(imagePath: icon, width: 10, height: 10),
        ),
        Text(title, style: AppTextStyles.rubik14w400()),
        if (value != null) Text(value, style: AppTextStyles.rubik14w400()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    PopupMenuItem<String> popUpMenuBtn({
      required String value,
      required String title,
      required String icon,
    }) {
      return PopupMenuItem(
        value: value,
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
              child: AssetImageWidget(
                imagePath: icon,
                width: 10,
                height: 10,
                color: AppColors.white,
              ),
            ),
            Text(title, style: AppTextStyles.rubik12w400()),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onClick,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: (selected == true
                ? AppColors.white
                : AppColors.eventCardBorderColor),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
          color: AppColors.eventCardBgColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 17,
                children: [
                  CommonWidget.commonNetworkImageView(
                    imageUrl: eventModel.imageUrl,
                    width: 133,
                    height: 160,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      spacing: 15,
                      children: [
                        Row(
                          spacing: 11,
                          children: [
                            EventChip(
                              title:
                                  eventModel.type != null &&
                                      eventModel.type!.isNotEmpty
                                  ? eventModel.type![0].toUpperCase() +
                                        eventModel.type!.substring(1)
                                  : '',
                              color: eventModel.type == 'external'
                                  ? AppColors.externalEventColor
                                  : AppColors.blue400,
                            ),
                            if (eventModel.type == 'external' &&
                                eventModel.status != null &&
                                eventModel.status!.isNotEmpty)
                              EventChip(
                                title:
                                    eventModel.status![0].toUpperCase() +
                                    eventModel.status!.substring(1),
                                color:
                                    eventModel.status!.toLowerCase() == 'active'
                                    ? AppColors.activeStatusTextColor
                                    : AppColors.inactiveStatusTextColor,
                                backgroundColor:
                                    eventModel.status!.toLowerCase() == 'active'
                                    ? AppColors.activeStatusBgColor
                                    : AppColors.inactiveStatusBgColor,
                              ),
                            EventChip(
                              title: eventModel.maxTickets == null
                                  ? 'Unlimited tickets'
                                  : '${(eventModel.maxTickets! - eventModel.ticketsSold).toString()} Remaining',
                            ),
                            EventChip(
                              title: controller.formatEventDate(
                                eventModel.eventDate,
                              ),
                            ),
                          ],
                        ),
                        CommonWidget.readMoreAndLessTextView(
                          text: eventModel.title,
                        ),
                        CommonWidget.readMoreAndLessTextView(
                          text: eventModel.description ?? '',
                          style: AppTextStyles.rubik14w400(),
                        ),
                        Row(
                          spacing: 20,
                          children: [
                            if (eventModel.costCreditCents != null &&
                                eventModel.costCreditCents! > 0)
                              _detailIcomCont(
                                title: 'Credit:',
                                value: eventModel.costCreditCents.toString(),
                                icon: AppAssets.creditIcon,
                              ),
                            if (eventModel.costPoints != null &&
                                eventModel.costPoints! > 0)
                              _detailIcomCont(
                                title: 'Points:',
                                value: eventModel.costPoints.toString(),
                                icon: AppAssets.sidebarPointStore,
                              ),
                          ],
                        ),
                      ],
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
                } else if (value == 'delete') {
                  onDelete?.call();
                } else if (value == 'view') {
                  _openEventDetailsFlyout(context);
                } else if (value == 'toggleStatus') {
                  if (eventModel.status != null) {
                    controller.toggleEventStatus(
                      eventModel.id,
                      eventModel.status!,
                    );
                  }
                }
              },
              itemBuilder: (context) => [
                popUpMenuBtn(
                  value: 'edit',
                  title: 'edit'.tr,
                  icon: AppAssets.editIcon,
                ),
                if (eventModel.type != 'external')
                  popUpMenuBtn(
                    value: 'delete',
                    title: 'delete'.tr,
                    icon: AppAssets.trashIcon,
                  ),
                if (eventModel.type == 'external')
                  popUpMenuBtn(
                    value: 'toggleStatus',
                    title: eventModel.status?.toLowerCase() == 'active'
                        ? 'setToInactive'.tr
                        : 'setToActive'.tr,
                    icon: eventModel.status?.toLowerCase() == 'active'
                        ? AppAssets.clearIc
                        : AppAssets.checkIc,
                  ),
                popUpMenuBtn(
                  value: 'view',
                  title: 'detailsAboutTheEvent'.tr,
                  icon: AppAssets.plusIcon,
                ),
              ],
              child: AssetImageWidget(
                imagePath: AppAssets.imagesIcMoreIcon,
                width: 30,
                height: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEventDetailsFlyout(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: EventDetailsFlyout(
              eventModel: eventModel,
              controller: controller,
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

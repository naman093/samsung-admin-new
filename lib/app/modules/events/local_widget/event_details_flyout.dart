import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import 'package:samsung_admin_main_new/app/common/common_button.dart';
import 'package:samsung_admin_main_new/app/common/common_flyout.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import 'package:samsung_admin_main_new/app/models/event_model.dart';
import 'package:samsung_admin_main_new/app/models/event_registration_model.dart';
import 'package:samsung_admin_main_new/app/modules/events/controllers/events_controller.dart';
import 'package:samsung_admin_main_new/app/modules/events/local_widget/event_chip.dart';

class EventDetailsFlyout extends StatefulWidget {
  final EventModel eventModel;
  final EventsController controller;

  const EventDetailsFlyout({
    super.key,
    required this.eventModel,
    required this.controller,
  });

  @override
  State<EventDetailsFlyout> createState() => _EventDetailsFlyoutState();
}

class _EventDetailsFlyoutState extends State<EventDetailsFlyout> {
  @override
  void initState() {
    super.initState();
    widget.controller.fetchEventRegistrations(widget.eventModel.id);
  }

  @override
  Widget build(BuildContext context) {
    return CommonFlyout(
      title: '',
      onClose: () => Navigator.of(context).pop(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                spacing: 16,
                children: [
                  Row(
                    spacing: 30,
                    children: [
                      CommonWidget.commonNetworkImageView(
                        imageUrl: widget.eventModel.imageUrl,
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      Expanded(
                        child: Row(
                          spacing: 11,
                          children: [
                            Expanded(
                              child: Text(
                                widget.eventModel.title,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.rubik14w400().copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            EventChip(
                              title: widget.eventModel.type ?? '',
                              color: widget.eventModel.type == 'external'
                                  ? AppColors.externalEventColor
                                  : AppColors.blue400,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 16,
                    children: [
                      EventChip(
                        title: widget.eventModel.maxTickets == null
                            ? 'Unlimited tickets'
                            : '${(widget.eventModel.maxTickets! - widget.eventModel.ticketsSold).toString()} Remaining',
                      ),
                      EventChip(
                        title: widget.controller.formatEventDate(
                          widget.eventModel.eventDate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildRegistrationsTable(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationsTable() {
    return Obx(() {
      if (widget.controller.isLoadingRegistrations.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (widget.controller.eventRegistrations.isEmpty) {
        return Text(
          'noData'.tr,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headingText(title: 'userName'.tr, color: AppColors.greyColor),
              Container(width: 100), // Space for cancel button
            ],
          ).marginOnly(top: 20),
          Divider(color: AppColors.dashboardContainerBorder, height: 30),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final registration = widget.controller.eventRegistrations[index];
              return _buildRegistrationRow(registration);
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 20);
            },
            itemCount: widget.controller.eventRegistrations.length,
          ),
        ],
      );
    });
  }

  Widget _headingText({String? title, Color? color}) {
    return Expanded(
      child: Text(
        title ?? "",
        textAlign: TextAlign.start,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.rubik14w400().copyWith(
          color: color ?? Colors.white,
        ),
      ),
    );
  }

  Widget _buildRegistrationRow(EventRegistrationModel registration) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            registration.displayName,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.rubik14w400().copyWith(color: Colors.white),
          ),
        ),
        SizedBox(
          width: 150,
          child: CommonButton(
            text: 'cancel'.tr,
            icon: AppAssets.userCrossIcon,
            iconColor: AppColors.redColor,
            borderRadius: 100,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            onTap: () {
              widget.controller.clickOnCancelRegistration(
                registration.id,
                widget.eventModel.title,
              );
            },
          ),
        ),
      ],
    );
  }
}

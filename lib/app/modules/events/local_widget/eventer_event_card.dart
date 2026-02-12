import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';
import 'package:samsung_admin_main_new/app/common/common_button.dart';
import 'package:samsung_admin_main_new/app/models/eventer_event_model.dart';

class EventerEventCard extends StatelessWidget {
  final EventerEventModel eventerEvent;
  final VoidCallback onImport;
  final bool isImported;

  const EventerEventCard({
    super.key,
    required this.eventerEvent,
    required this.onImport,
    this.isImported = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy');
    final startDate = dateFormat.format(eventerEvent.schedule.start);
    final endDate = dateFormat.format(eventerEvent.schedule.end);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.eventCardBorderColor, width: 1),
        borderRadius: BorderRadius.circular(20),
        color: AppColors.eventCardBgColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  eventerEvent.name,
                  style: AppTextStyles.rubik16w400().copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  spacing: 12,
                  children: [
                    Text(
                      'Start: $startDate',
                      style: AppTextStyles.rubik14w400().copyWith(
                        color: AppColors.greyColor,
                      ),
                    ),
                    Text(
                      'End: $endDate',
                      style: AppTextStyles.rubik14w400().copyWith(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
                if (eventerEvent.locationDescription.isNotEmpty)
                  Text(
                    eventerEvent.locationDescription,
                    style: AppTextStyles.rubik14w400().copyWith(
                      color: AppColors.greyColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 120,
            child: CommonButton(
              text: isImported ? 'imported'.tr : 'import'.tr,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              onTap: onImport,
              isEnabled: !isImported,
            ),
          ),
        ],
      ),
    );
  }
}

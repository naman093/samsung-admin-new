import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_theme/app_colors.dart';

class CustomDateRangePickerField extends StatelessWidget {
  final RxString startDate;
  final RxString endDate;
  final double width;
  final double height;
  final void Function(String start, String end)? onSaveDates;
  final VoidCallback? onClearDates;

  const CustomDateRangePickerField({
    super.key,
    required this.startDate,
    required this.endDate,
    this.width = 180,
    this.height = 44,
    this.onSaveDates,
    this.onClearDates,
  });

  DateTime _parseDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return DateTime.now();
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return DateTime.now();
    return DateTime(year, month, day);
  }

  Future<void> _pickRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDateRange: (startDate.value.isNotEmpty && endDate.value.isNotEmpty)
          ? DateTimeRange(
              start: _parseDate(startDate.value),
              end: _parseDate(endDate.value),
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.white,
              surface: AppColors.backgroundColor,
              onSurface: AppColors.white,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Get.width * 0.5,
                maxHeight: Get.height * 0.6,
              ),
              child: child!,
            ),
          ),
        );
      },
    );

    if (picked != null) {
      final start =
          "${picked.start.day.toString().padLeft(2, '0')}-"
          "${picked.start.month.toString().padLeft(2, '0')}-"
          "${picked.start.year}";

      final end =
          "${picked.end.day.toString().padLeft(2, '0')}-"
          "${picked.end.month.toString().padLeft(2, '0')}-"
          "${picked.end.year}";

      startDate.value = start;
      endDate.value = end;
      onSaveDates?.call(start, end);
    }
  }

  void _clearRange() {
    startDate.value = '';
    endDate.value = '';
    onClearDates?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final displayText = (startDate.value.isEmpty || endDate.value.isEmpty)
          ? '${'start'.tr} - ${'end'.tr} ${'date'.tr}'
          : '${startDate.value} - ${endDate.value}';

      return SizedBox(
        // width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7.86, sigmaY: 7.86),
            child: InkWell(
              onTap: _pickRange,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1D2024),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: const Color(0x1AFFFFFF)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: _pickRange,
                      child: Text(
                        displayText,
                        style: TextStyle(
                          fontFamily: 'samsungsharpsans',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Row(
                      children: [
                        if (startDate.value.isNotEmpty &&
                            endDate.value.isNotEmpty)
                          InkWell(
                            onTap: _clearRange,
                            child: Icon(
                              Icons.clear,
                              size: 18,
                              color: Colors.red,
                            ),
                          )
                        else
                          InkWell(
                            onTap: _pickRange,
                            child: Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

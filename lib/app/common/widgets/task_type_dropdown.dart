import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_theme/app_colors.dart';

class TaskTypeDropdown extends StatelessWidget {
  final RxString selectedValue;
  final List<String> items;
  final Map<String, String> labelMap;
  final double width;
  final double height;
  final PopupMenuItemSelected<String>? onSelected;
  final String? labelText;

  const TaskTypeDropdown({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.labelMap,
    this.width = 180,
    this.height = 44,
    this.onSelected,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            labelText ?? '',
            style: const TextStyle(
              fontFamily: 'samsungsharpsans',
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 14,
              height: 24 / 14,
              letterSpacing: 0,
              color: Colors.white,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              selectedValue.value = value;
              if (onSelected != null) {
                onSelected!(value);
              }
            },
            itemBuilder: (context) {
              return items.map((key) {
                return PopupMenuItem<String>(
                  value: key,
                  child: Text(
                    labelMap[key] ?? key,
                    style: const TextStyle(
                      fontFamily: 'samsungsharpsans',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      height: 24 / 14,
                      letterSpacing: 0,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList();
            },
            offset: Offset(0, 50),
            color: Color(0xFF1D2024),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              width: width,
              height: height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7.86, sigmaY: 7.86),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientColor1.withValues(alpha: 0.2),
                          AppColors.gradientColor2.withValues(alpha: 0.2),
                        ],
                        stops: const [0.0, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1,
                        color: const Color(0x1AFFFFFF),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          labelMap[selectedValue.value] ?? selectedValue.value,
                          style: TextStyle(
                            fontFamily: 'samsungsharpsans',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 24 / 14,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

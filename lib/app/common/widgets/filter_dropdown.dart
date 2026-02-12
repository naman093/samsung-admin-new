import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterDropdown extends StatelessWidget {
  final RxString selectedValue;
  final List<String> items;
  final Map<String, String> labelMap;
  final double width;
  final double height;
  final PopupMenuItemSelected<String>? onSelected;
  final String hint;

  const FilterDropdown({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.labelMap,
    this.width = 180,
    this.height = 44,
    this.onSelected,
    this.hint = 'Filter',
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopupMenuButton<String>(
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
        offset: const Offset(0, 50),
        color: const Color(0xFF1D2024),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          // width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7.86, sigmaY: 7.86),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1D2024),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: const Color(0x1AFFFFFF)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$hint ${labelMap[selectedValue.value] ?? selectedValue.value}',
                      style: const TextStyle(
                        fontFamily: 'samsungsharpsans',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 24 / 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
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
      );
    });
  }
}

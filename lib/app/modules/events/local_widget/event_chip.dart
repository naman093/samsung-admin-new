import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/app_theme/textstyles.dart';

class EventChip extends StatelessWidget {
  final String title;
  final Color? color;
  final Color? backgroundColor;

  const EventChip({
    super.key,
    required this.title,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Color? textColor;
    Color? finalBackgroundColor;

    if (this.backgroundColor != null) {
      finalBackgroundColor = this.backgroundColor;
      textColor = color;
    } else if (color != null) {
      textColor = color;
      finalBackgroundColor = Color.fromRGBO(
        color!.red,
        color!.green,
        color!.blue,
        0.2,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 7.864322662353516,
          sigmaY: 7.864322662353516,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: finalBackgroundColor != null
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [finalBackgroundColor, finalBackgroundColor],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(214, 214, 214, 0.4),
                      Color.fromRGBO(112, 112, 112, 0.4),
                    ],
                    stops: [-0.4925, 1.2388],
                  ),
            borderRadius: BorderRadius.circular(100),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 7.43),
                blurRadius: 16.6,
              ),
              BoxShadow(
                color: Color(0x17000000),
                offset: Offset(0, 30.15),
                blurRadius: 30.15,
              ),
              BoxShadow(
                color: Color(0x0D000000),
                offset: Offset(0, 68.16),
                blurRadius: 41.07,
              ),
              BoxShadow(
                color: Color(0x03000000),
                offset: Offset(0, 121.02),
                blurRadius: 48.5,
              ),
              BoxShadow(
                color: Color(0x00000000),
                offset: Offset(0, 189.18),
                blurRadius: 52.87,
              ),
            ],
          ),
          child: Text(
            title,
            style: AppTextStyles.rubik14w400().copyWith(
              color: textColor ?? AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

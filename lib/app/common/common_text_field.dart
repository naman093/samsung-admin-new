import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_theme/app_colors.dart';
import '../app_theme/textstyles.dart';

class CommonTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? prefix;
  final IconData? suffixIcon;
  final int? minLines;
  final int? maxLines;
  final Widget? suffix;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final double? borderRadius;
  final bool? readOnly;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const CommonTextField({
    super.key,
    this.hintText,
    this.prefixIcon,
    this.controller,
    this.suffixIcon,
    this.minLines,
    this.maxLines,
    this.suffix,
    this.readOnly,
    this.labelText,
    this.textStyle,
    this.prefix,
    this.hintStyle,
    this.borderRadius = 8,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelText != null
            ? Text(
                labelText ?? "",
                style: AppTextStyles.rubik14w400(context: context),
              ).marginOnly(bottom: 12)
            : Container(),
        Container(
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
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextFormField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            style: textStyle,
            readOnly: readOnly ?? false,
            cursorColor: Colors.white70,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle:
                  hintStyle ??
                  AppTextStyles.rubik12w400(
                    context: context,
                  ).copyWith(color: Colors.white.withValues(alpha: 0.3)),
              suffixIcon:
                  suffix ?? Icon(suffixIcon, color: Colors.white70, size: 20),
              prefixIcon: prefix != null
                  ? prefixIcon != null
                        ? Icon(prefixIcon, color: Colors.white70, size: 20)
                        : null
                  : null,

              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

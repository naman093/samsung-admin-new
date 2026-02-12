import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app_theme/app_colors.dart';
import '../../app_theme/textstyles.dart';

class GradientTextField extends StatefulWidget {
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
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final GestureTapCallback? onTap;
  final String? errorText;

  const GradientTextField({
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
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.onTap,
    this.errorText,
  });

  @override
  State<GradientTextField> createState() => _GradientTextFieldState();
}

class _GradientTextFieldState extends State<GradientTextField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.labelText != null
            ? Opacity(
                opacity: (widget.readOnly ?? false) && widget.onTap == null
                    ? 0.6
                    : 1.0,
                child: Text(
                  widget.labelText ?? "",
                  style: AppTextStyles.rubik14w400(context: context),
                ).marginOnly(bottom: 8),
              )
            : Container(),
        Opacity(
          opacity: (widget.readOnly ?? false) && widget.onTap == null
              ? 0.6
              : 1.0,
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
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextFormField(
              controller: widget.controller,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              style: widget.textStyle,
              readOnly: widget.readOnly ?? false,
              cursorColor: Colors.white70,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              validator: (value) {
                final error = widget.validator?.call(value);
                setState(() {
                  _errorText = error;
                });
                return error;
              },
              onChanged: (value) {
                if (_errorText != null) {
                  setState(() {
                    _errorText = null;
                  });
                }
                widget.onChanged?.call(value);
              },
              onFieldSubmitted: widget.onSubmitted,
              onTap: widget.onTap,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                errorStyle: const TextStyle(height: 0, fontSize: 0),
                hintText: widget.hintText,
                hintStyle:
                    widget.hintStyle ??
                    AppTextStyles.rubik12w400(
                      context: context,
                    ).copyWith(color: Colors.white.withValues(alpha: 0.3)),
                suffixIcon:
                    widget.suffix ??
                    (widget.suffixIcon != null
                        ? Icon(
                            widget.suffixIcon,
                            color: Colors.white70,
                            size: 20,
                          )
                        : null),
                prefixIcon:
                    widget.prefix ??
                    (widget.prefixIcon != null
                        ? Icon(
                            widget.prefixIcon,
                            color: Colors.white70,
                            size: 20,
                          )
                        : null),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20, // Fixed height to reserve space for error text
          child: (widget.errorText != null || _errorText != null)
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.errorText ?? _errorText!,
                    style: TextStyle(
                      fontFamily: 'samsungsharpsans',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

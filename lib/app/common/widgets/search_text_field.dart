import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/localization/language_controller.dart';

class SearchTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final double height;

  const SearchTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.height = 44,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // Only dispose if we created the controller ourselves
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _clearText() {
    _controller.clear();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final bool isRtl = languageController.currentLocale == 'he_IL';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 39, sigmaY: 39),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFF1D2024),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 1, color: const Color(0x1AFFFFFF)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.center,
          child: TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            cursorColor: Colors.white70,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.white70,
                size: 20,
              ),
              suffixIcon: _hasText
                  ? GestureDetector(
                      onTap: _clearText,
                      child: const Icon(
                        Icons.clear,
                        color: Colors.red,
                        size: 20,
                      ),
                    )
                  : null,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}

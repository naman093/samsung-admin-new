import 'package:flutter/material.dart';

import '../app_theme/app_colors.dart';

/// A reusable, library-style radio button with label.
///
/// Usage:
/// ```dart
/// CommonRadio<MyEnum>(
///   value: MyEnum.optionA,
///   groupValue: selected,
///   label: 'Option A',
///   onChanged: (v) => setState(() => selected = v!),
/// );
/// ```
class CommonRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final String label;
  final String? description;
  final bool dense;

  const CommonRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    this.description,
    this.dense = false,
  });

  bool get _isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    final theme = Theme.of(context);

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? () => onChanged?.call(value) : null,
          child: Container(
            height: 44,
            // Adjusted vertical padding so content (label + optional description)
            // fits without overflow while keeping overall height at 44.
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(214, 214, 214, 0.2),
                  Color.fromRGBO(112, 112, 112, 0.2),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000), // #00000040
                  offset: Offset(2, -2),
                  blurRadius: 2,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _RadioCircle(isSelected: _isSelected, enabled: enabled),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'samsungsharpsans',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 22 / 12,
                        letterSpacing: 0,
                        color: Colors.white,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.labelTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  final bool isSelected;
  final bool enabled;

  const _RadioCircle({required this.isSelected, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColors.primaryColor;
    final Color borderColor = enabled
        ? (isSelected ? activeColor : Colors.white.withOpacity(0.7))
        : Colors.white.withOpacity(0.4);

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: isSelected ? 11 : 0,
          height: isSelected ? 11 : 0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? activeColor : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

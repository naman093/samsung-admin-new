import 'dart:ui';
import 'package:flutter/material.dart';

import '../app_theme/app_colors.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final double rotation;
  const CustomBackButton({
    super.key,
    required this.onTap,
    this.rotation = 3.14159,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(89.48),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(214, 214, 214, 0.2),
                Color.fromRGBO(112, 112, 112, 0.2),
              ],
              stops: [0.0, 1.0],
            ),
            border: Border.all(width: 0.89, color: Colors.white.withOpacity(0.2)),
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 6.65),
                blurRadius: 14.86,
                spreadRadius: 0,
                color: Color(0x1A000000),
              ),
              BoxShadow(
                offset: Offset(0, 26.97),
                blurRadius: 26.97,
                spreadRadius: 0,
                color: Color(0x17000000),
              ),
              BoxShadow(
                offset: Offset(0, 60.99),
                blurRadius: 36.75,
                spreadRadius: 0,
                color: Color(0x0D000000),
              ),
              BoxShadow(
                offset: Offset(0, 108.29),
                blurRadius: 43.39,
                spreadRadius: 0,
                color: Color(0x03000000),
              ),
              BoxShadow(
                offset: Offset(0, 169.28),
                blurRadius: 47.3,
                spreadRadius: 0,
                color: Color(0x00000000),
              ),
              BoxShadow(
                offset: Offset(1.79, -1.79),
                blurRadius: 1.79,
                spreadRadius: 0,
                color: Color(0x40000000),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(89.48),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 7.036915302276611,
                sigmaY: 7.036915302276611,
              ),
              child: Center(
                child: Transform.rotate(
                  angle: rotation,
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateUploadButton extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;
  final double width;
  final double height;

  const CreateUploadButton({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.width = 215,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7.86, sigmaY: 7.86),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(214, 214, 214, 0.4),
                      Color.fromRGBO(112, 112, 112, 0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
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
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '+  ${title.tr}',
                      style: const TextStyle(
                        fontFamily: 'samsungsharpsans',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        height: 24 / 14,
                        letterSpacing: 0,
                        color: Colors.white,
                      ),
                    ),
                    // const SizedBox(width: 4),
                    // const Text(
                    //   '+',
                    //   style: TextStyle(
                    //     fontFamily: 'samsungsharpsans',
                    //     fontWeight: FontWeight.w500,
                    //     fontStyle: FontStyle.normal,
                    //     fontSize: 14,
                    //     height: 24 / 14,
                    //     letterSpacing: 0,
                    //     color: Colors.white,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

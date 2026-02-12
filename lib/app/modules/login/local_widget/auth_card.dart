import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_theme/app_colors.dart';
import '../../../common/constant/app_assets.dart';
import '../../../common/custom_back_button.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AuthCard({
    super.key,
    required this.child,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Image.asset(AppAssets.logo, height: 121, width: 130),
        const SizedBox(height: 51),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.loginBg),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 70,
                  vertical: 46,
                ),
                child: Column(
                  spacing: 33,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'welcome'.tr,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontFamily: 'samsungsharpsans',
                              fontWeight: FontWeight.w400,
                              fontSize: 24,
                            ),
                          ),
                          TextSpan(
                            text: '\n${'sCommunity'.tr}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontFamily: 'samsungsharpsans',
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    child,
                  ],
                ),
              ),
              if (showBackButton)
                Positioned(
                  top: 16,
                  right: 16,
                  child: CustomBackButton(
                    onTap: onBackPressed ?? () => Get.back(),
                    rotation: 0,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

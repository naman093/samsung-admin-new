import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/constant/app_assets.dart';
import '../../../common/widgets/asset_image_widget.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        controller.count.value;
        return Center(
          child: AssetImageWidget(
            imagePath: AppAssets.logo,
            width: Get.width * 0.3,
            height: Get.height * 0.6,
            fit: BoxFit.contain,
          ),
        );
      }),
    );
  }
}

import 'package:get/get.dart';

import '../../../repository/auth_repo/auth_repo.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepo>(() => AuthRepo());
    Get.lazyPut<SplashController>(() => SplashController());
  }
}

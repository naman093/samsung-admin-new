import 'package:get/get.dart';

import '../../../repository/auth_repo/auth_repo.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepo>(() => AuthRepo());
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}

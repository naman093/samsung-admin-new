import 'package:get/get.dart';

import '../../../repository/auth_repo/auth_repo.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepo>(() => AuthRepo());
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

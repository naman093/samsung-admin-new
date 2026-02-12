import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/repository/auth_repo/auth_repo.dart';

import '../controllers/signup_controller.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepo>(() => AuthRepo());
    Get.lazyPut<SignupController>(() => SignupController());
  }
}

import 'package:get/get.dart';

import '../../../repository/auth_repo/auth_repo.dart';
import '../controllers/verify_code_controller.dart';

class VerifyCodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepo>(() => AuthRepo());
    Get.lazyPut<VerifyCodeController>(() => VerifyCodeController());
  }
}

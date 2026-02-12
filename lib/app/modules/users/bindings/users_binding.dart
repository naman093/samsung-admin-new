import 'package:get/get.dart';

import '../../../repository/auth_repo/auth_repo.dart';
import '../controllers/users_controller.dart';

class UsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepo>(() => AuthRepo());
    Get.lazyPut<UsersController>(() => UsersController());
  }
}

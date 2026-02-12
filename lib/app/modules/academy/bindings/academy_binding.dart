import 'package:get/get.dart';

import '../../../repository/academy_repo.dart';
import '../controllers/academy_controller.dart';

class AcademyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(()=>AcademyRepo());
    Get.lazyPut<AcademyController>(
      () => AcademyController(),
    );
  }
}

import 'package:get/get.dart';

import '../../../repository/promotions_repo.dart';
import '../controllers/promotions_controller.dart';

class PromotionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PromotionsRepo());
    Get.lazyPut<PromotionsController>(() => PromotionsController());
  }
}

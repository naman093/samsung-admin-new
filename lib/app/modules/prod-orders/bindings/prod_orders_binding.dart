import 'package:get/get.dart';
import '../../../repository/prod_order_repo.dart';
import '../controllers/prod_orders_controller.dart';

class ProdOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProdOrderRepo>(() => ProdOrderRepo());
    Get.lazyPut<ProdOrdersController>(() => ProdOrdersController());
  }
}

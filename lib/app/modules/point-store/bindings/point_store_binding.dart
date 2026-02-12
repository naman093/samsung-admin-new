import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/repository/point_store_repo.dart';

import '../controllers/point_store_controller.dart';

class PointStoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PointStoreRepo>(() => PointStoreRepo());
    Get.lazyPut<PointStoreController>(() => PointStoreController());
  }
}

import 'package:get/get.dart';

import '../../../repository/community_repo.dart';
import '../controllers/community_controller.dart';

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunityRepo>(() => CommunityRepo());
    Get.lazyPut<CommunityController>(() => CommunityController(),);
  }
}

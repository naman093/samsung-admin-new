import 'package:get/get.dart';

import '../../../repository/vod_podcast_repo.dart';
import '../controllers/vod_podcasts_controller.dart';

class VodPodcastsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VodPodcastRepo>(
      () => VodPodcastRepo(),
    );
    Get.lazyPut<VodPodcastsController>(
      () => VodPodcastsController(),
    );
  }
}

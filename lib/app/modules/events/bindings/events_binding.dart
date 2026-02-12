import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/repository/events_repo.dart';

import '../controllers/events_controller.dart';

class EventsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EventsRepo());
    Get.lazyPut<EventsController>(() => EventsController());
  }
}

import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/repository/weekly_riddle_repo.dart';

import '../controllers/weekly_riddle_controller.dart';

class WeeklyRiddleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeeklyRiddleRepo>(() => WeeklyRiddleRepo());
    Get.lazyPut<WeeklyRiddleController>(() => WeeklyRiddleController());
  }
}

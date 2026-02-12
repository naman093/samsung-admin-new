import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/modules/chat/controllers/chat_controller.dart';
import 'package:samsung_admin_main_new/app/repository/chat_repo.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatRepo>(() => ChatRepo());
    Get.lazyPut<ChatController>(() => ChatController());
  }
}

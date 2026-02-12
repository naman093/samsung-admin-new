import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/models/user_model.dart';
import 'package:samsung_admin_main_new/app/models/notification_model.dart';
import 'package:samsung_admin_main_new/app/common/services/notification_service.dart';
import '../common/services/user_service.dart';
import '../routes/app_pages.dart';

class CommonHeaderController extends GetxController {
  UserService get userService {
    if (!Get.isRegistered<UserService>()) {
      Get.put(UserService());
    }
    return Get.find<UserService>();
  }

  final notificationService = NotificationService();

  final blockedUser = <UserModel>[].obs;
  final notifications = <NotificationModel>[].obs;

  final isLoading = true.obs;
  final isUnblockBtnLoading = false.obs;
  final isLoadingNotifications = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchBlockedUserList();
  }

  Future<void> fetchBlockedUserList({
    String? searchTerm,
    String? shortBy,
  }) async {
    try {
      isLoading.value = true;
      blockedUser.clear();
      blockedUser.value = await userService.fetchUserBlockList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clickOnUnblockUserBtn(String userId) async {
    try {
      isUnblockBtnLoading.value = true;
      final res = await userService.unblockUser(userId);
      if (res.isSuccess) {
        await fetchBlockedUserList();
      }
    } finally {
      isUnblockBtnLoading.value = false;
    }
  }

  Future<void> clickOnEditProfileBtn(UserModel record) async {
    await Get.offAllNamed(
      Routes.EDIT_PROFILE,
      parameters: {'userId': record.id},
    );
    fetchBlockedUserList();
  }

  Future<void> fetchNotifications({String? userId, int? limit}) async {
    try {
      isLoadingNotifications.value = true;
      notifications.clear();

      final result = await notificationService.fetchNotifications(
        userId: userId,
        limit: limit,
      );

      if (result.isSuccess) {
        final fetchedNotifications = result.dataOrNull ?? [];
        notifications.value = fetchedNotifications;
      }
    } finally {
      isLoadingNotifications.value = false;
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final result = await notificationService.markAsRead(notificationId);
      if (result.isSuccess) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}

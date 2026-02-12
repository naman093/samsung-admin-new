import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/common/services/supabase_service.dart';
import 'package:samsung_admin_main_new/app/models/notification_model.dart';

class NotificationService {
  Future<Result<List<NotificationModel>>> fetchNotifications({
    String? userId,
    bool? isRead,
    int? limit,
  }) async {
    try {
      print('📋 Fetching notifications...');

      dynamic query = SupabaseService.client
          .from('notifications')
          .select()
          .isFilter('deleted_at', null);

      if (userId != null && userId.isNotEmpty) {
        query = query.eq('user_id', userId);
      }

      if (isRead != null) {
        query = query.eq('is_read', isRead);
      }

      query = query.order('created_at', ascending: false);

      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final response = await query;

      final List<dynamic> data = response as List<dynamic>;
      final notifications = data
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      print('✅ Fetched ${notifications.length} notifications');
      return Success(notifications);
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return Failure(e.toString());
    }
  }

  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      print('✅ Notification marked as read: $notificationId');
      return const Success(null);
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return Failure(e.toString());
    }
  }

  Future<Result<void>> markAllAsRead(String userId) async {
    try {
      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      print('✅ All notifications marked as read for user: $userId');
      return const Success(null);
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      return Failure(e.toString());
    }
  }
}

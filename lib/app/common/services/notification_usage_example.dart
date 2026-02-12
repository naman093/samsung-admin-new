// Example usage of Firebase Push Notifications
// This file demonstrates how to use the notification services in your controllers

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/services/firebase_notification_service.dart';
import 'package:samsung_admin_main_new/app/common/services/notification_sender_service.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';

/// Example controller showing how to use push notifications
class NotificationExampleController extends GetxController {
  final FirebaseNotificationService _notificationService =
      Get.find<FirebaseNotificationService>();

  final fcmToken = ''.obs;
  final isLoadingToken = false.obs;
  final isSendingNotification = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupNotificationListener();
    _getFCMToken();
  }

  /// Setup listener for incoming notifications
  void _setupNotificationListener() {
    _notificationService.notificationStream.listen((message) {
      debugPrint('Notification received: ${message.notification?.title}');
      // Handle notification data
      if (message.data.containsKey('type')) {
        _handleNotificationByType(message.data['type'], message.data);
      }
    });
  }

  /// Get FCM token for this device
  Future<void> _getFCMToken() async {
    isLoadingToken.value = true;
    try {
      final token = await _notificationService.getFCMToken();
      if (token != null) {
        fcmToken.value = token;
        debugPrint('FCM Token: $token');
      } else {
        CommonSnackbar.error('Failed to get FCM token');
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      CommonSnackbar.error('Error getting FCM token');
    } finally {
      isLoadingToken.value = false;
    }
  }

  /// Send notification to a specific device
  Future<void> sendNotificationToDevice({
    required String targetFcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    isSendingNotification.value = true;
    try {
      final success = await NotificationSenderService.sendToDevice(
        fcmToken: targetFcmToken,
        title: title,
        body: body,
        data: data,
      );

      if (success) {
        CommonSnackbar.success('Notification sent successfully');
      } else {
        CommonSnackbar.error('Failed to send notification');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
      CommonSnackbar.error('Error sending notification');
    } finally {
      isSendingNotification.value = false;
    }
  }

  /// Send notification to multiple devices
  Future<void> sendNotificationToMultipleDevices({
    required List<String> targetFcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    isSendingNotification.value = true;
    try {
      final results = await NotificationSenderService.sendToMultipleDevices(
        fcmTokens: targetFcmTokens,
        title: title,
        body: body,
        data: data,
      );

      final successCount = results.values.where((v) => v == true).length;
      final totalCount = results.length;

      if (successCount == totalCount) {
        CommonSnackbar.success('All notifications sent successfully');
      } else {
        CommonSnackbar.error(
          'Sent $successCount out of $totalCount notifications',
        );
      }
    } catch (e) {
      debugPrint('Error sending notifications: $e');
      CommonSnackbar.error('Error sending notifications');
    } finally {
      isSendingNotification.value = false;
    }
  }

  /// Send notification to a topic
  Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    isSendingNotification.value = true;
    try {
      final success = await NotificationSenderService.sendToTopic(
        topic: topic,
        title: title,
        body: body,
        data: data,
      );

      if (success) {
        CommonSnackbar.success('Notification sent to topic: $topic');
      } else {
        CommonSnackbar.error('Failed to send notification to topic');
      }
    } catch (e) {
      debugPrint('Error sending notification to topic: $e');
      CommonSnackbar.error('Error sending notification to topic');
    } finally {
      isSendingNotification.value = false;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _notificationService.subscribeToTopic(topic);
      CommonSnackbar.success('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
      CommonSnackbar.error('Error subscribing to topic');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _notificationService.unsubscribeFromTopic(topic);
      CommonSnackbar.success('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
      CommonSnackbar.error('Error unsubscribing from topic');
    }
  }

  /// Handle notification by type
  void _handleNotificationByType(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'weekly_riddle':
        // Navigate to weekly riddle
        // Get.toNamed('/weekly-riddle');
        break;
      case 'user_approved':
        // Handle user approval notification
        break;
      case 'points_added':
        // Handle points notification
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  /// Copy FCM token to clipboard
  void copyTokenToClipboard() {
    if (fcmToken.value.isNotEmpty) {
      // Use clipboard package or Get.snackbar
      CommonSnackbar.success('FCM Token copied to clipboard');
      // Clipboard.setData(ClipboardData(text: fcmToken.value));
    }
  }
}

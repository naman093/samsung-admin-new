import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';

/// Top-level function to handle background messages (for web)
/// Must be a top-level function, not a class method
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  debugPrint('Background message data: ${message.data}');
  debugPrint('Background message notification: ${message.notification?.title}');
}

class FirebaseNotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GetStorage _storage = GetStorage();

  static const String _fcmTokenKey = 'fcm_token';

  // Stream controller for notifications
  final _notificationStreamController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get notificationStream =>
      _notificationStreamController.stream;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  void onInit() {
    super.onInit();
    // Only initialize for web platform
    if (kIsWeb) {
      _initializeNotifications();
    } else {
      debugPrint('Firebase notifications only supported on web platform');
    }
  }

  @override
  void onClose() {
    _notificationStreamController.close();
    super.onClose();
  }

  /// Initialize Firebase Cloud Messaging for web
  Future<void> _initializeNotifications() async {
    try {
      // Request permission for web notifications
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: false, // Not supported on web
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        await _getFCMToken();

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle notification taps when app is in background
        FirebaseMessaging.onMessageOpenedApp.listen(
          _handleBackgroundMessageTap,
        );

        // Check if app was opened from a terminated state
        RemoteMessage? initialMessage = await _firebaseMessaging
            .getInitialMessage();
        if (initialMessage != null) {
          _handleBackgroundMessageTap(initialMessage);
        }

        // Set background message handler
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );

        _isInitialized = true;
        debugPrint(
          'Firebase Notification Service initialized successfully for web',
        );
      } else {
        debugPrint(
          'Notification permission not granted: ${settings.authorizationStatus}',
        );
      }
    } catch (e) {
      debugPrint('Error initializing Firebase notifications: $e');
    }
  }

  /// Get FCM token for this device
  Future<String?> _getFCMToken() async {
    try {
      // For web, we need to get the VAPID key from Firebase config
      // This should be set in your Firebase project settings
      _fcmToken = await _firebaseMessaging.getToken(
        vapidKey: null, // Set your VAPID key here if needed
      );

      if (_fcmToken != null) {
        await _storage.write(_fcmTokenKey, _fcmToken);
        debugPrint('FCM Token: $_fcmToken');

        // Token refresh listener
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _storage.write(_fcmTokenKey, newToken);
          debugPrint('FCM Token refreshed: $newToken');
        });
      }
      return _fcmToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Get FCM token (public method)
  Future<String?> getFCMToken() async {
    if (!kIsWeb) {
      debugPrint('FCM tokens only available on web platform');
      return null;
    }

    if (_fcmToken == null) {
      await _getFCMToken();
    }
    return _fcmToken;
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    debugPrint('Message data: ${message.data}');
    debugPrint('Message notification: ${message.notification?.title}');

    // Add to stream for UI updates
    _notificationStreamController.add(message);

    // Show notification in app
    _showNotificationInApp(message);
  }

  /// Handle notification tap when app is in background
  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    debugPrint('Message data: ${message.data}');

    // Navigate to specific screen based on notification data
    _navigateFromNotification(message);
  }

  /// Show notification in app (for foreground messages)
  void _showNotificationInApp(RemoteMessage message) {
    // Use Get.snackbar to show notification
    if (message.notification != null) {
      CommonSnackbar.notification(
        message: message.notification?.title ?? 'Notification',
        descrption: message.notification?.body ?? '',
      );
    }
  }

  /// Navigate based on notification data
  void _navigateFromNotification(RemoteMessage message) {
    final data = message.data;

    if (data.containsKey('type')) {
      final type = data['type'];
      switch (type) {
        case 'weekly_riddle':
          break;
        case 'user':
          break;
        default:
          break;
      }
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    if (!kIsWeb) {
      debugPrint('Topic subscription only available on web platform');
      return;
    }

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!kIsWeb) {
      debugPrint('Topic unsubscription only available on web platform');
      return;
    }

    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }
}

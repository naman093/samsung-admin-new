import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:samsung_admin_main_new/app/common/services/supabase_service.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_consts.dart';

class NotificationSenderService {
  static String? get _serverKey => dotenv.env['FCM_SERVER_KEY'];
  static const String _fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

  /// Check if we should use Supabase Edge Function or direct FCM API
  static bool get _useSupabaseEdgeFunction {
    // Prefer Supabase Edge Function if available
    return AppConsts.supabaseUrl.isNotEmpty;
  }

  /// Send a notification to a specific device using FCM token
  ///
  /// [fcmToken] - The FCM token of the target device
  /// [title] - Notification title
  /// [body] - Notification body
  /// [data] - Additional data payload (optional)
  /// [imageUrl] - URL of image to show in notification (optional)
  static Future<bool> sendToDevice({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    // Try Supabase Edge Function first (more secure)
    if (_useSupabaseEdgeFunction) {
      final success = await _sendViaSupabaseEdgeFunction(
        fcmToken: fcmToken,
        title: title,
        body: body,
        data: data,
        imageUrl: imageUrl,
      );
      if (success) return true;
      // Fall back to direct FCM if Edge Function fails
    }

    // Fallback to direct FCM API (requires server key)
    return await _sendViaDirectFCM(
      fcmToken: fcmToken,
      title: title,
      body: body,
      data: data,
      imageUrl: imageUrl,
    );
  }

  /// Send notification via Supabase Edge Function (Recommended)
  static Future<bool> _sendViaSupabaseEdgeFunction({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      final supabaseUrl = AppConsts.supabaseUrl;
      if (supabaseUrl.isEmpty) {
        debugPrint('Supabase URL not configured');
        return false;
      }

      final edgeFunctionUrl = '$supabaseUrl/functions/v1/send-notification';

      // Get access token from current session
      final currentSession = SupabaseService.client.auth.currentSession;
      final token = currentSession?.accessToken ?? AppConsts.supabaseAnonKey;

      final response = await http
          .post(
            Uri.parse(edgeFunctionUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'apikey': AppConsts.supabaseAnonKey,
            },
            body: jsonEncode({
              'fcm_token': fcmToken,
              'title': title,
              'body': body,
              'data': data ?? {},
              if (imageUrl != null) 'image_url': imageUrl,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Notification sent successfully via Supabase Edge Function');
        return true;
      } else {
        debugPrint(
          'Edge Function error: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error sending via Supabase Edge Function: $e');
      return false;
    }
  }

  /// Send notification via direct FCM API (requires server key)
  static Future<bool> _sendViaDirectFCM({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    if (_serverKey == null || _serverKey!.isEmpty) {
      debugPrint(
        'Error: FCM_SERVER_KEY not found in .env file.\n'
        'SOLUTION: Create a Supabase Edge Function to send notifications securely.\n'
        'See FIREBASE_SETUP.md for instructions.',
      );
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'to': fcmToken,
          'notification': {
            'title': title,
            'body': body,
            if (imageUrl != null) 'image': imageUrl,
          },
          'data': data ?? {},
          'priority': 'high',
          'webpush': {
            'notification': {
              'title': title,
              'body': body,
              'icon': '/icons/Icon-192.png',
              if (imageUrl != null) 'image': imageUrl,
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == 1) {
          debugPrint('Notification sent successfully');
          return true;
        } else {
          debugPrint('Failed to send notification: ${responseData['results']}');
          return false;
        }
      } else {
        debugPrint(
          'Error sending notification: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Exception sending notification: $e');
      return false;
    }
  }

  /// Send a notification to multiple devices
  ///
  /// [fcmTokens] - List of FCM tokens
  /// [title] - Notification title
  /// [body] - Notification body
  /// [data] - Additional data payload (optional)
  /// [imageUrl] - URL of image to show in notification (optional)
  static Future<Map<String, bool>> sendToMultipleDevices({
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    final results = <String, bool>{};

    for (final token in fcmTokens) {
      final success = await sendToDevice(
        fcmToken: token,
        title: title,
        body: body,
        data: data,
        imageUrl: imageUrl,
      );
      results[token] = success;
    }

    return results;
  }

  /// Send a notification to a topic
  ///
  /// [topic] - The topic to send to (e.g., 'all_users', 'admin')
  /// [title] - Notification title
  /// [body] - Notification body
  /// [data] - Additional data payload (optional)
  /// [imageUrl] - URL of image to show in notification (optional)
  static Future<bool> sendToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    // Try Supabase Edge Function first
    if (_useSupabaseEdgeFunction) {
      try {
        final supabaseUrl = AppConsts.supabaseUrl;
        final edgeFunctionUrl =
            '$supabaseUrl/functions/v1/send-notification-topic';

        final currentSession = SupabaseService.client.auth.currentSession;
        final token = currentSession?.accessToken ?? AppConsts.supabaseAnonKey;

        final response = await http.post(
          Uri.parse(edgeFunctionUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'apikey': AppConsts.supabaseAnonKey,
          },
          body: jsonEncode({
            'topic': topic,
            'title': title,
            'body': body,
            'data': data ?? {},
            if (imageUrl != null) 'image_url': imageUrl,
          }),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        }
      } catch (e) {
        debugPrint('Error sending to topic via Edge Function: $e');
      }
    }

    // Fallback to direct FCM
    if (_serverKey == null || _serverKey!.isEmpty) {
      debugPrint(
        'Error: FCM_SERVER_KEY not found. Use Supabase Edge Function instead.',
      );
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'to': '/topics/$topic',
          'notification': {
            'title': title,
            'body': body,
            if (imageUrl != null) 'image': imageUrl,
          },
          'data': data ?? {},
          'priority': 'high',
          'webpush': {
            'notification': {
              'title': title,
              'body': body,
              'icon': '/icons/Icon-192.png',
              if (imageUrl != null) 'image': imageUrl,
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == 1) {
          debugPrint('Notification sent to topic successfully');
          return true;
        } else {
          debugPrint(
            'Failed to send notification to topic: ${responseData['results']}',
          );
          return false;
        }
      } else {
        debugPrint(
          'Error sending notification to topic: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Exception sending notification to topic: $e');
      return false;
    }
  }

  /// Send a data-only notification (no notification UI, just data)
  ///
  /// [fcmToken] - The FCM token of the target device
  /// [data] - Data payload
  static Future<bool> sendDataOnly({
    required String fcmToken,
    required Map<String, dynamic> data,
  }) async {
    // Try Supabase Edge Function first
    if (_useSupabaseEdgeFunction) {
      try {
        final supabaseUrl = AppConsts.supabaseUrl;
        final edgeFunctionUrl = '$supabaseUrl/functions/v1/send-notification';

        final currentSession = SupabaseService.client.auth.currentSession;
        final token = currentSession?.accessToken ?? AppConsts.supabaseAnonKey;

        final response = await http.post(
          Uri.parse(edgeFunctionUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'apikey': AppConsts.supabaseAnonKey,
          },
          body: jsonEncode({
            'fcm_token': fcmToken,
            'data_only': true,
            'data': data,
          }),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        }
      } catch (e) {
        debugPrint('Error sending data via Edge Function: $e');
      }
    }

    // Fallback to direct FCM
    if (_serverKey == null || _serverKey!.isEmpty) {
      debugPrint(
        'Error: FCM_SERVER_KEY not found. Use Supabase Edge Function instead.',
      );
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({'to': fcmToken, 'data': data, 'priority': 'high'}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == 1) {
          debugPrint('Data-only notification sent successfully');
          return true;
        } else {
          debugPrint(
            'Failed to send data-only notification: ${responseData['results']}',
          );
          return false;
        }
      } else {
        debugPrint(
          'Error sending data-only notification: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Exception sending data-only notification: $e');
      return false;
    }
  }
}

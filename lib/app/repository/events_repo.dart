import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_consts.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/common/services/storage_service.dart';
import 'package:samsung_admin_main_new/app/common/services/supabase_service.dart';
import 'package:samsung_admin_main_new/app/models/event_model.dart';
import 'package:samsung_admin_main_new/app/models/event_registration_model.dart';
import 'package:samsung_admin_main_new/app/models/eventer_event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<EventListResponse> fetchEventListWithPagination({
    String searchTerm = '',
    int pageNumber = 1,
    int perPage = 8,
  }) async {
    try {
      final from = (pageNumber - 1) * perPage;
      final to = from + perPage - 1;
      final searchPattern = '%$searchTerm%';

      final countResponse = await supabase
          .from('events')
          .select('*')
          .eq('event_type', 'live_event')
          .or('title.ilike.$searchPattern,description.ilike.$searchPattern')
          .or('deleted_at.is.null')
          .order('created_at', ascending: false);

      final totalCount = (countResponse as List).length;
      final totalPages = totalCount == 0 ? 1 : (totalCount / perPage).ceil();

      final response = await supabase
          .from('events')
          .select('*')
          .eq('event_type', 'live_event')
          .or('title.ilike.$searchPattern,description.ilike.$searchPattern')
          .or('deleted_at.is.null')
          .order('created_at', ascending: false)
          .range(from, to);

      final data = (response as List)
          .map((e) => EventModel.fromJson(e))
          .toList();

      return EventListResponse.save(
        totalCount: totalCount,
        totalPages: totalPages,
        pageNumber: pageNumber,
        data: data,
      );
    } catch (e) {
      debugPrint('❌ fetchEventListWithPagination Error: $e');
      return EventListResponse.save(
        totalCount: 0,
        totalPages: 1,
        pageNumber: pageNumber,
        data: [],
      );
    }
  }

  static Future<Result<EventModel>> createEvent(
    String title,
    String eventDate,
    String description,
    String endDate,
    String creditCost,
    String costInPoints,
    String maxTickets,
    Uint8List fileBytes,
    String fileName,
    Uint8List? explanatoryVideoOptional,
    String? explanatoryVideoOptionalName, {
    String? eventerId,
    String? eventType,
    String? status,
  }) async {
    try {
      final userId = SupabaseService.currentUser?.id ?? 'anonymous';
      final imageUrl = await StorageService.uploadMediaBytes(
        bytes: fileBytes,
        userId: userId,
        bucketName: 'content',
        mediaType: MediaType.video,
        customFileName: fileName,
      );
      String? explanatoryVideoOptionalUrl;
      if (explanatoryVideoOptional != null) {
        explanatoryVideoOptionalUrl = await StorageService.uploadMediaBytes(
          bytes: explanatoryVideoOptional,
          userId: userId,
          bucketName: 'content',
          mediaType: MediaType.video,
          customFileName: explanatoryVideoOptionalName,
        );
      }
      final Map<String, dynamic> insertData = {
        'title': title,
        'event_date': eventDate,
        'description': description,
        'end_date': endDate,
        'cost_credit_cents': creditCost.isNotEmpty ? creditCost : 0,
        'cost_points': costInPoints.isNotEmpty ? costInPoints : 0,
        'max_tickets': maxTickets.isNotEmpty ? int.parse(maxTickets) : null,
        'event_type': 'live_event',
        'image_url': imageUrl,
        'video_url': explanatoryVideoOptionalUrl,
        'type': eventType,
      };

      // Add eventer_id if provided
      if (eventerId != null && eventerId.isNotEmpty) {
        insertData['external_id'] = eventerId;
      }

      // Add status if provided
      if (status != null && status.isNotEmpty) {
        insertData['status'] = status;
      }

      final response = await SupabaseService.client
          .from('events')
          .insert(insertData)
          .select()
          .single();
      return Success(EventModel.fromJson(response));
    } catch (e) {
      debugPrint(e.toString());
      debugPrint('🔥 Exception occurred in createEvent');
      return Failure(e.toString());
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      final response = await SupabaseService.client
          .from('events')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .select()
          .single();
      if (response['deleted_at'] != null) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('🔥 Exception occurred in deleteContent $e');
      return false;
    }
  }

  Future<bool> toggleEventStatus(String id, String currentStatus) async {
    try {
      final newStatus = currentStatus.toLowerCase() == 'active'
          ? 'inactive'
          : 'active';
      final response = await SupabaseService.client
          .from('events')
          .update({'status': newStatus})
          .eq('id', id)
          .select()
          .single();
      if (response['status'] == newStatus) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('🔥 Exception occurred in toggleEventStatus $e');
      return false;
    }
  }

  static Future<Result<EventModel>> updateEvent(
    String eventId,
    String title,
    String description,
    String validity,
    String creditCost,
    String costInPoints,
    String maxTickets,
    String eventDate,
    Uint8List fileBytes,
    String fileName,
    Uint8List? explanatoryVideoOptional,
    String? explanatoryVideoOptionalName,
    bool shouldRemoveVideo,
  ) async {
    final userId = SupabaseService.currentUser?.id ?? 'anonymous';
    final imageUrl = await StorageService.uploadMediaBytes(
      bytes: fileBytes,
      userId: userId,
      bucketName: 'content',
      mediaType: MediaType.video,
      customFileName: fileName,
    );
    String? explanatoryVideoOptionalUrl;
    if (explanatoryVideoOptional != null) {
      explanatoryVideoOptionalUrl = await StorageService.uploadMediaBytes(
        bytes: explanatoryVideoOptional,
        userId: userId,
        bucketName: 'content',
        mediaType: MediaType.video,
        customFileName: explanatoryVideoOptionalName,
      );
    }

    try {
      final updateData = <String, dynamic>{
        'title': title,
        'description': description,
        'end_date': validity,
        'cost_credit_cents': creditCost,
        'cost_points': costInPoints,
        'max_tickets': maxTickets.isNotEmpty ? int.parse(maxTickets) : null,
        'event_date': eventDate,
        if (imageUrl != null) 'image_url': imageUrl,
      };

      // Handle video_url: remove if explicitly removed, update if new file uploaded, keep existing if neither
      if (shouldRemoveVideo) {
        updateData['video_url'] = null;
      } else if (explanatoryVideoOptionalUrl != null) {
        updateData['video_url'] = explanatoryVideoOptionalUrl;
      }

      final response = await SupabaseService.client
          .from('events')
          .update(updateData)
          .eq('id', eventId)
          .select()
          .single();
      return Success(EventModel.fromJson(response));
    } catch (e) {
      debugPrint('❌ updateFile Error: $e');
      return Failure(e.toString());
    }
  }

  Future<List<EventRegistrationModel>> fetchEventRegistrations(
    String eventId,
  ) async {
    try {
      final response = await SupabaseService.client
          .from('event_registrations')
          .select('''
            *,
            users:user_id (
              full_name,
              phone_number
            )
          ''')
          .eq('event_id', eventId)
          .isFilter('deleted_at', null)
          .order('registered_at', ascending: false);

      final data = (response as List).map((e) {
        // Flatten user data
        final userData = e['users'];
        if (userData != null) {
          e['user_full_name'] = userData['full_name'];
          e['user_phone_number'] = userData['phone_number'];
        }
        return EventRegistrationModel.fromJson(e);
      }).toList();

      return data;
    } catch (e) {
      debugPrint('❌ fetchEventRegistrations Error: $e');
      return [];
    }
  }

  Future<EventRegistrationModel?> getEventRegistrationById(
    String registrationId,
  ) async {
    try {
      final response = await SupabaseService.client
          .from('event_registrations')
          .select('''
            *,
            users:user_id (
              full_name,
              phone_number
            )
          ''')
          .eq('id', registrationId)
          .maybeSingle();

      if (response == null) return null;

      // Flatten user data
      final userData = response['users'];
      if (userData != null) {
        response['user_full_name'] = userData['full_name'];
        response['user_phone_number'] = userData['phone_number'];
      }

      return EventRegistrationModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ getEventRegistrationById Error: $e');
      return null;
    }
  }

  Future<bool> cancelEventRegistration(String registrationId) async {
    try {
      final response = await SupabaseService.client
          .from('event_registrations')
          .update({
            'status': 'cancelled',
            'deleted_at': DateTime.now().toIso8601String(),
          })
          .eq('id', registrationId)
          .select()
          .single();

      if (response['deleted_at'] != null) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('🔥 Exception occurred in cancelEventRegistration $e');
      return false;
    }
  }

  Future<List<EventerEventModel>> fetchEventsFromEventer() async {
    try {
      final token = supabase.auth.currentSession?.accessToken;
      final FunctionResponse response = await supabase.functions.invoke(
        'eventer-events',
        method: HttpMethod.get,
        headers: {
          'Authorization': 'Bearer $token',
          'apikey': AppConsts.supabaseAnonKey,
          'Content-Type': 'application/json',
        },
      );

      debugPrint(
        'response::   ${response.status},  --------  ${response.data}',
      );

      if (response.status != 200) {
        debugPrint('❌ Edge Function Error: ${response.data}');
        return [];
      }

      if (response.data == null) {
        debugPrint('❌ No data received from Eventer API');
        return [];
      }

      // Parse the response data
      final List<dynamic> eventsList = response.data is List
          ? response.data as List<dynamic>
          : [];

      final events = eventsList
          .map(
            (json) => EventerEventModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      debugPrint('✅ Fetched ${events.length} events from Eventer');
      return events;
    } catch (e) {
      debugPrint('❌ fetchEventsFromEventer Error: $e');
      return [];
    }
  }
}

class EventListResponse {
  final int totalCount;
  final int totalPages;
  final int pageNumber;
  final List<EventModel> data;

  EventListResponse.save({
    required this.totalCount,
    required this.totalPages,
    required this.pageNumber,
    required this.data,
  });
}

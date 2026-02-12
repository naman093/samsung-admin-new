import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_consts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../common/services/storage_service.dart';
import '../common/services/supabase_service.dart';
import '../models/academy_content_view_model.dart';
import '../models/assignment_submission_model.dart';

class AcademyRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String?> uploadFile(Uint8List fileBytes, MediaType mediaType) async {
    try {
      final userId = supabase.auth.currentUser?.id ?? 'anonymous';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = mediaType == MediaType.image ? 'jpg' : 'mp4';
      final uniqueFileName = '${userId}_${timestamp}.$extension';
      final mediaUrl = await StorageService.uploadMediaBytes(
        userId: userId,
        bucketName: 'content',
        bytes: fileBytes,
        mediaType: mediaType,
        customFileName: uniqueFileName,
      );
      return mediaUrl;
    } catch (e) {
      debugPrint('❌ uploadFile Error: $e');
      return null;
    }
  }

  // Future<VODPodcastListResponse> fetchAcademyViewListWithPagination({
  //   String searchTerm = '',
  //   String shortBy = 'all',
  //   int pageNumber = 1,
  //   int perPage = 8,
  //   String? startDate,
  //   String? endDate,
  // }) async {
  //   try {
  //     final from = (pageNumber - 1) * perPage;
  //     final to = from + perPage - 1;
  //     final searchPattern = '%$searchTerm%';
  //
  //     final countResponse = await supabase.from('v_academy_content_full').select('academy_content_id')
  //         .or(
  //           'file_type.eq.video,file_type.eq.zoom_workshop,file_type.eq.assignment,file_type.eq.reel',
  //         )
  //         .or('creator_full_name.ilike.$searchPattern,title.ilike.$searchPattern,description.ilike.$searchPattern');
  //
  //     final totalCount = (countResponse as List).length;
  //     final totalPages = totalCount == 0 ? 1 : (totalCount / perPage).ceil();
  //
  //     final response = await supabase.from('v_academy_content_full').select('*')
  //         .or(
  //           'file_type.eq.video,file_type.eq.zoom_workshop,file_type.eq.assignment,file_type.eq.reel',
  //         )
  //         .or('creator_full_name.ilike.$searchPattern,title.ilike.$searchPattern,description.ilike.$searchPattern')
  //         .order(shortBy == 'all' ? 'academy_content_id' : shortBy, ascending: true)
  //         .range(from, to);
  //
  //     final data = (response as List).map((e) => AcademyContentViewModel.fromJson(e)).toList();
  //
  //     return VODPodcastListResponse.save(
  //       totalCount: totalCount,
  //       totalPages: totalPages,
  //       pageNumber: pageNumber,
  //       data: data,
  //     );
  //   } catch (e) {
  //     debugPrint('❌ fetchAcademyListWithPagination Error: $e');
  //     return VODPodcastListResponse.save(
  //       totalCount: 0,
  //       totalPages: 1,
  //       pageNumber: pageNumber,
  //       data: [],
  //     );
  //   }
  // }

  Future<VODPodcastListResponse> fetchAcademyViewListWithPagination({
    String searchTerm = '',
    String shortBy = 'all',
    int pageNumber = 1,
    int perPage = 8,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final from = (pageNumber - 1) * perPage;
      final to = from + perPage - 1;
      final searchPattern = '%$searchTerm%';

      String toIso(String date) {
        final parts = date.split('-');
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        ).toIso8601String();
      }

      final fileTypeFilter =
          'file_type.eq.video,file_type.eq.zoom_workshop,file_type.eq.assignment,file_type.eq.reel';

      final searchFilter =
          'creator_full_name.ilike.$searchPattern,'
          'title.ilike.$searchPattern,'
          'description.ilike.$searchPattern';

      var baseQuery = supabase
          .from('v_academy_content_full')
          .select('*')
          .or(fileTypeFilter)
          .or(searchFilter);

      if (startDate != null &&
          endDate != null &&
          startDate.isNotEmpty &&
          endDate.isNotEmpty) {
        baseQuery = baseQuery
            .gte('created_at', toIso(startDate))
            .lte('created_at', toIso(endDate));
      }

      final countResponse = await supabase
          .from('v_academy_content_full')
          .select('academy_content_id')
          .or(fileTypeFilter)
          .or(searchFilter);

      final totalCount = (countResponse as List).length;
      final totalPages = totalCount == 0 ? 1 : (totalCount / perPage).ceil();

      final response = await baseQuery
          .order(
            // shortBy == 'all' ? 'academy_content_id' : shortBy,
            'created_at',
            ascending: false,
          )
          .range(from, to);

      final data = (response as List)
          .map((e) => AcademyContentViewModel.fromJson(e))
          .toList();

      return VODPodcastListResponse.save(
        totalCount: totalCount,
        totalPages: totalPages,
        pageNumber: pageNumber,
        data: data,
      );
    } catch (e) {
      debugPrint('❌ fetchAcademyViewListWithPagination Error: $e');
      return VODPodcastListResponse.save(
        totalCount: 0,
        totalPages: 1,
        pageNumber: pageNumber,
        data: [],
      );
    }
  }

  Future<bool> deleteAcademyContent(String id) async {
    try {
      await SupabaseService.client
          .from('academy_content')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .select()
          .single();
      return true;
    } catch (e) {
      debugPrint('🔥 Exception occurred in deleteContent');
      return false;
    }
  }

  Future<bool> createAcademyContent({
    required String academyFileType,
    required String title,
    String? description,
    String? mediaFileUrl,
    int pointsToEarn = 0,
    Map<String, dynamic>? assignment,
    Map<String, dynamic>? event,
  }) async {
    try {
      final payload = {
        'academy_file_type': academyFileType,
        'title': title,
        'description': description,
        'media_file_url': mediaFileUrl,
        'points_to_earn': pointsToEarn,
        'created_by': supabase.auth.currentUser?.id,
        'assignment': assignment,
        'event': event,
      };

      final token = supabase.auth.currentSession?.accessToken;
      FunctionResponse response = await supabase.functions.invoke(
        'create-academy-content',
        method: HttpMethod.post,
        headers: {
          'Authorization': 'Bearer $token',
          'apikey': AppConsts.supabaseAnonKey,
          'Content-Type': 'application/json',
        },
        body: payload,
      );
      debugPrint(
        'response::   ${response.status},  --------  ${response.data}',
      );

      if (response.status != 200) {
        debugPrint('❌ Edge Function Error: ${response.data}');
        return false;
      }

      debugPrint('✅ Academy content created successfully');
      return true;
    } catch (e) {
      CommonSnackbar.error('Exception: $e');
      debugPrint('🔥 createAcademyContent Exception: $e');
      return false;
    }
  }

  Future<bool> updateAcademyContent({
    required String academyContentId,
    String? title,
    String? description,
    String? mediaFileUrl,
    int? pointsToEarn,
    Map<String, dynamic>? assignment,
    Map<String, dynamic>? event,
  }) async {
    try {
      final payload = {
        'academy_content_id': academyContentId,
        'title': title,
        'description': description,
        'media_file_url': mediaFileUrl,
        'points_to_earn': pointsToEarn,
        'assignment': assignment,
        'event': event,
      };

      final token = supabase.auth.currentSession?.accessToken;

      FunctionResponse response = await supabase.functions.invoke(
        'update-academy-content',
        method: HttpMethod.post,
        headers: {
          'Authorization': 'Bearer $token',
          'apikey': AppConsts.supabaseAnonKey,
          'Content-Type': 'application/json',
        },
        body: payload,
      );

      debugPrint(
        'response::   ${response.status},  --------  ${response.data}',
      );

      if (response.status != 200) {
        debugPrint('❌ Edge Function Error: ${response.data}');
        return false;
      }

      debugPrint('✅ Academy content updated successfully');
      return true;
    } catch (e) {
      CommonSnackbar.error('Exception: $e');
      debugPrint('🔥 updateAcademyContent Exception: $e');
      return false;
    }
  }

  Future<AssignmentSubmissionListResponse> getAssignmentSubmissions({
    required String assignmentId,
  }) async {
    try {
      print('assignmentId:::  $assignmentId');

      final res = await supabase
          .from('v_assignment_submissions?assignment_id=eq.$assignmentId')
          .select('*')
          .order('submission_created_at', ascending: false);

      final data = (res as List)
          .map((e) => AssignmentSubmissionModel.fromJson(e))
          .toList();

      print('data:::  ${data.length}');

      return AssignmentSubmissionListResponse.save(
        totalCount: data.length,
        data: data,
        totalPages: 0,
        pageNumber: 0,
      );
    } catch (e, st) {
      debugPrint('❌ getRiddleSubmissions Error: $e');
      debugPrint(st.toString());
      return AssignmentSubmissionListResponse.save(
        totalCount: 0,
        data: [],
        totalPages: 0,
        pageNumber: 0,
      );
    }
  }

  Future<bool> verifySubmission({
    required String submissionId,
    required bool status,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('assignment_submissions')
          .update({'is_correct': status})
          .eq('id', submissionId)
          .select()
          .single();

      debugPrint('Submission verification successful: $response');
      CommonSnackbar.success('Submission verification successful');
      return true;
    } catch (e) {
      CommonSnackbar.error('Submission verification failed');
      debugPrint('❌ verifySubmission Error: $e');
      return false;
    }
  }
}

class VODPodcastListResponse {
  final int totalCount;
  final int totalPages;
  final int pageNumber;
  final List<AcademyContentViewModel> data;

  VODPodcastListResponse.save({
    required this.totalCount,
    required this.totalPages,
    required this.pageNumber,
    required this.data,
  });
}

class AssignmentSubmissionListResponse {
  final int totalCount;
  final int totalPages;
  final int pageNumber;
  final List<AssignmentSubmissionModel> data;

  AssignmentSubmissionListResponse.save({
    required this.totalCount,
    required this.totalPages,
    required this.pageNumber,
    required this.data,
  });
}

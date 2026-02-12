import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/common/services/storage_service.dart';
import 'package:samsung_admin_main_new/app/common/services/supabase_service.dart';
import 'package:samsung_admin_main_new/app/models/riddle_submission_model.dart';
import 'package:samsung_admin_main_new/app/models/weekly_riddle_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WeeklyRiddleRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  static Future<Result<WeeklyRiddleModel>> createRiddle({
    required String solutionType,
    required String startDate,
    required String endDate,
    required String endTime,
    required String missionEndTime,
    required String pointsToEarn,
    required String title,
    required String description,
    required String correctAnswer,
    required List<String> options,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final userId = SupabaseService.currentUser?.id ?? 'anonymous';
      final mediaUrl = await StorageService.uploadMediaBytes(
        bytes: fileBytes,
        userId: userId,
        bucketName: 'weekly_riddle_files',
        mediaType: MediaType.audio,
        customFileName: fileName,
      );
      final response = await SupabaseService.client
          .from('weekly_riddles')
          .insert({
            'type': solutionType,
            'start_date': startDate,
            'end_date': endDate,
            'end_time': endTime,
            'points_to_earn': int.tryParse(pointsToEarn) ?? 0,
            'title': title,
            'description': description,
            'answer': solutionType == 'Audio' ? mediaUrl : correctAnswer,
            'question': solutionType == 'MCQ' ? options : '',
          })
          .select()
          .single();

      debugPrint(response.toString());
      return Success(WeeklyRiddleModel.fromJson(response));
    } catch (e) {
      debugPrint(e.toString());
      return Failure(e.toString());
    }
  }

  static Future<Result<WeeklyRiddleModel>> updateRiddle({
    required String riddleId,
    required String title,
    required String description,
    required String startDate,
    required String solutionType,
    required String endDate,
    required String endTime,
    required String pointsToEarn,
    required String correctAnswer,
    required List<String> options,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final userId = SupabaseService.currentUser?.id ?? 'anonymous';
      final mediaUrl = await StorageService.uploadMediaBytes(
        bytes: fileBytes,
        userId: userId,
        bucketName: 'weekly_riddle_files',
        mediaType: MediaType.audio,
        customFileName: fileName,
      );
      final response = await SupabaseService.client
          .from('weekly_riddles')
          .update({
            'type': solutionType,
            'start_date': startDate,
            'end_date': endDate,
            'end_time': endTime,
            'points_to_earn': int.tryParse(pointsToEarn) ?? 0,
            'title': title,
            'description': description,
            'answer': solutionType == 'Audio' ? mediaUrl : correctAnswer,
            'question': solutionType == 'MCQ' ? options : '',
          })
          .eq('id', riddleId)
          .select()
          .single();

      debugPrint(response.toString());
      return Success(WeeklyRiddleModel.fromJson(response));
    } catch (e) {
      debugPrint(e.toString());
      return Failure(e.toString());
    }
  }

  Future<bool> deleteRiddle(String id) async {
    try {
      final response = await SupabaseService.client
          .from('weekly_riddles')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .select()
          .single();
      if (response['deleted_at'] != null) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('🔥 Exception occurred in deleteRiddle $e');
      return false;
    }
  }

  Future<WeeklyRiddleListResponse> getWeeklyRiddlesWithPagination({
    String searchTerm = '',
    int pageNumber = 1,
    String shortBy = 'all',
    int perPage = 8,
  }) async {
    try {
      final from = (pageNumber - 1) * perPage;
      final to = from + perPage - 1;
      final searchPattern = '%$searchTerm%';

      final allowedTypes = {'Text', 'Audio', 'MCQ'};
      final normalizedShortBy = shortBy.trim();
      final shouldFilterByType = allowedTypes.contains(normalizedShortBy);
      var countQuery = SupabaseService.client
          .from('weekly_riddles')
          .select('*')
          .or('title.ilike.$searchPattern,description.ilike.$searchPattern')
          .or('deleted_at.is.null');

      if (shouldFilterByType) {
        countQuery = countQuery.eq('type', normalizedShortBy);
      }

      final countResponse = await countQuery;

      final totalCount = (countResponse as List).length;
      final totalPages = totalCount == 0 ? 1 : (totalCount / perPage).ceil();

      var responseQuery = SupabaseService.client
          .from('weekly_riddles')
          .select()
          .or('deleted_at.is.null')
          .or('title.ilike.$searchPattern,description.ilike.$searchPattern');

      if (shouldFilterByType) {
        responseQuery = responseQuery.eq('type', normalizedShortBy);
      }

      final response = await responseQuery.order('created_at', ascending: false).range(from, to);

      final data = (response as List)
          .map((e) => WeeklyRiddleModel.fromJson(e))
          .toList();



      return WeeklyRiddleListResponse.save(
        totalCount: totalCount,
        totalPages: totalPages,
        pageNumber: pageNumber,
        data: data,
      );
    } catch (e) {
      debugPrint(e.toString());
      debugPrint('❌ fetchAcademyViewListWithPagination Error: $e');
      return WeeklyRiddleListResponse.save(
        totalCount: 0,
        totalPages: 1,
        pageNumber: pageNumber,
        data: [],
      );
    }
  }

  // Future<RiddleSubmissionListResponse> getRiddleSubmissions({String riddleId = ''}) async {
  //   try {
  //     final res = await supabase
  //         .from('riddle_submissions')
  //         .select('*')
  //         .eq('riddle_id', riddleId)
  //         .or('deleted_at.is.null')
  //         .order('submitted_at', ascending: false);
  //
  //     final data = (res as List).map((e) => RiddleSubmissionModel.fromJson(e)).toList();
  //     debugPrint('$data data submit');
  //     return RiddleSubmissionListResponse.save(
  //       totalCount: (res as List).length,
  //       data: data,
  //     );
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     debugPrint('❌ getRiddleSubmissions Error: $e');
  //     return RiddleSubmissionListResponse.save(totalCount: 0, data: []);
  //   }
  // }

  Future<RiddleSubmissionListResponse> getRiddleSubmissions({String riddleId = ''}) async {
    try {
      final res = await supabase
          .from('v_riddle_submissions?riddle_id=eq.$riddleId')
          .select('*')
          .order('submitted_at', ascending: false);

      final data = (res as List)
          .map((e) => RiddleSubmissionModel.fromJson(e))
          .toList();

      return RiddleSubmissionListResponse.save(
        totalCount: data.length,
        data: data,
      );
    } catch (e, st) {
      debugPrint('❌ getRiddleSubmissions Error: $e');
      debugPrint(st.toString());
      return RiddleSubmissionListResponse.save(
        totalCount: 0,
        data: [],
      );
    }
  }

  Future<bool> checkRiddleForCurrentWeek() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(Duration(days: 6));

      final startStr = DateFormat('yyyy-MM-dd').format(startOfWeek);
      final endStr = DateFormat('yyyy-MM-dd').format(endOfWeek);

      debugPrint('startStr: $startStr');
      debugPrint('endStr: $endStr');

      final response = await SupabaseService.client
          .from('weekly_riddles')
          .select('id')
          .gte('start_date', startStr)
          .lte('start_date', endStr)
          .or('deleted_at.is.null');


      return (response as List).isNotEmpty;
    } catch (e) {
      debugPrint('❌ checkRiddleForCurrentWeek Error: $e');
      return false;
    }
  }

  Future<Result<bool>> updateSubmissionStatus({
    required String submissionId,
    required bool isCorrect,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('riddle_submissions')
          .update({'is_correct': isCorrect})
          .eq('id', submissionId)
          .select()
          .single();

      debugPrint('Submission updated: $response');
      return Success(true);
    } catch (e) {
      debugPrint('❌ updateSubmissionStatus Error: $e');
      return Failure(e.toString());
    }
  }

  Future<bool> verifySubmission({
    required String submissionId,
    required bool status,
  }) async {
    try {
      final response = await SupabaseService.client.from('riddle_submissions').update({'is_correct': status})
          .eq('id', submissionId)
          .select().single();

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

class RiddleSubmissionListResponse {
  final int totalCount;
  final List<RiddleSubmissionModel> data;

  RiddleSubmissionListResponse.save({
    required this.totalCount,
    required this.data,
  });
}

class WeeklyRiddleListResponse {
  final int totalCount;
  final int totalPages;
  final int pageNumber;
  final List<WeeklyRiddleModel> data;

  WeeklyRiddleListResponse.save({
    required this.totalCount,
    required this.totalPages,
    required this.pageNumber,
    required this.data,
  });
}

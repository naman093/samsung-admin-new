import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/common/services/storage_service.dart';
import 'package:samsung_admin_main_new/app/common/services/supabase_service.dart';
import 'package:samsung_admin_main_new/app/models/content_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/comment_model.dart';
import '../models/content_full_details_model.dart';

class CommunityRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  static Future<Result<ContentModel>> createFeed(
    String title,
    String description,
    Uint8List fileBytes,
    String fileName,
    bool isSharedToCommunity,
  ) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id ?? 'anonymous';

      final mediaUrl = await StorageService.uploadMediaBytes(
        bytes: fileBytes,
        userId: userId,
        bucketName: 'content',
        mediaType: MediaType.image,
        customFileName: fileName,
      );

      final response = await SupabaseService.client
          .from('content')
          .insert({
            'title': title,
            'description': description,
            'user_id': userId,
            'content_type': 'feed',
            'media_file_url': mediaUrl,
            'is_shared_to_community': isSharedToCommunity,
          })
          .select()
          .single();
      return Success(ContentModel.fromJson(response));
    } catch (e) {
      debugPrint('🔥 Exception occurred in createFeed');
      return Failure(e.toString());
    }
  }

  // Future<CommunityListResponse> getFeedsWithPagination({
  //   int page = 1,
  //   int perPage = 8,
  //   String searchTerm = '',
  //   String shortBy = 'all',
  //   String? startDate,
  //   String? endDate,
  // }) async {
  //   try {
  //     final from = (page - 1) * perPage;
  //     final to = from + perPage - 1;
  //     final searchPattern = '%${searchTerm.trim()}%';
  //
  //     String toIso(String date) {
  //       final parts = date.split('-');
  //       return DateTime(
  //         int.parse(parts[2]),
  //         int.parse(parts[1]),
  //         int.parse(parts[0]),
  //       ).toIso8601String();
  //     }
  //
  //     final Map<String, String?> sortByColumnMap = {
  //       'all': null,
  //       'title': 'title',
  //       'description': 'description',
  //       'content_type': 'content_type',
  //       'author_name': 'author_name',
  //     };
  //
  //     var countQuery = SupabaseService.client
  //         .from('v_content_full_details')
  //         .select('content_id')
  //         .eq('content_type', 'feed')
  //         .or('deleted_at.is.null')
  //         .or(
  //           'author_name.ilike.$searchPattern,title.ilike.$searchPattern,description.ilike.$searchPattern',
  //         );
  //
  //     if (startDate != null &&
  //         startDate.isNotEmpty &&
  //         endDate != null &&
  //         endDate.isNotEmpty) {
  //       countQuery = countQuery
  //           .gte('created_at', toIso(startDate))
  //           .lte('created_at', toIso(endDate));
  //     }
  //
  //     final countResponse = await countQuery;
  //
  //     final totalCount = (countResponse as List).length;
  //     final totalPages = totalCount == 0 ? 1 : (totalCount / perPage).ceil();
  //
  //     final sortColumn = sortByColumnMap[shortBy];
  //     var dataQuery = SupabaseService.client
  //         .from('v_content_full_details')
  //         .select('*')
  //         .eq('content_type', 'feed')
  //         .or(
  //           'author_name.ilike.$searchPattern,title.ilike.$searchPattern,description.ilike.$searchPattern',
  //         )
  //         .or('deleted_at.is.null');
  //
  //     if (startDate != null &&
  //         startDate.isNotEmpty &&
  //         endDate != null &&
  //         endDate.isNotEmpty) {
  //       dataQuery = dataQuery
  //           .gte('created_at', toIso(startDate))
  //           .lte('created_at', toIso(endDate));
  //     }
  //
  //     final response = await dataQuery
  //         .order(sortColumn ?? 'content_id', ascending: true)
  //         .range(from, to);
  //
  //     final data = (response as List)
  //         .map(
  //           (json) =>
  //               ContentFullDetailsModel.fromJson(json as Map<String, dynamic>),
  //         )
  //         .toList();
  //
  //     return CommunityListResponse.save(
  //       totalCount: totalCount,
  //       totalPages: totalPages,
  //       pageNumber: page,
  //       data: data,
  //     );
  //   } catch (e) {
  //     debugPrint('🔥 Exception occurred in getFeeds: $e');
  //     return CommunityListResponse.save(
  //       totalCount: 0,
  //       totalPages: 0,
  //       pageNumber: page,
  //       data: [],
  //     );
  //   }
  // }

  Future<bool> toggleLike(String contentId) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return false;

      final existingLike = await SupabaseService.client
          .from('content_likes')
          .select()
          .eq('content_id', contentId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike == null) {
        await SupabaseService.client.from('content_likes').insert({
          'content_id': contentId,
          'user_id': userId,
        });
      } else {
        await SupabaseService.client
            .from('content_likes')
            .delete()
            .eq('content_id', contentId)
            .eq('user_id', userId);
      }
      return true;
    } catch (e) {
      debugPrint('🔥 Error in toggleLike: $e');
      return false;
    }
  }

  Future<bool> addComment(String contentId, String commentText) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return false;

      await SupabaseService.client.from('content_comments').insert({
        'content_id': contentId,
        'user_id': userId,
        'content': commentText,
      });
      return true;
    } catch (e) {
      debugPrint('🔥 Error in addComment: $e');
      return false;
    }
  }

  Future<List<ContentCommentViewModel>> getComments(String contentId) async {
    try {
      final response = await SupabaseService.client
          .from('v_content_comment')
          .select('*')
          .eq('content_id', contentId)
          .order('comment_created_at', ascending: false);

      return (response as List).map((json) {
        try {
          return ContentCommentViewModel.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          debugPrint('🔥 Error parsing comment: $e\nComment data: $json');
          rethrow;
        }
      }).toList();
    } catch (e) {
      debugPrint('🔥 Error fetching comments from view: $e');
      return [];
    }
  }

  Future<CommunityListResponse> getFeedsWithPagination({
    int page = 1,
    int perPage = 8,
    String searchTerm = '',
    String shortBy = 'all',
    String? startDate,
    String? endDate,
  }) async {
    String toIso(String date) {
      final parts = date.split('-');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      ).toIso8601String();
    }

    debugPrint(
      '🔥 getFeedsWithPagination called with params: page: $page, perPage: $perPage, searchTerm: $searchTerm, shortBy: $shortBy, startDate: $startDate, endDate: $endDate',
    );

    try {
      final from = (page - 1) * perPage;
      final to = from + perPage - 1;
      final searchPattern = '%${searchTerm.trim()}%';
      final userId = SupabaseService.client.auth.currentUser?.id;

      final searchFilter =
          'author_name.ilike.$searchPattern,title.ilike.$searchPattern,description.ilike.$searchPattern';

      // 1. Fetch Feeds from view
      var query = SupabaseService.client
          .from('v_content_full_details')
          .select('*')
          .or('deleted_at.is.null')
          .eq('content_type', 'feed')
          .or(searchFilter);

      if (startDate != null && endDate != null) {
        query = query
            .gte('created_at', toIso(startDate))
            .lte('created_at', toIso(endDate));
      }

      final countResponse = await query;

      final totalCount = (countResponse as List).length;
      final totalPages = totalCount == 0 ? 1 : (totalCount / perPage).ceil();

      final response = await query
          .order(shortBy == 'all' ? 'created_at' : shortBy, ascending: false)
          .range(from, to);

      final List<dynamic> feedsList = response as List;
      if (feedsList.isEmpty) {
        return CommunityListResponse.save(
          totalCount: 0,
          totalPages: 0,
          pageNumber: 1,
          data: [],
        );
      }

      final contentIds = feedsList
          .map((e) => e['content_id'].toString())
          .toList();

      // 2. Fetch specific likes for these posts (to show avatars)
      // Using your v_content_like view
      final likesDataResponse = await SupabaseService.client
          .from('v_content_like')
          .select('*')
          .inFilter('content_id', contentIds)
          .order('liked_at', ascending: false);

      final List<dynamic> allLikes = likesDataResponse as List;

      // Group likes by content_id (limit to top 3 in Dart for simplicity)
      Map<String, List<LikedByUserInfo>> likedUsersMap = {};
      Set<String> myLikedContentIds = {};

      for (var like in allLikes) {
        final String cid = like['content_id'].toString();
        final String luid = like['like_user_id'].toString();

        if (luid == userId) {
          myLikedContentIds.add(cid);
        }

        if (!likedUsersMap.containsKey(cid)) {
          likedUsersMap[cid] = [];
        }

        if (likedUsersMap[cid]!.length < 3) {
          likedUsersMap[cid]!.add(
            LikedByUserInfo(
              userId: luid,
              fullName: like['like_user_name'],
              profilePictureUrl: like['like_user_profile_picture'],
            ),
          );
        }
      }

      // 3. Map to Model
      final data = feedsList.map((json) {
        final Map<String, dynamic> mutableJson = Map<String, dynamic>.from(
          json,
        );
        final String cid = mutableJson['content_id'].toString();

        mutableJson['is_liked_by_me'] = myLikedContentIds.contains(cid);

        return ContentFullDetailsModel.fromJson(
          mutableJson,
        ).copyWith(likedByUsers: likedUsersMap[cid] ?? []);
      }).toList();

      // final totalCount =
      //     feedsList.length; // Ideally fetch full count via separate query

      return CommunityListResponse.save(
        totalCount: totalCount,
        totalPages: totalPages,
        pageNumber: page,
        data: data,
      );
    } catch (e) {
      debugPrint('🔥 Exception in getFeedsWithPagination: $e');
      return CommunityListResponse.save(
        totalCount: 0,
        totalPages: 0,
        pageNumber: 1,
        data: [],
      );
    }
  }

  Future<bool> deleteContent(String contentId) async {
    try {
      await SupabaseService.client
          .from('content')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', contentId)
          .select()
          .single();
      return true;
    } catch (e) {
      debugPrint('🔥 Exception occurred in deleteContent');
      return false;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      await SupabaseService.client
          .from('content_comments')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', commentId);
      return true;
    } catch (e) {
      debugPrint('🔥 Error in deleteComment: $e');
      return false;
    }
  }

  Future<Result<ContentModel>> updateFeed(
    String contentId,
    String title,
    String description,
    Uint8List? fileBytes,
    String? fileName,
    bool isSharedToCommunity,
  ) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id ?? 'anonymous';

      Map<String, dynamic> updateData = {
        'title': title,
        'description': description,
        'is_shared_to_community': isSharedToCommunity,
      };

      // Only update media if a new file is provided
      if (fileBytes != null && fileName != null) {
        final mediaUrl = await StorageService.uploadMediaBytes(
          bytes: fileBytes,
          userId: userId,
          bucketName: 'content',
          mediaType: MediaType.image,
          customFileName: fileName,
        );
        updateData['media_file_url'] = mediaUrl;
      }

      final response = await SupabaseService.client
          .from('content')
          .update(updateData)
          .eq('id', contentId)
          .select()
          .single();
      return Success(ContentModel.fromJson(response));
    } catch (e) {
      debugPrint('🔥 Exception occurred in updateFeed');
      return Failure(e.toString());
    }
  }
}

class CommunityListResponse {
  final int totalCount;
  final int totalPages;
  final int pageNumber;
  final List<ContentFullDetailsModel> data;

  CommunityListResponse.save({
    required this.totalCount,
    required this.totalPages,
    required this.pageNumber,
    required this.data,
  });
}

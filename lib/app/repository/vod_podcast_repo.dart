import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:samsung_admin_main_new/app/common/constant/types.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/common/services/storage_service.dart';
import 'package:samsung_admin_main_new/app/common/services/supabase_service.dart';
import 'package:samsung_admin_main_new/app/models/content_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VodPodcastRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  static Future<Result<ContentModel>> createFile(
    String title,
    String description,
    ContentType contentType,
    Uint8List fileBytes,
    String fileName,
    Uint8List? thumbnailUrlBytes,
    String? thumbnailUrlName,
  ) async {
    try {
      if (fileBytes.isEmpty) {
        return Failure('No file bytes provided');
      }

      final userId = SupabaseService.currentUser?.id ?? 'anonymous';
      final mediaUrl = await StorageService.uploadMediaBytes(
        bytes: fileBytes,
        userId: userId,
        bucketName: 'content',
        mediaType: MediaType.video,
        customFileName: fileName,
      );

      if (mediaUrl == null) {
        return Failure('Failed to upload file');
      }

      String? thumbnailUrl;
      if (thumbnailUrlBytes != null &&
          thumbnailUrlBytes.isNotEmpty &&
          thumbnailUrlName != null &&
          thumbnailUrlName.isNotEmpty) {
        thumbnailUrl = await StorageService.uploadMediaBytes(
          bytes: thumbnailUrlBytes,
          userId: userId,
          bucketName: 'content',
          mediaType: MediaType.image,
          customFileName: thumbnailUrlName,
        );
      }

      final response = await SupabaseService.client
          .from('content')
          .insert({
            'media_file_url': mediaUrl,
            if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
            'content_type': contentType.toJson(),
            'title': title,
            'description': description,
            'user_id': SupabaseService.currentUser?.id,
          })
          .select()
          .single();
      return Success(ContentModel.fromJson(response));
    } catch (e) {
      debugPrint('🔥 Exception occurred in uploadFile');
      return Failure(e.toString());
    }
  }

  static Future<Result<List<ContentModel>>> getFiles() async {
    try {
      final response = await SupabaseService.client.from('content').select();
      return Success(
        (response as List)
            .map((json) => ContentModel.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      debugPrint('error::  $e');
      return Failure(e.toString());
    }
  }

  Future<VODPodcastListResponse> fetchContentListWithPagination({
    String searchTerm = '',
    String shortBy = 'all',
    int pageNumber = 1,
    int perPage = 8,
    String? startDate,
    String? endDate,
    // ContentType? contentType,
    String? contentType,
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

      var countQuery = supabase
          .from('content')
          .select('id')
          .or('deleted_at.is.null');

      if (contentType != null) {
        countQuery = countQuery.eq('content_type', contentType);
        // countQuery = countQuery.eq('content_type', contentType.toJson());
      } else {
        countQuery = countQuery.or(
          'content_type.eq.vod,content_type.eq.podcast',
        );
      }

      if (startDate != null &&
          startDate.isNotEmpty &&
          endDate != null &&
          endDate.isNotEmpty) {
        countQuery = countQuery
            .gte('created_at', toIso(startDate))
            .lte('created_at', toIso(endDate));
      }

      final countResponse = await countQuery
          .or('title.ilike.$searchPattern,description.ilike.$searchPattern')
          .or('deleted_at.is.null');

      final totalCount = (countResponse as List).length;
      final totalPages = totalCount == 0 ? 1 : (totalCount / perPage).ceil();

      var dataQuery = supabase
          .from('content')
          .select('*')
          .or('deleted_at.is.null');

      if (contentType != null) {
        dataQuery = dataQuery.eq('content_type', contentType);
        // dataQuery = dataQuery.eq('content_type', contentType.toJson());
      } else {
        dataQuery = dataQuery.or('content_type.eq.vod,content_type.eq.podcast');
      }

      if (startDate != null &&
          startDate.isNotEmpty &&
          endDate != null &&
          endDate.isNotEmpty) {
        dataQuery = dataQuery
            .gte('created_at', toIso(startDate))
            .lte('created_at', toIso(endDate));
      }

      final response = await dataQuery
          .or('title.ilike.$searchPattern,description.ilike.$searchPattern')
          .or('deleted_at.is.null')
          .order(shortBy == 'all' ? 'id' : shortBy, ascending: true)
          .range(from, to);

      final data = (response as List)
          .map((e) => ContentModel.fromJson(e))
          .toList();

      return VODPodcastListResponse.save(
        totalCount: totalCount,
        totalPages: totalPages,
        pageNumber: pageNumber,
        data: data,
      );
    } catch (e) {
      debugPrint('❌ fetchContentListWithPagination Error: $e');
      return VODPodcastListResponse.save(
        totalCount: 0,
        totalPages: 1,
        pageNumber: pageNumber,
        data: [],
      );
    }
  }

  static Future<Result<ContentModel>> updateFile(
    String contentId,
    String title,
    String description,
    Uint8List? fileBytes,
    String? fileName,
    Uint8List? thumbnailUrlBytes,
    String? thumbnailUrlName,
  ) async {
    final userId = SupabaseService.currentUser?.id ?? 'anonymous';
    final mediaUrl = await StorageService.uploadMediaBytes(
      bytes: fileBytes ?? Uint8List(0),
      userId: userId,
      bucketName: 'content',
      mediaType: MediaType.video,
      customFileName: fileName,
    );

    String? thumbnailUrl;
    if (thumbnailUrlBytes != null &&
        thumbnailUrlBytes.isNotEmpty &&
        thumbnailUrlName != null &&
        thumbnailUrlName.isNotEmpty) {
      thumbnailUrl = await StorageService.uploadMediaBytes(
        bytes: thumbnailUrlBytes,
        userId: userId,
        bucketName: 'content',
        mediaType: MediaType.image,
        customFileName: thumbnailUrlName,
      );
    }

    try {
      final userId = SupabaseService.currentUser?.id ?? 'anonymous';
      final response = await SupabaseService.client
          .from('content')
          .update({
            'title': title,
            'description': description,
            'user_id': userId,
            if (mediaUrl != null) 'media_file_url': mediaUrl,
            if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
          })
          .eq('id', contentId)
          .select()
          .single();
      return Success(ContentModel.fromJson(response));
    } catch (e) {
      debugPrint('❌ updateFile Error: $e');
      return Failure(e.toString());
    }
  }

  Future<bool> deleteContentById(String contentId) async {
    try {
      await supabase
          .from('content')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', contentId)
          .select()
          .single();
      return true;
    } catch (e) {
      debugPrint('❌ deleteContentById Error: $e');
      return false;
    }
  }
}

class VODPodcastListResponse {
  final int totalCount;
  final int totalPages;
  final int pageNumber;
  final List<ContentModel> data;

  VODPodcastListResponse.save({
    required this.totalCount,
    required this.totalPages,
    required this.pageNumber,
    required this.data,
  });
}

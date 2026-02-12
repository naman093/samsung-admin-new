import 'package:flutter/foundation.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/common/services/storage_service.dart';
import 'package:samsung_admin_main_new/app/common/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/promotions_model.dart';

class PromotionsRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  static Future<Result<PromotionModel>> createPromotion({
    required PromotionModel model,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id ?? 'anonymous';

      String? imageUrl;

      if (imageBytes != null && imageName != null) {
        imageUrl = await StorageService.uploadMediaBytes(
          bytes: imageBytes,
          userId: userId,
          bucketName: 'promotion_images',
          mediaType: MediaType.image,
          customFileName: imageName,
        );
      }

      final response = await SupabaseService.client
          .from('promotions')
          .insert({
        'title': model.title,
        'description': model.description,
        'background_image_url': imageUrl,
        'frequency': model.frequency,
        'interval_duration': model.frequency == 'interval' ? model.intervalDuration : null,
        'created_by': userId,
      })
          .select()
          .single();

      return Success(PromotionModel.fromJson(response));
    } catch (e, st) {
      debugPrint('❌ createPromotion Error: $e');
      debugPrint(st.toString());
      return Failure(e.toString());
    }
  }

  static Future<Result<PromotionModel>> updatePromotion({
    required PromotionModel model,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final userId = SupabaseService.currentUser?.id;

      String? imageUrl;
      if (imageBytes != null) {
        imageUrl = await StorageService.uploadMediaBytes(
          bytes: imageBytes,
          userId: userId ?? 'anonymous',
          bucketName: 'promotion_images',
          mediaType: MediaType.image,
          customFileName: imageName,
        );
      }

      final data = {
        'title': model.title,
        'description': model.description,
        'frequency': model.frequency,
        'interval_duration':  model.frequency == 'interval' ? model.intervalDuration : null,
      };

      if (imageUrl != null) {
        data['background_image_url'] = imageUrl;
      }

      final response = await SupabaseService.client.from('promotions').update(data)
          .eq('id', model.id).select().single();

      return Success(PromotionModel.fromJson(response));
    } catch (e, st) {
      debugPrint('❌ updatePromotion Error: $e');
      debugPrint(st.toString());
      return Failure(e.toString());
    }
  }

  Future<bool> deletePromotion(String id) async {
    try {
      final response = await SupabaseService.client
          .from('promotions')
          .delete()
          .eq('id', id)
          .select()
          .single();

      return response['deleted_at'] != null;
    } catch (e) {
      debugPrint('❌ deletePromotion Error: $e');
      return false;
    }
  }

  Future<PromotionListResponse> getPromotionsWithPagination({
    String searchTerm = '',
    int pageNumber = 1,
    int perPage = 8,
    String frequency = 'all',
  }) async {
    try {
      final from = (pageNumber - 1) * perPage;
      final to = from + perPage - 1;
      final searchPattern = '%$searchTerm%';

      var countQuery = SupabaseService.client
          .from('promotions')
          .select('*')
          .or('title.ilike.$searchPattern,description.ilike.$searchPattern')
          .or('deleted_at.is.null');

      if (frequency != 'all') {
        countQuery = countQuery.eq('frequency', frequency);
      }

      final countRes = await countQuery;
      final totalCount = (countRes as List).length;
      final totalPages = totalCount == 0 ? 1 : (totalCount / perPage).ceil();

      var dataQuery = SupabaseService.client
          .from('promotions')
          .select()
          .or('deleted_at.is.null')
          .or('title.ilike.$searchPattern,description.ilike.$searchPattern');

      if (frequency != 'all') {
        dataQuery = dataQuery.eq('frequency', frequency);
      }

      final response = await dataQuery
          .order('created_at', ascending: false)
          .range(from, to);

      final data = (response as List)
          .map((e) => PromotionModel.fromJson(e))
          .toList();

      return PromotionListResponse.save(
        totalCount: totalCount,
        totalPages: totalPages,
        pageNumber: pageNumber,
        data: data,
      );
    } catch (e, st) {
      debugPrint('❌ getPromotionsWithPagination Error: $e');
      debugPrint(st.toString());
      return PromotionListResponse.save(
        totalCount: 0,
        totalPages: 1,
        pageNumber: pageNumber,
        data: [],
      );
    }
  }
}

class PromotionListResponse {
  final int totalCount;
  final int totalPages;
  final int pageNumber;
  final List<PromotionModel> data;

  PromotionListResponse.save({
    required this.totalCount,
    required this.totalPages,
    required this.pageNumber,
    required this.data,
  });
}

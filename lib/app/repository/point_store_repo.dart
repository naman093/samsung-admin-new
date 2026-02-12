import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/common/services/storage_service.dart';
import 'package:samsung_admin_main_new/app/common/services/supabase_service.dart';
import 'package:samsung_admin_main_new/app/models/store_product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PointStoreRepo {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<StoreProductListResponse> fetchStoreProductListWithPagination({
    String searchTerm = '',
    int pageNumber = 1,
    int perPage = 8,
  }) async {
    try {
      final from = (pageNumber - 1) * perPage;
      final to = from + perPage - 1;
      final searchPattern = '%$searchTerm%';

      final countResponse = await supabase
          .from('store_products')
          .select('id')
          .or('name.ilike.$searchPattern,description.ilike.$searchPattern')
          .or('deleted_at.is.null');

      final totalCount = (countResponse as List).length;
      final totalPages = totalCount == 0 ? 1 : (totalCount / perPage).ceil();

      final response = await supabase
          .from('store_products')
          .select('*')
          .or('name.ilike.$searchPattern,description.ilike.$searchPattern')
          .or('deleted_at.is.null')
          .order('created_at', ascending: false)
          .range(from, to);

      final data = (response as List)
          .map((e) => StoreProductModel.fromJson(e))
          .toList();

      return StoreProductListResponse.save(
        totalCount: totalCount,
        totalPages: totalPages,
        pageNumber: pageNumber,
        data: data,
      );
    } catch (e) {
      debugPrint('❌ fetchAcademyListWithPagination Error: $e');
      return StoreProductListResponse.save(
        totalCount: 0,
        totalPages: 1,
        pageNumber: pageNumber,
        data: [],
      );
    }
  }

  static Future<Result<StoreProductModel>> createProduct(
    String title,
    String description,
    DateTime endDate,
    int costInPoints,
    Uint8List fileBytes,
    String fileName,
    Uint8List? explanatoryVideoOptional,
    String? explanatoryVideoOptionalName,
  ) async {
    try {
      final userId = SupabaseService.currentUser?.id ?? 'anonymous';
      final imageUrl = await StorageService.uploadMediaBytes(
        bytes: fileBytes,
        userId: userId,
        bucketName: 'content',
        mediaType: MediaType.image,
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
      final response = await SupabaseService.client
          .from('store_products')
          .insert({
            'name': title,
            'description': description,
            'end_date': endDate.toIso8601String(),
            'cost_points': costInPoints,
            'image_url': imageUrl,
            'video_url': explanatoryVideoOptionalUrl,
          })
          .select()
          .single();
      return Success(StoreProductModel.fromJson(response));
    } catch (e) {
      debugPrint('🔥 Exception occurred in createEvent');
      return Failure(e.toString());
    }
  }

  static Future<Result<StoreProductModel>> updateProduct(
    String id,
    String title,
    String description,
    String endDate,
    int costInPoints,
    Uint8List? fileBytes,
    String? fileName,
    Uint8List? explanatoryVideoOptional,
    String? explanatoryVideoOptionalName,
    String? existingVideoUrl,
    bool videoRemovedByUser,
  ) async {
    try {
      final userId = SupabaseService.currentUser?.id ?? 'anonymous';

      final updateData = <String, dynamic>{
        'name': title,
        'description': description,
        'end_date': endDate,
        'cost_points': costInPoints,
      };

      if (fileBytes != null &&
          fileBytes.isNotEmpty &&
          fileName != null &&
          fileName.isNotEmpty) {
        final imageUrl = await StorageService.uploadMediaBytes(
          bytes: fileBytes,
          userId: userId,
          bucketName: 'content',
          mediaType: MediaType.image,
          customFileName: fileName,
        );
        if (imageUrl != null) {
          updateData['image_url'] = imageUrl;
        }
      }

      if (explanatoryVideoOptional != null) {
        final newVideoUrl = await StorageService.uploadMediaBytes(
          bytes: explanatoryVideoOptional,
          userId: userId,
          bucketName: 'content',
          mediaType: MediaType.video,
          customFileName: explanatoryVideoOptionalName,
        );
        updateData['video_url'] = newVideoUrl;
      } else if (videoRemovedByUser) {
        updateData['video_url'] = null;
      }

      final response = await SupabaseService.client
          .from('store_products')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();
      return Success(StoreProductModel.fromJson(response));
    } catch (e) {
      debugPrint('🔥 Exception occurred in updateProduct');
      return Failure(e.toString());
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final response = await supabase
          .from('store_products')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .select()
          .single();
      if (response['deleted_at'] != null) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('🔥 Exception occurred in deleteProduct: $e');
      return false;
    }
  }
}

class StoreProductListResponse {
  final int totalCount;
  final int totalPages;
  final int pageNumber;
  final List<StoreProductModel> data;

  StoreProductListResponse.save({
    required this.totalCount,
    required this.totalPages,
    required this.pageNumber,
    required this.data,
  });
}

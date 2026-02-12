import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

enum MediaType { image, video, audio }

class StorageService {
  static Future<String?> uploadMediaBytes({
    required Uint8List bytes,
    required String userId,
    required String bucketName,
    required MediaType mediaType,
    String? customFileName,
  }) async {
    try {
      if (bytes.isEmpty) {
        return null;
      }

      final String fileName;
      if (customFileName != null && customFileName.isNotEmpty) {
        final sanitized = _sanitizeFileName(customFileName);
        fileName = sanitized;
      } else {
        final extension = _getFileExtension(mediaType);
        fileName =
            '${userId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      }
      final filePath = '$userId/$fileName';
      final contentType = _getContentTypeFromFileName(fileName, mediaType);

      await SupabaseService.client.storage
          .from(bucketName)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: contentType),
          );

      final publicUrl = SupabaseService.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading media: $e');
      return null;
    }
  }

  static Future<void> deleteFile({
    required String filePath,
    required String bucketName,
  }) async {
    try {
      await SupabaseService.client.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  static String _getFileExtension(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
        return 'jpg';
      case MediaType.video:
        return 'mp4';
      case MediaType.audio:
        return 'mp3';
    }
  }

  static String _getContentType(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
        return 'image/jpeg';
      case MediaType.video:
        return 'video/mp4';
      case MediaType.audio:
        return 'audio/mpeg';
    }
  }

  static String _getContentTypeFromFileName(
    String fileName,
    MediaType mediaType,
  ) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'webm':
        return 'video/webm';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'aac':
        return 'audio/aac';
      case 'm4a':
        return 'audio/x-m4a';
      default:
        return _getContentType(mediaType);
    }
  }

  static String _sanitizeFileName(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    String nameWithoutExt = lastDotIndex > 0
        ? fileName.substring(0, lastDotIndex)
        : fileName;
    final extension = lastDotIndex > 0
        ? fileName.substring(lastDotIndex + 1)
        : '';

    nameWithoutExt = nameWithoutExt
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    if (nameWithoutExt.isEmpty) {
      nameWithoutExt = 'file';
    }

    final sanitized = extension.isNotEmpty
        ? '$nameWithoutExt.$extension'
        : nameWithoutExt;

    return sanitized.toLowerCase();
  }
}

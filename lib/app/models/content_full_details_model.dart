import 'package:samsung_admin_main_new/app/common/constant/types.dart';

class LikedByUserInfo {
  final String userId;
  final String? fullName;
  final String? profilePictureUrl;

  LikedByUserInfo({
    required this.userId,
    this.fullName,
    this.profilePictureUrl,
  });

  factory LikedByUserInfo.fromJson(Map<String, dynamic> json) {
    return LikedByUserInfo(
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'profile_picture_url': profilePictureUrl,
    };
  }
}

class ContentFullDetailsModel {
  // Content
  final String contentId;
  final String? title;
  final String? description;
  final ContentType contentType;
  final String category;
  final String? mediaFileUrl;
  final List<String>? mediaFiles;
  final String? thumbnailUrl;

  final int pointsToEarn;
  final int viewCount;
  final int likesCount;
  final int commentsCount;

  final bool isFeatured;
  final bool isPublished;
  final bool isSharedToCommunity;
  final dynamic externalSharePlatforms;

  final bool isLikedByMe;

  final List<LikedByUserInfo>? likedByUsers;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Author
  final String userId;
  final String? authorName;
  final String? authorProfilePicture;
  final String? authorProfession;
  final String? authorBio;
  final String? authorCity;

  // KPIs
  final int authorFollowers;
  final int authorPostsCount;

  ContentFullDetailsModel({
    required this.contentId,
    this.title,
    this.description,
    required this.contentType,
    required this.category,
    this.mediaFileUrl,
    this.mediaFiles,
    this.thumbnailUrl,
    this.pointsToEarn = 0,
    required this.viewCount,
    required this.likesCount,
    required this.commentsCount,
    required this.isFeatured,
    required this.isPublished,
    required this.isSharedToCommunity,
    this.externalSharePlatforms,
    this.isLikedByMe = false,
    this.likedByUsers,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userId,
    this.authorName,
    this.authorProfilePicture,
    this.authorProfession,
    this.authorBio,
    this.authorCity,
    this.authorFollowers = 0,
    this.authorPostsCount = 0,
  });

  factory ContentFullDetailsModel.fromJson(Map<String, dynamic> json) {
    return ContentFullDetailsModel(
      contentId: json['content_id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      contentType: ContentType.fromString(json['content_type'] as String),
      category: json['category'] as String? ?? '',
      mediaFileUrl: json['media_file_url'] as String?,
      mediaFiles: json['media_files'] != null
          ? List<String>.from(json['media_files'] as List)
          : null,
      thumbnailUrl: json['thumbnail_url'] as String?,
      pointsToEarn: json['points_to_earn'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? true,
      isSharedToCommunity: json['is_shared_to_community'] as bool? ?? true,
      externalSharePlatforms: json['external_share_platforms'],
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      likedByUsers: json['liked_by_users'] != null
          ? (json['liked_by_users'] as List)
          .map((e) => LikedByUserInfo.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      userId: json['user_id'] as String,
      authorName: json['author_name'] as String?,
      authorProfilePicture: json['author_profile_picture'] as String?,
      authorProfession: json['author_profession'] as String?,
      authorBio: json['author_bio'] as String?,
      authorCity: json['author_city'] as String?,
      authorFollowers: json['author_followers'] as int? ?? 0,
      authorPostsCount: json['author_posts_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content_id': contentId,
      'title': title,
      'description': description,
      'content_type': contentType.toJson(),
      'category': category,
      'media_file_url': mediaFileUrl,
      'media_files': mediaFiles,
      'thumbnail_url': thumbnailUrl,
      'points_to_earn': pointsToEarn,
      'view_count': viewCount,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_featured': isFeatured,
      'is_published': isPublished,
      'is_shared_to_community': isSharedToCommunity,
      'external_share_platforms': externalSharePlatforms,
      'is_liked_by_me': isLikedByMe,
      'liked_by_users': likedByUsers?.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'user_id': userId,
      'author_name': authorName,
      'author_profile_picture': authorProfilePicture,
      'author_profession': authorProfession,
      'author_bio': authorBio,
      'author_city': authorCity,
      'author_followers': authorFollowers,
      'author_posts_count': authorPostsCount,
    };
  }

  ContentFullDetailsModel copyWith({
    String? contentId,
    String? title,
    String? description,
    ContentType? contentType,
    String? category,
    String? mediaFileUrl,
    List<String>? mediaFiles,
    String? thumbnailUrl,
    int? pointsToEarn,
    int? viewCount,
    int? likesCount,
    int? commentsCount,
    bool? isFeatured,
    bool? isPublished,
    bool? isSharedToCommunity,
    dynamic externalSharePlatforms,
    bool? isLikedByMe,
    List<LikedByUserInfo>? likedByUsers,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? userId,
    String? authorName,
    String? authorProfilePicture,
    String? authorProfession,
    String? authorBio,
    String? authorCity,
    int? authorFollowers,
    int? authorPostsCount,
  }) {
    return ContentFullDetailsModel(
      contentId: contentId ?? this.contentId,
      title: title ?? this.title,
      description: description ?? this.description,
      contentType: contentType ?? this.contentType,
      category: category ?? this.category,
      mediaFileUrl: mediaFileUrl ?? this.mediaFileUrl,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      pointsToEarn: pointsToEarn ?? this.pointsToEarn,
      viewCount: viewCount ?? this.viewCount,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isPublished: isPublished ?? this.isPublished,
      isSharedToCommunity: isSharedToCommunity ?? this.isSharedToCommunity,
      externalSharePlatforms: externalSharePlatforms ?? this.externalSharePlatforms,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      likedByUsers: likedByUsers ?? this.likedByUsers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorProfilePicture: authorProfilePicture ?? this.authorProfilePicture,
      authorProfession: authorProfession ?? this.authorProfession,
      authorBio: authorBio ?? this.authorBio,
      authorCity: authorCity ?? this.authorCity,
      authorFollowers: authorFollowers ?? this.authorFollowers,
      authorPostsCount: authorPostsCount ?? this.authorPostsCount,
    );
  }
}
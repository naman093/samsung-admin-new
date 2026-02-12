class ContentCommentViewModel {
  final String contentId;
  final String contentTitle;

  final String commentId;
  final String commentText;
  final DateTime commentCreatedAt;

  final String commentUserId;
  final String commentUserName;
  final String? commentUserProfilePicture;
  final String? commentUserProfession;
  final String? commentUserCity;

  ContentCommentViewModel({
    required this.contentId,
    required this.contentTitle,
    required this.commentId,
    required this.commentText,
    required this.commentCreatedAt,
    required this.commentUserId,
    required this.commentUserName,
    this.commentUserProfilePicture,
    this.commentUserProfession,
    this.commentUserCity,
  });

  factory ContentCommentViewModel.fromJson(Map<String, dynamic> json) {
    return ContentCommentViewModel(
      contentId: json['content_id']?.toString() ?? '',
      contentTitle: json['content_title']?.toString() ?? '',

      commentId: json['comment_id']?.toString() ?? '',
      commentText: json['comment_text']?.toString() ?? '',
      commentCreatedAt: json['comment_created_at'] != null
          ? DateTime.tryParse(json['comment_created_at'].toString()) ??
                DateTime.now()
          : DateTime.now(),

      commentUserId: json['comment_user_id']?.toString() ?? '',
      commentUserName: json['comment_user_name']?.toString() ?? 'Unknown',
      commentUserProfilePicture: json['comment_user_profile_picture']
          ?.toString(),
      commentUserProfession: json['comment_user_profession']?.toString(),
      commentUserCity: json['comment_user_city']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content_id': contentId,
      'content_title': contentTitle,
      'comment_id': commentId,
      'comment_text': commentText,
      'comment_created_at': commentCreatedAt.toIso8601String(),
      'comment_user_id': commentUserId,
      'comment_user_name': commentUserName,
      'comment_user_profile_picture': commentUserProfilePicture,
      'comment_user_profession': commentUserProfession,
      'comment_user_city': commentUserCity,
    };
  }
}

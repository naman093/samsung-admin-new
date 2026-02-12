class CommentModel {
  final String commentId;
  final String contentId;
  final String text;
  final DateTime createdAt;
  final String userId;
  final String userName;
  final String? userProfilePicture;
  final String? userProfession;

  CommentModel({
    required this.commentId,
    required this.contentId,
    required this.text,
    required this.createdAt,
    required this.userId,
    required this.userName,
    this.userProfilePicture,
    this.userProfession,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['comment_id'] as String,
      contentId: json['content_id'] as String,
      text: json['comment_text'] as String,
      createdAt: DateTime.parse(json['comment_created_at'] as String),
      userId: json['comment_user_id'] as String,
      userName: json['comment_user_name'] as String? ?? 'Unknown',
      userProfilePicture: json['comment_user_profile_picture'] as String?,
      userProfession: json['comment_user_profession'] as String?,
    );
  }
}
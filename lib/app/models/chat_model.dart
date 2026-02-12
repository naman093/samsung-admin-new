/// Matches table: conversation_messages
/// Columns: id, conversation_id, sender_id, content, media, metadata, created_at, updated_at, deleted_at
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String? content;
  final List<dynamic>? media;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    this.media,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      content: json['content'] as String?,
      media: json['media'] as List<dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      deletedAt: json['deleted_at'] != null
          ? _parseDate(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'media': media,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// For INSERT into conversation_messages (omit id; DB generates it).
  Map<String, dynamic> toJsonForInsert() {
    final now = DateTime.now().toUtc().toIso8601String();
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'media': media ?? [],
      'metadata': metadata ?? {},
      'created_at': now,
      'updated_at': now,
    };
  }
}

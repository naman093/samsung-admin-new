/// Matches table: conversations
/// Columns: id, is_group, title, created_by, last_message_at, created_at, updated_at, deleted_at
class ConversationModel {
  final String id;
  final bool isGroup;
  final String? title;
  final String? createdBy;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ConversationModel({
    required this.id,
    this.isGroup = false,
    this.title,
    this.createdBy,
    this.lastMessageAt,
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

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      isGroup: json['is_group'] == true,
      title: json['title'] as String?,
      createdBy: json['created_by'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? _parseDate(json['last_message_at'])
          : null,
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
      'is_group': isGroup,
      'title': title,
      'created_by': createdBy,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}

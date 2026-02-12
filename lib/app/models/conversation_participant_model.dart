/// Matches table: conversation_participants
/// Columns: id, conversation_id, user_id, joined_at, last_read_at, deleted_at
class ConversationParticipantModel {
  final String id;
  final String conversationId;
  final String userId;
  final DateTime? joinedAt;
  final DateTime? lastReadAt;
  final DateTime? deletedAt;

  ConversationParticipantModel({
    required this.id,
    required this.conversationId,
    required this.userId,
    this.joinedAt,
    this.lastReadAt,
    this.deletedAt,
  });

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory ConversationParticipantModel.fromJson(Map<String, dynamic> json) {
    return ConversationParticipantModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      joinedAt: _parseDate(json['joined_at']),
      lastReadAt: _parseDate(json['last_read_at']),
      deletedAt: _parseDate(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'user_id': userId,
      'joined_at': joinedAt?.toIso8601String(),
      'last_read_at': lastReadAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}

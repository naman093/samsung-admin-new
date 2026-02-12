/// Notification Model based on Supabase schema

enum NotificationType {
  riddleNew('riddle_new'),
  zoomStarting('zoom_starting'),
  eventReminder('event_reminder'),
  orderUpdate('order_update'),
  follow('follow'),
  comment('comment'),
  like('like'),
  pointsEarned('points_earned'),
  welcome('welcome'),
  riddleSubmissionCreated('riddle_submission_created'),
  riddleSubmissionResult('riddle_submission_result');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.welcome,
    );
  }

  String toJson() => value;
}

enum NotificationStatus {
  pending,
  sent,
  failed;

  static NotificationStatus fromString(String value) {
    return NotificationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationStatus.pending,
    );
  }

  String toJson() => name;
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType notificationType;
  final String title;
  final String message;
  final bool isRead;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final NotificationStatus status;
  final String? notificationFailedMsg;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.isRead,
    this.relatedEntityType,
    this.relatedEntityId,
    required this.createdAt,
    this.deletedAt,
    required this.status,
    this.notificationFailedMsg,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'notification_type': notificationType.toJson(),
      'title': title,
      'message': message,
      'is_read': isRead,
      'related_entity_type': relatedEntityType,
      'related_entity_id': relatedEntityId,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'status': status.toJson(),
      'notification_failed_msg': notificationFailedMsg,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      notificationType: NotificationType.fromString(
        json['notification_type'] as String,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      relatedEntityType: json['related_entity_type'] as String?,
      relatedEntityId: json['related_entity_id'] as String?,
      createdAt: parseDateTime(json['created_at']) ?? DateTime.now(),
      deletedAt: parseDateTime(json['deleted_at']),
      status: NotificationStatus.fromString(
        json['status'] as String? ?? 'pending',
      ),
      notificationFailedMsg: json['notification_failed_msg'] as String?,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? notificationType,
    String? title,
    String? message,
    bool? isRead,
    String? relatedEntityType,
    String? relatedEntityId,
    DateTime? createdAt,
    DateTime? deletedAt,
    NotificationStatus? status,
    String? notificationFailedMsg,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      status: status ?? this.status,
      notificationFailedMsg:
          notificationFailedMsg ?? this.notificationFailedMsg,
    );
  }
}

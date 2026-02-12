/// Event Model based on Supabase schema

enum EventType {
  workshop,
  webinar,
  meetup,
  exclusive;

  static EventType fromString(String value) {
    return EventType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EventType.workshop,
    );
  }

  String toJson() => name;
}

class EventModel {
  final String id;
  final String title;
  final String? description;
  final EventType eventType;
  final DateTime eventDate;
  final int? durationMinutes;
  final int? costPoints;
  final DateTime? end_date;
  final int? cost_credit_cents;
  final String? type;
  final int? costCreditCents;
  final String? video_url;
  final String? image_url;
  final int? maxTickets;
  final int ticketsSold;
  final String? zoomLink;
  final String? zoomMeetingId;
  final String imageUrl;
  final bool isPublished;
  final String? createdBy;
  final String? deletedAt;
  final String? eventerId;
  final String? status;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    this.type,
    this.cost_credit_cents,
    required this.eventType,
    required this.eventDate,
    this.durationMinutes,
    this.costPoints,
    this.end_date,
    this.costCreditCents,
    this.deletedAt,
    this.video_url,
    this.image_url,
    this.maxTickets,
    required this.ticketsSold,
    this.zoomLink,
    this.zoomMeetingId,
    required this.imageUrl,
    required this.isPublished,
    this.createdBy,
    this.eventerId,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'event_type': eventType.toJson(),
      'event_date': eventDate.toIso8601String(),
      'duration_minutes': durationMinutes,
      'cost_points': costPoints,
      'end_date': end_date,
      'cost_credit_cents': cost_credit_cents,
      'max_tickets': maxTickets,
      'tickets_sold': ticketsSold,
      'zoom_link': zoomLink,
      'zoom_meeting_id': zoomMeetingId,
      'image_url': imageUrl,
      'is_published': isPublished,
      'created_by': createdBy,
      'deleted_at': deletedAt,
      'external_id': eventerId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] as String?,
      type: json['type'] as String?,
      eventType: EventType.fromString(json['event_type'] ?? ''),
      eventDate:
          DateTime.tryParse(json['event_date'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),

      durationMinutes: json['duration_minutes'] as int?,
      costPoints: json['cost_points'] as int?,
      end_date: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'])
          : null,

      costCreditCents: json['cost_credit_cents'] as int?,
      cost_credit_cents: json['cost_credit_cents'] as int?,

      video_url: json['video_url'] as String?,
      image_url: json['image_url'] as String?,
      imageUrl: json['image_url'] ?? '',

      maxTickets: json['max_tickets'] as int?,
      ticketsSold: json['tickets_sold'] as int? ?? 0,

      zoomLink: json['zoom_link'] as String?,
      zoomMeetingId: json['zoom_meeting_id'] as String?,

      isPublished: json['is_published'] as bool? ?? false,
      createdBy: json['created_by'] as String?,
      deletedAt: json['deleted_at'] as String?,
      eventerId: json['external_id'] as String?,
      status: json['status'] as String?,

      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json['updated_at'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    EventType? eventType,
    DateTime? eventDate,
    int? durationMinutes,
    int? costPoints,
    int? costCreditCents,
    int? maxTickets,
    int? ticketsSold,
    String? zoomLink,
    String? zoomMeetingId,
    String? imageUrl,
    bool? isPublished,
    String? createdBy,
    String? eventerId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      costPoints: costPoints ?? this.costPoints,
      costCreditCents: costCreditCents ?? this.costCreditCents,
      maxTickets: maxTickets ?? this.maxTickets,
      ticketsSold: ticketsSold ?? this.ticketsSold,
      zoomLink: zoomLink ?? this.zoomLink,
      zoomMeetingId: zoomMeetingId ?? this.zoomMeetingId,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublished: isPublished ?? this.isPublished,
      createdBy: createdBy ?? this.createdBy,
      eventerId: eventerId ?? this.eventerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

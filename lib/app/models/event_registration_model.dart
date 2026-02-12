enum PaymentMethod {
  points,
  credit;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentMethod.points,
    );
  }

  String toJson() => name;
}

enum RegistrationStatus {
  registered,
  cancelled,
  attended;

  static RegistrationStatus fromString(String value) {
    return RegistrationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RegistrationStatus.registered,
    );
  }

  String toJson() => name;
}

class EventRegistrationModel {
  final String id;
  final String eventId;
  final String userId;
  final PaymentMethod paymentMethod;
  final int? pointsPaid;
  final int? creditPaidCents;
  final RegistrationStatus status;
  final DateTime registeredAt;
  final DateTime? attendedAt;
  final DateTime? deletedAt;
  // User info from join
  final String? userName;
  final String? userPhoneNumber;
  final String? userFullName;

  EventRegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.paymentMethod,
    this.pointsPaid,
    this.creditPaidCents,
    required this.status,
    required this.registeredAt,
    this.attendedAt,
    this.deletedAt,
    this.userName,
    this.userPhoneNumber,
    this.userFullName,
  });

  String get displayName {
    return userFullName ?? userName ?? userPhoneNumber ?? 'Unknown User';
  }

  factory EventRegistrationModel.fromJson(Map<String, dynamic> json) {
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

    return EventRegistrationModel(
      id: json['id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      paymentMethod: PaymentMethod.fromString(
        json['payment_method']?.toString() ?? 'points',
      ),
      pointsPaid: json['points_paid'] as int?,
      creditPaidCents: json['credit_paid_cents'] as int?,
      status: RegistrationStatus.fromString(
        json['status']?.toString() ?? 'registered',
      ),
      registeredAt: parseDateTime(json['registered_at']) ?? DateTime.now(),
      attendedAt: parseDateTime(json['attended_at']),
      deletedAt: parseDateTime(json['deleted_at']),
      userName: json['user_name'] as String?,
      userPhoneNumber: json['user_phone_number'] as String?,
      userFullName:
          json['user_full_name'] as String? ??
          json['users']?['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'payment_method': paymentMethod.toJson(),
      'points_paid': pointsPaid,
      'credit_paid_cents': creditPaidCents,
      'status': status.toJson(),
      'registered_at': registeredAt.toIso8601String(),
      'attended_at': attendedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}

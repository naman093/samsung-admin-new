/// Eventer Event Model based on Eventer API response structure

class EventerEventModel {
  final String id;
  final int status;
  final int eventType;
  final String name;
  final String linkName;
  final EventerSchedule schedule;
  final String eventDesc;
  final EventerLocation location;
  final String locationDescription;
  final String? background;
  final String? mobileBackground;
  final String? thumbnail;
  final String? mobilePhoto;
  final String? imgForEmail;
  final String? imgForETicket;

  EventerEventModel({
    required this.id,
    required this.status,
    required this.eventType,
    required this.name,
    required this.linkName,
    required this.schedule,
    required this.eventDesc,
    required this.location,
    required this.locationDescription,
    this.background,
    this.mobileBackground,
    this.thumbnail,
    this.mobilePhoto,
    this.imgForEmail,
    this.imgForETicket,
  });

  factory EventerEventModel.fromJson(Map<String, dynamic> json) {
    return EventerEventModel(
      id: json['_id']?.toString() ?? '',
      status: json['status'] as int? ?? 0,
      eventType: json['eventType'] as int? ?? 0,
      name: json['name'] ?? '',
      linkName: json['linkName'] ?? '',
      schedule: EventerSchedule.fromJson(
        json['schedule'] as Map<String, dynamic>? ?? {},
      ),
      eventDesc: json['eventDesc'] ?? '',
      location: EventerLocation.fromJson(
        json['location'] as Map<String, dynamic>? ?? {},
      ),
      locationDescription: json['locationDescription'] ?? '',
      background: json['background'] as String?,
      mobileBackground: json['mobileBackground'] as String?,
      thumbnail: json['thumbnail'] as String?,
      mobilePhoto: json['mobilePhoto'] as String?,
      imgForEmail: json['imgForEmail'] as String?,
      imgForETicket: json['imgForETicket'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'status': status,
      'eventType': eventType,
      'name': name,
      'linkName': linkName,
      'schedule': schedule.toJson(),
      'eventDesc': eventDesc,
      'location': location.toJson(),
      'locationDescription': locationDescription,
      'background': background,
      'mobileBackground': mobileBackground,
      'thumbnail': thumbnail,
      'mobilePhoto': mobilePhoto,
      'imgForEmail': imgForEmail,
      'imgForETicket': imgForETicket,
    };
  }
}

class EventerSchedule {
  final DateTime start;
  final DateTime end;
  final DateTime openDoors;
  final DateTime cancellationDeadline;

  EventerSchedule({
    required this.start,
    required this.end,
    required this.openDoors,
    required this.cancellationDeadline,
  });

  factory EventerSchedule.fromJson(Map<String, dynamic> json) {
    return EventerSchedule(
      start:
          DateTime.tryParse(json['start'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      end:
          DateTime.tryParse(json['end'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      openDoors:
          DateTime.tryParse(json['openDoors'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      cancellationDeadline:
          DateTime.tryParse(json['cancellationDeadline'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'openDoors': openDoors.toIso8601String(),
      'cancellationDeadline': cancellationDeadline.toIso8601String(),
    };
  }
}

class EventerLocation {
  final double latitude;
  final double longtitude;
  final String timezone;

  EventerLocation({
    required this.latitude,
    required this.longtitude,
    required this.timezone,
  });

  factory EventerLocation.fromJson(Map<String, dynamic> json) {
    return EventerLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longtitude: (json['longtitude'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longtitude': longtitude,
      'timezone': timezone,
    };
  }
}

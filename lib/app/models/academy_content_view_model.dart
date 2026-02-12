class AcademyContentViewModel {
  /// ---------------------------
  /// Academy Content
  /// ---------------------------
  final String academyContentId;
  final String title;
  final String? description;
  final String fileType;
  final String? mediaFileUrl;
  final int pointsToEarn;
  final bool isPublished;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// ---------------------------
  /// Creator User Profile
  /// ---------------------------
  final String? creatorUserId;
  final String? creatorFullName;
  final String? creatorPhoneNumber;
  final String? creatorProfilePictureUrl;
  final String? creatorRole;
  final String? creatorStatus;

  /// ---------------------------
  /// Zoom Workshop (Events)
  /// ---------------------------
  final String? eventId;
  final DateTime? eventDate;
  final int? durationMinutes;
  final String? zoomLink;
  final String? zoomStartTime;
  final String? zoomEndTime;
  final int? eventCostPoints;
  final int? eventCostCreditCents;

  /// ---------------------------
  /// Assignment / Mission Challenge
  /// ---------------------------
  final String? assignmentId;
  final String? taskName;
  final String? taskType;
  final String? assignmentDescription;
  final DateTime? taskStartDate;
  final DateTime? taskEndDate;
  final String? taskEndTime;
  final int? totalPointsToWin;
  final List<dynamic>? answers;
  final String? assignmentCreatorUserId;
  final DateTime? assignmentCreatedAt;
  final DateTime? assignmentUpdatedAt;

  /// ---------------------------
  /// Assignment Submissions
  /// ---------------------------
  final List<String>? submissionUserIds;

  AcademyContentViewModel({
    required this.academyContentId,
    required this.title,
    required this.fileType,
    required this.pointsToEarn,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.mediaFileUrl,
    this.createdBy,

    // Creator
    this.creatorUserId,
    this.creatorFullName,
    this.creatorPhoneNumber,
    this.creatorProfilePictureUrl,
    this.creatorRole,
    this.creatorStatus,

    // Zoom
    this.eventId,
    this.eventDate,
    this.durationMinutes,
    this.zoomLink,
    this.zoomStartTime,
    this.zoomEndTime,
    this.eventCostPoints,
    this.eventCostCreditCents,

    // Assignment
    this.assignmentId,
    this.taskName,
    this.taskType,
    this.assignmentDescription,
    this.taskStartDate,
    this.taskEndDate,
    this.taskEndTime,
    this.totalPointsToWin,
    this.answers,
    this.assignmentCreatorUserId,
    this.assignmentCreatedAt,
    this.assignmentUpdatedAt,

    // Submissions
    this.submissionUserIds,
  });

  /// ---------------------------
  /// From JSON
  /// ---------------------------
  factory AcademyContentViewModel.fromJson(Map<String, dynamic> json) {
    return AcademyContentViewModel(
      academyContentId: json['academy_content_id'],
      title: json['title'] ?? '',
      description: json['description'],
      fileType: json['file_type'],
      mediaFileUrl: json['media_file_url'],
      pointsToEarn: json['points_to_earn'] ?? 0,
      isPublished: json['is_published'] ?? true,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),

      // Creator
      creatorUserId: json['creator_user_id'],
      creatorFullName: json['creator_full_name'],
      creatorPhoneNumber: json['creator_phone_number'],
      creatorProfilePictureUrl: json['creator_profile_picture_url'],
      creatorRole: json['creator_role'],
      creatorStatus: json['creator_status'],

      // Zoom
      eventId: json['event_id'],
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'])
          : null,
      zoomStartTime: json['zoom_start_time'],
      zoomEndTime: json['zoom_end_time'],
      durationMinutes: json['duration_minutes'],
      eventCostPoints: json['cost_points'],
      eventCostCreditCents: json['cost_credit_cents'],
      zoomLink: json['zoom_link'],

      // Assignment
      assignmentId: json['assignment_id'],
      taskName: json['task_name'],
      taskType: json['task_type'],
      assignmentDescription: json['assignment_description'],
      taskStartDate: json['task_start_date'] != null
          ? DateTime.parse(json['task_start_date'])
          : null,
      taskEndDate: json['task_end_date'] != null
          ? DateTime.parse(json['task_end_date'])
          : null,
      taskEndTime: json['task_end_time'],
      totalPointsToWin: json['total_points_to_win'],
      answers: json['answers'],
      assignmentCreatorUserId: json['assignment_creator_user_id'],
      assignmentCreatedAt: json['assignment_created_at'] != null
          ? DateTime.parse(json['assignment_created_at'])
          : null,
      assignmentUpdatedAt: json['assignment_updated_at'] != null
          ? DateTime.parse(json['assignment_updated_at'])
          : null,

      // Submissions
      submissionUserIds: json['submission_user_ids'] != null
          ? List<String>.from(json['submission_user_ids'])
          : [],
    );
  }

  /// ---------------------------
  /// To JSON
  /// ---------------------------
  Map<String, dynamic> toJson() {
    return {
      'academy_content_id': academyContentId,
      'title': title,
      'description': description,
      'file_type': fileType,
      'media_file_url': mediaFileUrl,
      'points_to_earn': pointsToEarn,
      'is_published': isPublished,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),

      // Creator
      'creator_user_id': creatorUserId,
      'creator_full_name': creatorFullName,
      'creator_phone_number': creatorPhoneNumber,
      'creator_profile_picture_url': creatorProfilePictureUrl,
      'creator_role': creatorRole,
      'creator_status': creatorStatus,

      // Zoom
      'event_id': eventId,
      'event_date': eventDate?.toIso8601String(),
      'zoom_start_time': zoomStartTime,
      'zoom_end_time': zoomEndTime,
      'duration_minutes': durationMinutes,
      'cost_points': eventCostPoints,
      'cost_credit_cents': eventCostCreditCents,
      'zoom_link': zoomLink,

      // Assignment
      'assignment_id': assignmentId,
      'task_name': taskName,
      'task_type': taskType,
      'assignment_description': assignmentDescription,
      'task_start_date': taskStartDate?.toIso8601String(),
      'task_end_date': taskEndDate?.toIso8601String(),
      'task_end_time': taskEndTime,
      'total_points_to_win': totalPointsToWin,
      'answers': answers,
      'assignment_creator_user_id': assignmentCreatorUserId,
      'assignment_created_at': assignmentCreatedAt?.toIso8601String(),
      'assignment_updated_at': assignmentUpdatedAt?.toIso8601String(),

      // Submissions
      'submission_user_ids': submissionUserIds,
    };
  }

  /// ---------------------------
  /// Helpers
  /// ---------------------------
  bool get isVideo => fileType == 'video' || fileType == 'reel';
  bool get isZoomWorkshop => fileType == 'zoom_workshop';
  bool get isAssignment => fileType == 'assignment';
}

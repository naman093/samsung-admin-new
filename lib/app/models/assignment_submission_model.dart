class AssignmentSubmissionModel {
  // Submission details
  final String submissionId;
  final DateTime submissionCreatedAt;
  final String? solution;
  final String? assignmentId;
  final String? submittedByUserId;
  final bool? isCorrect;
  final DateTime? submissionDeletedAt;

  // Assignment details
  final String? taskName;
  final String? taskType;
  final String? assignmentDescription;
  final DateTime? taskStartDate;
  final DateTime? taskEndDate;
  final String? taskEndTime;
  final int? totalPointsToWin;
  final String? audioFileUrl;
  final dynamic answers;
  final bool? assignmentIsActive;
  final DateTime? assignmentCreatedAt;
  final DateTime? assignmentUpdatedAt;

  // Assignment creator details
  final String? assignmentCreatorId;
  final String? assignmentCreatorName;
  final String? assignmentCreatorPhone;
  final String? assignmentCreatorEmail;

  // Submitted user details
  final String? submittedByName;
  final String? submittedByPhone;
  final String? submittedByEmail;
  final String? submittedByProfilePicture;
  final String? submittedByCity;
  final String? submittedByCollege;
  final String? submittedByClass;
  final int? submittedByPointsBalance;
  final String? submittedByStatus;
  final String? submittedByRole;

  AssignmentSubmissionModel({
    required this.submissionId,
    required this.submissionCreatedAt,
    this.solution,
    this.assignmentId,
    this.submittedByUserId,
    this.isCorrect,
    this.submissionDeletedAt,
    this.taskName,
    this.taskType,
    this.assignmentDescription,
    this.taskStartDate,
    this.taskEndDate,
    this.taskEndTime,
    this.totalPointsToWin,
    this.audioFileUrl,
    this.answers,
    this.assignmentIsActive,
    this.assignmentCreatedAt,
    this.assignmentUpdatedAt,
    this.assignmentCreatorId,
    this.assignmentCreatorName,
    this.assignmentCreatorPhone,
    this.assignmentCreatorEmail,
    this.submittedByName,
    this.submittedByPhone,
    this.submittedByEmail,
    this.submittedByProfilePicture,
    this.submittedByCity,
    this.submittedByCollege,
    this.submittedByClass,
    this.submittedByPointsBalance,
    this.submittedByStatus,
    this.submittedByRole,
  });

  factory AssignmentSubmissionModel.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmissionModel(
      submissionId: json['submission_id'],
      submissionCreatedAt:
      DateTime.parse(json['submission_created_at']),
      solution: json['solution'],
      assignmentId: json['assignment_id'],
      submittedByUserId: json['submitted_by_user_id'],
      isCorrect: json['is_correct'],
      submissionDeletedAt: json['submission_deleted_at'] != null
          ? DateTime.parse(json['submission_deleted_at'])
          : null,

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
      audioFileUrl: json['audio_file_url'],
      answers: json['answers'],
      assignmentIsActive: json['assignment_is_active'],
      assignmentCreatedAt: json['assignment_created_at'] != null
          ? DateTime.parse(json['assignment_created_at'])
          : null,
      assignmentUpdatedAt: json['assignment_updated_at'] != null
          ? DateTime.parse(json['assignment_updated_at'])
          : null,

      assignmentCreatorId: json['assignment_creator_id'],
      assignmentCreatorName: json['assignment_creator_name'],
      assignmentCreatorPhone: json['assignment_creator_phone'],
      assignmentCreatorEmail: json['assignment_creator_email'],

      submittedByName: json['submitted_by_name'],
      submittedByPhone: json['submitted_by_phone'],
      submittedByEmail: json['submitted_by_email'],
      submittedByProfilePicture:
      json['submitted_by_profile_picture'],
      submittedByCity: json['submitted_by_city'],
      submittedByCollege: json['submitted_by_college'],
      submittedByClass: json['submitted_by_class'],
      submittedByPointsBalance:
      json['submitted_by_points_balance'],
      submittedByStatus: json['submitted_by_status'],
      submittedByRole: json['submitted_by_role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'submission_id': submissionId,
      'submission_created_at':
      submissionCreatedAt.toIso8601String(),
      'solution': solution,
      'assignment_id': assignmentId,
      'submitted_by_user_id': submittedByUserId,
      'is_correct': isCorrect,
      'submission_deleted_at':
      submissionDeletedAt?.toIso8601String(),

      'task_name': taskName,
      'task_type': taskType,
      'assignment_description': assignmentDescription,
      'task_start_date': taskStartDate?.toIso8601String(),
      'task_end_date': taskEndDate?.toIso8601String(),
      'task_end_time': taskEndTime,
      'total_points_to_win': totalPointsToWin,
      'audio_file_url': audioFileUrl,
      'answers': answers,
      'assignment_is_active': assignmentIsActive,
      'assignment_created_at':
      assignmentCreatedAt?.toIso8601String(),
      'assignment_updated_at':
      assignmentUpdatedAt?.toIso8601String(),

      'assignment_creator_id': assignmentCreatorId,
      'assignment_creator_name': assignmentCreatorName,
      'assignment_creator_phone': assignmentCreatorPhone,
      'assignment_creator_email': assignmentCreatorEmail,

      'submitted_by_name': submittedByName,
      'submitted_by_phone': submittedByPhone,
      'submitted_by_email': submittedByEmail,
      'submitted_by_profile_picture':
      submittedByProfilePicture,
      'submitted_by_city': submittedByCity,
      'submitted_by_college': submittedByCollege,
      'submitted_by_class': submittedByClass,
      'submitted_by_points_balance':
      submittedByPointsBalance,
      'submitted_by_status': submittedByStatus,
      'submitted_by_role': submittedByRole,
    };
  }
}

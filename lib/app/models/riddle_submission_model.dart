import 'package:samsung_admin_main_new/app/models/weekly_riddle_model.dart';

class RiddleSubmissionModel {
  final String submissionId;
  final String riddleId;
  final String userId;
  final String? solution;
  final bool? isCorrect;
  final int pointsEarned;
  final DateTime submittedAt;

  final String riddleTitle;
  final String? riddleDescription;
  final String? riddleRules;
  final String riddleType;
  final int pointsToEarn;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int totalParticipants;

  final String? fullName;
  final String phoneNumber;
  final String? email;
  final String? profilePictureUrl;
  final String? city;
  final String? gender;
  final String? className;
  final String? college;
  final int pointsBalance;
  final String userRole;
  final String userStatus;

  final WeeklyRiddleModel? riddle;

  const RiddleSubmissionModel({
    required this.submissionId,
    required this.riddleId,
    required this.userId,
    this.solution,
    this.isCorrect,
    required this.pointsEarned,
    required this.submittedAt,

    required this.riddleTitle,
    this.riddleDescription,
    this.riddleRules,
    required this.riddleType,
    required this.pointsToEarn,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.totalParticipants,

    this.fullName,
    required this.phoneNumber,
    this.email,
    this.profilePictureUrl,
    this.city,
    this.gender,
    this.className,
    this.college,
    required this.pointsBalance,
    required this.userRole,
    required this.userStatus,

    this.riddle,
  });

  // factory RiddleSubmissionModel.fromJson(Map<String, dynamic> json) {
  //   DateTime parseDate(dynamic value) =>
  //       DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  //
  //   return RiddleSubmissionModel(
  //     // Submission
  //     submissionId: json['submission_id'] as String,
  //     riddleId: json['riddle_id'] as String,
  //     userId: json['user_id'] as String,
  //     solution: json['solution'] as String?,
  //     isCorrect: json['is_correct'] as bool?,
  //     pointsEarned: (json['points_earned'] as num?)?.toInt() ?? 0,
  //     submittedAt: parseDate(json['submitted_at']),
  //
  //     // Riddle
  //     riddleTitle: json['riddle_title'] as String,
  //     riddleDescription: json['riddle_description'] as String?,
  //     riddleRules: json['riddle_rules'] as String?,
  //     riddleType: json['riddle_type'] as String,
  //     pointsToEarn: (json['points_to_earn'] as num).toInt(),
  //     startDate: parseDate(json['start_date']),
  //     endDate: parseDate(json['end_date']),
  //     isActive: json['is_active'] as bool? ?? false,
  //     totalParticipants:
  //     (json['total_participants'] as num?)?.toInt() ?? 0,
  //
  //     // User
  //     fullName: json['full_name'] as String?,
  //     phoneNumber: json['phone_number'] as String,
  //     email: json['email'] as String?,
  //     profilePictureUrl: json['profile_picture_url'] as String?,
  //     city: json['city'] as String?,
  //     gender: json['gender'] as String?,
  //     className: json['class_name'] as String?,
  //     college: json['college'] as String?,
  //     pointsBalance: (json['points_balance'] as num?)?.toInt() ?? 0,
  //     userRole: json['user_role'] as String,
  //     userStatus: json['user_status'] as String,
  //
  //     riddle: WeeklyRiddleModel.fromJson({
  //       'id': json['riddle_id'],
  //       'title': json['riddle_title'],
  //       'description': json['riddle_description'],
  //       'rules': json['riddle_rules'],
  //       'type': json['riddle_type'],
  //       'points_to_earn': json['points_to_earn'],
  //       'start_date': json['start_date'],
  //       'end_date': json['end_date'],
  //       'is_active': json['is_active'],
  //       'total_participants': json['total_participants'],
  //     }),
  //     user: UserModel.fromJson({
  //       'id': json['user_id'],
  //       'full_name': json['full_name'],
  //       'phone_number': json['phone_number'],
  //       'email': json['email'],
  //       'profile_picture_url': json['profile_picture_url'],
  //       'city': json['city'],
  //       'gender': json['gender'],
  //       'class_name': json['class_name'],
  //       'college': json['college'],
  //       'points_balance': json['points_balance'],
  //       'role': json['user_role'],
  //       'status': json['user_status'],
  //     }),
  //   );
  // }

  factory RiddleSubmissionModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();

    return RiddleSubmissionModel(
      // Submission
      submissionId: json['submission_id']?.toString() ?? '',
      riddleId: json['riddle_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      solution: json['solution'] as String?,
      isCorrect: json['is_correct'] as bool?,
      pointsEarned: (json['points_earned'] as num?)?.toInt() ?? 0,
      submittedAt: parseDate(json['submitted_at']),

      // Riddle
      riddleTitle: json['riddle_title']?.toString() ?? '',
      riddleDescription: json['riddle_description'] as String?,
      riddleRules: json['riddle_rules'] as String?,
      riddleType: json['riddle_type']?.toString() ?? '',
      pointsToEarn: (json['points_to_earn'] as num?)?.toInt() ?? 0,
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
      isActive: json['is_active'] as bool? ?? false,
      totalParticipants:
      (json['total_participants'] as num?)?.toInt() ?? 0,

      // User (⚠️ NULL SAFE)
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number']?.toString() ?? '',
      email: json['email'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      city: json['city'] as String?,
      gender: json['gender']?.toString(),
      className: json['class_name'] as String?,
      college: json['college'] as String?,
      pointsBalance: (json['points_balance'] as num?)?.toInt() ?? 0,
      userRole: json['user_role']?.toString() ?? 'user',
      userStatus: json['user_status']?.toString() ?? 'pending',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'submission_id': submissionId,
      'riddle_id': riddleId,
      'user_id': userId,
      'solution': solution,
      'is_correct': isCorrect,
      'points_earned': pointsEarned,
      'submitted_at': submittedAt.toIso8601String(),

      'riddle_title': riddleTitle,
      'riddle_description': riddleDescription,
      'riddle_rules': riddleRules,
      'riddle_type': riddleType,
      'points_to_earn': pointsToEarn,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'total_participants': totalParticipants,

      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'profile_picture_url': profilePictureUrl,
      'city': city,
      'gender': gender,
      'class_name': className,
      'college': college,
      'points_balance': pointsBalance,
      'user_role': userRole,
      'user_status': userStatus,

      if (riddle != null) 'riddle': riddle!.toJson(),
    };
  }

}

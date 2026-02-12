/// Weekly Riddle Model based on Supabase schema

enum RiddleSolutionType {
  text,
  voice,
  video;

  static RiddleSolutionType fromString(String value) {
    return RiddleSolutionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RiddleSolutionType.text,
    );
  }

  String toJson() => name;
}

class WeeklyRiddleModel {
  final String id;
  final String title;
  final String? description;
  final String? rules;
  final String solutionType;
  final Map<String, dynamic>? textSolutions;
  final int pointsToEarn;
  final String? adminVodUrl;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? endTime;
  final String? answer;
  final dynamic question;
  final int totalParticipants;

  WeeklyRiddleModel({
    required this.id,
    required this.title,
    this.description,
    this.rules,
    required this.totalParticipants,
    required this.solutionType,
    this.textSolutions,
    required this.pointsToEarn,
    this.adminVodUrl,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.answer,
    this.endTime,
    this.question,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rules': rules,
      'type': solutionType,
      'answer': answer,
      'question': question,
      'points_to_earn': pointsToEarn,
      'admin_vod_url': adminVodUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_participants': totalParticipants,
    };
  }

  factory WeeklyRiddleModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      try {
        return DateTime.parse(date as String);
      } catch (e) {
        return DateTime.now();
      }
    }

    DateTime? parseTime(dynamic time) {
      if (time == null) return null;
      try {
        final timeStr = time.toString();
        if (timeStr.contains(':')) {
          // Supabase 'time' type returns HH:mm:ss
          final now = DateTime.now();
          final parts = timeStr.split(':');
          return DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
            parts.length > 2 ? int.parse(parts[2].split('.')[0]) : 0,
          );
        }
        return DateTime.parse(timeStr);
      } catch (e) {
        return null;
      }
    }

    return WeeklyRiddleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      rules: json['rules']?.toString(),
      totalParticipants: json['total_participants'] ?? 0,
      solutionType:
          json['type']?.toString() ??
          json['solution_type']?.toString() ??
          'Text',
      textSolutions: json['answers'] is Map<String, dynamic>
          ? json['answers'] as Map<String, dynamic>
          : json['text_solutions'] is Map<String, dynamic>
          ? json['text_solutions'] as Map<String, dynamic>
          : null,
      pointsToEarn: (json['points_to_earn'] as num?)?.toInt() ?? 0,
      adminVodUrl:
          json['admin_vod_url'] as String? ?? json['file_url'] as String?,
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      answer: json['answer']?.toString(),
      question: json['question'],
      endTime: parseTime(json['end_time']),
    );
  }

  WeeklyRiddleModel copyWith({
    String? id,
    String? title,
    String? description,
    String? rules,
    RiddleSolutionType? solutionType,
    Map<String, dynamic>? textSolutions,
    int? pointsToEarn,
    int? totalParticipants,
    String? adminVodUrl,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? endTime,
  }) {
    return WeeklyRiddleModel(
      id: id ?? this.id,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      title: title ?? this.title,
      description: description ?? this.description,
      rules: rules ?? this.rules,
      solutionType: this.solutionType,
      textSolutions: textSolutions ?? this.textSolutions,
      pointsToEarn: pointsToEarn ?? this.pointsToEarn,
      adminVodUrl: adminVodUrl ?? this.adminVodUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      endTime: endTime ?? this.endTime,
      answer: answer,
      question: question,
    );
  }
}

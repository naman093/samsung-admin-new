class PromotionModel {
  final String id;
  final String title;
  final String? description;
  final String? backgroundImageUrl;
  final String frequency; // one_time | interval
  final String? intervalDuration;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  PromotionModel({
    required this.id,
    required this.title,
    this.description,
    this.backgroundImageUrl,
    required this.frequency,
    this.intervalDuration,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'],
      backgroundImageUrl: json['background_image_url'],
      frequency: json['frequency'] as String,
      intervalDuration: json['interval_duration']?.toString(),
      isActive: json['is_active'] ?? true,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'background_image_url': backgroundImageUrl,
      'frequency': frequency,
      'interval_duration': intervalDuration,
      'is_active': isActive,
    };
  }

  PromotionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? backgroundImageUrl,
    String? frequency,
    String? intervalDuration,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return PromotionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      frequency: frequency ?? this.frequency,
      intervalDuration: intervalDuration ?? this.intervalDuration,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  bool get isInterval => frequency == 'interval';

  bool get isOneTime => frequency == 'one_time';

  bool get isDeleted => deletedAt != null;
}

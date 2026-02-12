class DashboardCounts {
  final int events;
  final int users;
  final int lessons;
  final int tasks;

  DashboardCounts({
    required this.events,
    required this.users,
    required this.lessons,
    required this.tasks,
  });

  factory DashboardCounts.fromJson(Map<String, dynamic> json) {
    return DashboardCounts(
      events: json['events'] ?? 0,
      users: json['users'] ?? 0,
      lessons: json['lessons'] ?? 0,
      tasks: json['tasks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events,
      'users': users,
      'lessons': lessons,
      'tasks': tasks,
    };
  }
}

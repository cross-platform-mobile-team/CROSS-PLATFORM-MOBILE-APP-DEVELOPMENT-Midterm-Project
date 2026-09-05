class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.createdAt,
    this.completed = false,
  });
  final String id;
  final String title;
  final DateTime createdAt;
  final bool completed;
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter a task title';
    if (value.trim().length > 120) return 'Use 120 characters or fewer';
    return null;
  }

  TaskItem toggle() => TaskItem(
    id: id,
    title: title,
    createdAt: createdAt,
    completed: !completed,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'completed': completed,
  };
  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
    id: json['id'] as String,
    title: json['title'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    completed: json['completed'] as bool,
  );
}

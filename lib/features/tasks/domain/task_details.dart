enum TaskPriority { low, medium, high }

/// Editable metadata. Dates represent a local calendar day, without a time zone.
class TaskDetails {
  TaskDetails({
    this.notes = '',
    this.priority = TaskPriority.medium,
    DateTime? dueDate,
    Iterable<String> tags = const [],
  }) : dueDate = dueDate == null
           ? null
           : DateTime(dueDate.year, dueDate.month, dueDate.day),
       tags = List.unmodifiable(
         tags
             .map((tag) => tag.trim().toLowerCase())
             .where((tag) => tag.isNotEmpty)
             .toSet()
             .toList()
           ..sort(),
       );
  final String notes;
  final TaskPriority priority;
  final DateTime? dueDate;
  final List<String> tags;

  String? get validationError {
    if (notes.length > 2000) return 'Use 2000 characters or fewer for notes';
    if (tags.length > 10 || tags.any((tag) => tag.length > 24)) {
      return 'Use up to 10 tags, each 24 characters or fewer';
    }
    return null;
  }

  static String dateLabel(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  Map<String, dynamic> toJson() => {
    'notes': notes,
    'priority': priority.name,
    'dueDate': dueDate == null ? null : dateLabel(dueDate!),
    'tags': tags,
  };
  factory TaskDetails.fromJson(Map<String, dynamic> json) => TaskDetails(
    notes: json['notes'] as String? ?? '',
    priority: TaskPriority.values.byName(
      json['priority'] as String? ?? 'medium',
    ),
    dueDate: json['dueDate'] == null
        ? null
        : DateTime.parse(json['dueDate'] as String),
    tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
  );
}

import 'task_details.dart';
import 'task_item.dart';

enum TaskStatusFilter { all, pending, completed }

enum DueFilter { all, overdue, today, upcoming, noDate }

enum TaskSort { newest, priority, dueDate, title }

class TaskFilters {
  const TaskFilters({
    this.status = TaskStatusFilter.all,
    this.priority,
    this.due = DueFilter.all,
    this.tag = '',
    this.sort = TaskSort.newest,
  });
  final TaskStatusFilter status;
  final TaskPriority? priority;
  final DueFilter due;
  final String tag;
  final TaskSort sort;

  List<TaskItem> apply(Iterable<TaskItem> tasks, String query, DateTime now) {
    final search = query.trim().toLowerCase();
    final normalizedTag = tag.trim().toLowerCase();
    final today = DateTime(now.year, now.month, now.day);
    final result = tasks.where((task) {
      final details = task.details;
      if (!'${task.title} ${details.notes} ${details.tags.join(' ')}'
          .toLowerCase()
          .contains(search)) {
        return false;
      }
      if (status == TaskStatusFilter.pending && task.completed) return false;
      if (status == TaskStatusFilter.completed && !task.completed) return false;
      if (priority != null && details.priority != priority) return false;
      if (normalizedTag.isNotEmpty && !details.tags.contains(normalizedTag)) {
        return false;
      }
      final date = details.dueDate;
      return switch (due) {
        DueFilter.all => true,
        DueFilter.overdue =>
          date != null && date.isBefore(today) && !task.completed,
        DueFilter.today => date == today,
        DueFilter.upcoming => date != null && date.isAfter(today),
        DueFilter.noDate => date == null,
      };
    }).toList();
    result.sort((a, b) {
      int order;
      switch (sort) {
        case TaskSort.newest:
          order = b.createdAt.compareTo(a.createdAt);
        case TaskSort.priority:
          order = b.details.priority.index.compareTo(a.details.priority.index);
        case TaskSort.title:
          order = a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case TaskSort.dueDate:
          final ad = a.details.dueDate;
          final bd = b.details.dueDate;
          order = ad == null
              ? (bd == null ? 0 : 1)
              : (bd == null ? -1 : ad.compareTo(bd));
      }
      return order == 0 ? a.id.compareTo(b.id) : order;
    });
    return result;
  }
}

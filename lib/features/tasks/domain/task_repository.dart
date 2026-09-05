import 'task_item.dart';

abstract interface class TaskRepository {
  Future<List<TaskItem>> load();
  Future<void> save(List<TaskItem> tasks);
}

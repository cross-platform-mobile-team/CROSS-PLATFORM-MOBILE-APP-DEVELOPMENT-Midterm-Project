import '../domain/task_item.dart';
import '../domain/task_repository.dart';

class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository({List<TaskItem> seed = const []})
    : _tasks = List.of(seed);
  List<TaskItem> _tasks;
  bool failNext = false;
  Future<void>? gate;
  Future<void> _check() async {
    await gate;
    if (failNext) {
      failNext = false;
      throw StateError('Controlled storage failure');
    }
  }

  @override
  Future<List<TaskItem>> load() async {
    await _check();
    return List.of(_tasks);
  }

  @override
  Future<void> save(List<TaskItem> tasks) async {
    await _check();
    _tasks = List.of(tasks);
  }
}

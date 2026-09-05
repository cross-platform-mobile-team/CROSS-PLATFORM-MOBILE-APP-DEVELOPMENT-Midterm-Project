import 'package:flutter/foundation.dart';

import '../domain/task_item.dart';
import '../domain/task_repository.dart';

class TaskController extends ChangeNotifier {
  TaskController(
    this.repository, {
    DateTime Function()? clock,
    String Function()? idGenerator,
  }) : clock = clock ?? DateTime.now,
       idGenerator = idGenerator ?? _nextId;
  final TaskRepository repository;
  final DateTime Function() clock;
  final String Function() idGenerator;
  static int _sequence = 0;
  static String _nextId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';
  List<TaskItem> _tasks = [];
  bool busy = false;
  String? error;
  bool _disposed = false;
  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  List<TaskItem> matching(String query) {
    final normalized = query.trim().toLowerCase();
    final result = _tasks
        .where((task) => task.title.toLowerCase().contains(normalized))
        .toList();
    result.sort((a, b) {
      final date = b.createdAt.compareTo(a.createdAt);
      return date == 0 ? a.id.compareTo(b.id) : date;
    });
    return result;
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (busy) return false;
    busy = true;
    error = null;
    _emit();
    try {
      await action();
      return true;
    } catch (_) {
      error = 'Unable to access your tasks. Please try again.';
      return false;
    } finally {
      busy = false;
      _emit();
    }
  }

  Future<bool> load() => _run(() async {
    _tasks = await repository.load();
  });
  Future<bool> add(String title) async {
    if (TaskItem.validateTitle(title) != null) return false;
    return _run(() async {
      final task = TaskItem(
        id: idGenerator(),
        title: title.trim(),
        createdAt: clock(),
      );
      final next = [..._tasks, task];
      await repository.save(next);
      _tasks = next;
    });
  }

  Future<bool> toggle(TaskItem task) => _run(() async {
    final next = _tasks
        .map((item) => item.id == task.id ? item.toggle() : item)
        .toList();
    await repository.save(next);
    _tasks = next;
  });
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

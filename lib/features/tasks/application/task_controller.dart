import 'package:flutter/foundation.dart';

import '../domain/task_item.dart';
import '../domain/task_repository.dart';
import '../domain/task_details.dart';
import '../domain/task_filters.dart';

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
  TaskItem? _deletedTask;
  TaskItem? get deletedTask => _deletedTask;
  bool busy = false;
  String? error;
  bool _disposed = false;
  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  List<TaskItem> matching(
    String query, {
    TaskFilters filters = const TaskFilters(),
  }) => filters.apply(_tasks, query, clock());

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
  Future<bool> add(String title, {TaskDetails? details}) async {
    if (TaskItem.validateTitle(title) != null ||
        details?.validationError != null) {
      return false;
    }
    return _run(() async {
      final task = TaskItem(
        id: idGenerator(),
        title: title.trim(),
        createdAt: clock(),
        details: details,
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

  Future<bool> rename(String id, String title, {TaskDetails? details}) async {
    if (TaskItem.validateTitle(title) != null ||
        details?.validationError != null) {
      return false;
    }
    return _run(() async {
      final current = _tasks.firstWhere((item) => item.id == id);
      final updated = TaskItem(
        id: current.id,
        title: title.trim(),
        createdAt: current.createdAt,
        completed: current.completed,
        details: details ?? current.details,
      );
      final next = _tasks
          .map((item) => item.id == id ? updated : item)
          .toList();
      await repository.save(next);
      _tasks = next;
    });
  }

  Future<bool> delete(String id) => _run(() async {
    final removed = _tasks.firstWhere((item) => item.id == id);
    final next = _tasks.where((item) => item.id != id).toList();
    await repository.save(next);
    _tasks = next;
    _deletedTask = removed;
  });

  Future<bool> undoDelete() async {
    if (_deletedTask == null) return false;
    return _run(() async {
      final removed = _deletedTask!;
      if (_tasks.any((item) => item.id == removed.id)) {
        throw StateError('Cannot restore a duplicate task ID');
      }
      final next = [..._tasks, removed];
      await repository.save(next);
      _tasks = next;
      _deletedTask = null;
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

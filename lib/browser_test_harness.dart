import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/tasks/domain/task_details.dart';
import 'features/tasks/domain/task_item.dart';
import 'features/tasks/domain/task_repository.dart';
import 'features/tasks/presentation/task_screen.dart';

const _enabled = bool.fromEnvironment('TASKFLOW_BROWSER_HARNESS');

void main() {
  if (!_enabled) {
    throw StateError(
      'Browser QA harness is disabled. Build with '
      '--dart-define=TASKFLOW_BROWSER_HARNESS=true.',
    );
  }
  WidgetsFlutterBinding.ensureInitialized();
  final scenario = Uri.base.queryParameters['scenario'] ?? 'discovery';
  final repository = switch (scenario) {
    'discovery' => _BrowserHarnessRepository(seed: _discoveryTasks()),
    'failure' => _BrowserHarnessRepository(loadFailures: 1, saveFailures: 1),
    'empty' => _BrowserHarnessRepository(),
    _ => throw ArgumentError.value(scenario, 'scenario', 'Unknown QA scenario'),
  };
  runApp(
    TaskFlowApp(
      home: TaskScreen(
        repository: repository,
        notice: 'Browser QA harness: synthetic in-memory data only.',
      ),
    ),
  );
}

List<TaskItem> _discoveryTasks() => [
  _task('a', 'Alpha ready', 1),
  _task('b', 'Beta ready', 2),
  _task('c', 'Gamma ready', 3, priority: TaskPriority.low),
  _task('d', 'Delta ready', 4, completed: true),
];

TaskItem _task(
  String id,
  String title,
  int day, {
  TaskPriority priority = TaskPriority.high,
  bool completed = false,
}) => TaskItem(
  id: id,
  title: title,
  createdAt: DateTime.utc(2026, 9, day),
  completed: completed,
  details: TaskDetails(priority: priority, tags: ['flutter']),
);

class _BrowserHarnessRepository implements TaskRepository {
  _BrowserHarnessRepository({
    List<TaskItem> seed = const [],
    this.loadFailures = 0,
    this.saveFailures = 0,
  }) : _tasks = List.of(seed);

  List<TaskItem> _tasks;
  int loadFailures;
  int saveFailures;

  @override
  Future<List<TaskItem>> load() async {
    if (loadFailures > 0) {
      loadFailures--;
      throw StateError('Controlled browser load failure');
    }
    return List.of(_tasks);
  }

  @override
  Future<void> save(List<TaskItem> tasks) async {
    if (saveFailures > 0) {
      saveFailures--;
      throw StateError('Controlled browser save failure');
    }
    _tasks = List.of(tasks);
  }
}

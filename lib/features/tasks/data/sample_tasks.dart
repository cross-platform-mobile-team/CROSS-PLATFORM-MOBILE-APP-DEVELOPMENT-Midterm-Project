import '../domain/task_details.dart';
import '../domain/task_item.dart';

/// Fixed synthetic examples. Each entry into the sandbox gets new objects.
List<TaskItem> sampleTasks() => [
  TaskItem(
    id: 'sample-review',
    title: 'Review Flutter testing',
    createdAt: DateTime.utc(2026, 9, 3),
    details: TaskDetails(
      notes: 'Compare unit, widget and end-to-end tests.',
      priority: TaskPriority.high,
      tags: ['flutter', 'course'],
    ),
  ),
  TaskItem(
    id: 'sample-demo',
    title: 'Prepare the presentation',
    createdAt: DateTime.utc(2026, 9, 2),
    details: TaskDetails(
      notes: 'Use synthetic data in the recording.',
      tags: ['course'],
    ),
  ),
  TaskItem(
    id: 'sample-done',
    title: 'Read the project guide',
    createdAt: DateTime.utc(2026, 9, 1),
    completed: true,
    details: TaskDetails(priority: TaskPriority.low, tags: ['setup']),
  ),
];

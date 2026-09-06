import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_details.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_filters.dart';
import 'package:taskflow_qa_lab/features/tasks/application/task_controller.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';

void main() {
  final today = DateTime(2026, 9, 6);
  TaskItem item(
    String id, {
    TaskPriority priority = TaskPriority.medium,
    DateTime? due,
    bool completed = false,
  }) => TaskItem(
    id: id,
    title: 'Task $id',
    createdAt: today,
    completed: completed,
    details: TaskDetails(
      priority: priority,
      dueDate: due,
      notes: 'Meeting notes',
      tags: ['Work'],
    ),
  );
  test('legacy JSON receives defaults without losing old fields', () {
    final legacy = {
      'id': 'old',
      'title': 'Existing',
      'createdAt': '2026-01-01T00:00:00.000',
      'completed': true,
    };
    final task = TaskItem.fromJson(legacy);
    expect(task.completed, isTrue);
    expect(task.details.priority, TaskPriority.medium);
    expect(task.details.notes, isEmpty);
    expect(task.details.tags, isEmpty);
    expect(task.details.dueDate, isNull);
    expect(TaskItem.fromJson(task.toJson()).toJson(), task.toJson());
  });
  test('tags normalize, deduplicate, sort and cannot be mutated', () {
    final source = [' Work ', 'work', '', 'Study'];
    final details = TaskDetails(tags: source);
    source.add('later');
    expect(details.tags, ['study', 'work']);
    expect(() => details.tags.add('other'), throwsUnsupportedError);
    expect(TaskDetails(tags: ['x' * 25]).validationError, isNotNull);
    expect(TaskDetails(notes: 'x' * 2001).validationError, isNotNull);
  });
  test('calendar date round trips without time-of-day or timezone', () {
    final details = TaskDetails(dueDate: DateTime(2026, 9, 6, 23, 59));
    expect(details.toJson()['dueDate'], '2026-09-06');
    expect(TaskDetails.fromJson(details.toJson()).dueDate, today);
  });
  test('combined filters use AND, exact normalized tag and note search', () {
    final tasks = [
      item('1', priority: TaskPriority.high, due: today),
      item('2', due: today),
      item('3', priority: TaskPriority.high, completed: true, due: today),
    ];
    const filters = TaskFilters(
      status: TaskStatusFilter.pending,
      priority: TaskPriority.high,
      due: DueFilter.today,
      tag: ' WORK ',
    );
    expect(filters.apply(tasks, ' MEETING ', today).single.id, '1');
    expect(const TaskFilters(tag: 'wor').apply(tasks, '', today), isEmpty);
  });
  test(
    'due boundaries exclude completed overdue and separate future/no date',
    () {
      final tasks = [
        item('past', due: DateTime(2026, 9, 5)),
        item('done', due: DateTime(2026, 9, 5), completed: true),
        item('today', due: today),
        item('future', due: DateTime(2026, 9, 7)),
        item('none'),
      ];
      expect(
        const TaskFilters(due: DueFilter.overdue)
            .apply(tasks, '', today)
            .single
            .id,
        'past',
      );
      expect(
        const TaskFilters(due: DueFilter.today)
            .apply(tasks, '', today)
            .single
            .id,
        'today',
      );
      expect(
        const TaskFilters(due: DueFilter.upcoming)
            .apply(tasks, '', today)
            .single
            .id,
        'future',
      );
      expect(
        const TaskFilters(due: DueFilter.noDate)
            .apply(tasks, '', today)
            .single
            .id,
        'none',
      );
    },
  );
  test('priority and due sorting use stable IDs; no-date tasks sort last', () {
    final tasks = [
      item('b', priority: TaskPriority.high),
      item('a', priority: TaskPriority.high, due: today),
      item('c', priority: TaskPriority.low, due: DateTime(2026, 9, 5)),
    ];
    expect(
      const TaskFilters(sort: TaskSort.priority)
          .apply(tasks, '', today)
          .map((task) => task.id),
      ['a', 'b', 'c'],
    );
    expect(
      const TaskFilters(sort: TaskSort.dueDate)
          .apply(tasks, '', today)
          .map((task) => task.id),
      ['c', 'a', 'b'],
    );
  });
  test('save, rename-only, toggle, delete/undo preserve metadata; edit can clear date', () async {
    final repo = InMemoryTaskRepository();
    final controller = TaskController(repo, idGenerator: () => '1');
    addTearDown(controller.dispose);
    final details = TaskDetails(
      notes: 'Remember',
      priority: TaskPriority.high,
      dueDate: today,
      tags: ['Work'],
    );
    await controller.add('Task', details: details);
    await controller.rename('1', 'Renamed');
    await controller.toggle(controller.tasks.single);
    await controller.delete('1');
    await controller.undoDelete();
    expect((await repo.load()).single.details.toJson(), details.toJson());
    expect(
      await controller.rename(
        '1',
        'Invalid',
        details: TaskDetails(notes: 'x' * 2001),
      ),
      isFalse,
    );
    await controller.rename('1', 'Cleared', details: TaskDetails());
    expect((await repo.load()).single.details.dueDate, isNull);
  });
}

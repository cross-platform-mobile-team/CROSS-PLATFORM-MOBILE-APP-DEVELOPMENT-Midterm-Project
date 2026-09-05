import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/features/tasks/application/task_controller.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';

void main() {
  test('rejects blank and oversized titles', () {
    expect(TaskItem.validateTitle('   '), isNotNull);
    expect(TaskItem.validateTitle('x' * 121), isNotNull);
    expect(TaskItem.validateTitle('x' * 120), isNull);
  });
  test(
    'creates deterministic task and finds a case-insensitive substring',
    () async {
      final repository = InMemoryTaskRepository();
      final now = DateTime.utc(2026, 9, 5);
      final controller = TaskController(
        repository,
        clock: () => now,
        idGenerator: () => 'task-1',
      );
      addTearDown(controller.dispose);
      expect(await controller.add('  Review Flutter testing  '), isTrue);
      expect(
        controller.matching(' FLUTTER ').single.title,
        'Review Flutter testing',
      );
      expect(controller.tasks.single.createdAt, now);
      expect(controller.tasks.single.id, 'task-1');
      await controller.toggle(controller.tasks.single);
      expect((await repository.load()).single.completed, isTrue);
    },
  );
  test(
    'failed write does not publish unpersisted task; load retry recovers',
    () async {
      final repository = InMemoryTaskRepository()..failNext = true;
      final controller = TaskController(repository);
      addTearDown(controller.dispose);
      expect(await controller.add('Task'), isFalse);
      expect(controller.tasks, isEmpty);
      expect(controller.error, isNotNull);
      expect(await controller.load(), isTrue);
      expect(controller.error, isNull);
    },
  );
  test('task JSON round trip preserves fields', () {
    final task = TaskItem(
      id: '1',
      title: 'Read',
      createdAt: DateTime.utc(2026),
      completed: true,
    );
    expect(TaskItem.fromJson(task.toJson()).toJson(), task.toJson());
  });
}

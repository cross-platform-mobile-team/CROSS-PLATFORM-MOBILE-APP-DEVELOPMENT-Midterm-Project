import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/features/tasks/application/task_controller.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';

void main() {
  late TaskController controller;
  late InMemoryTaskRepository repository;
  final first = TaskItem(
    id: '1',
    title: 'First',
    createdAt: DateTime.utc(2026),
    completed: true,
  );
  final second = TaskItem(
    id: '2',
    title: 'Second',
    createdAt: DateTime.utc(2026),
  );
  setUp(() async {
    repository = InMemoryTaskRepository(seed: [first, second]);
    controller = TaskController(repository);
    await controller.load();
  });
  tearDown(() => controller.dispose());

  test('edit preserves identity, creation time and completed state', () async {
    expect(await controller.rename('1', '  Updated  '), isTrue);
    final stored = (await repository.load()).first;
    expect(stored.title, 'Updated');
    expect(stored.id, first.id);
    expect(stored.createdAt, first.createdAt);
    expect(stored.completed, isTrue);
    expect(await controller.rename('1', '  '), isFalse);
    expect(controller.tasks.first.title, 'Updated');
  });

  test('failed edit retains persisted data and can retry', () async {
    repository.failNext = true;
    expect(await controller.rename('1', 'Changed'), isFalse);
    expect(controller.tasks.first.title, 'First');
    expect((await repository.load()).first.title, 'First');
    expect(await controller.rename('1', 'Changed'), isTrue);
  });

  test(
    'delete and undo preserve all fields and deterministic ordering',
    () async {
      expect(await controller.delete('1'), isTrue);
      expect((await repository.load()).map((task) => task.id), ['2']);
      expect(await controller.undoDelete(), isTrue);
      expect(controller.matching('').map((task) => task.id), ['1', '2']);
      expect(controller.matching('').first.toJson(), first.toJson());
      expect(controller.deletedTask, isNull);
      expect(await controller.undoDelete(), isFalse);
    },
  );

  test(
    'failed delete retains tasks; failed undo retains recovery opportunity',
    () async {
      repository.failNext = true;
      expect(await controller.delete('1'), isFalse);
      expect(controller.tasks.length, 2);
      expect(controller.deletedTask, isNull);
      await controller.delete('1');
      repository.failNext = true;
      expect(await controller.undoDelete(), isFalse);
      expect(controller.tasks.length, 1);
      expect(controller.deletedTask!.id, '1');
      expect(await controller.undoDelete(), isTrue);
      expect((await repository.load()).length, 2);
    },
  );

  test('only latest successful deletion is undoable', () async {
    await controller.delete('1');
    expect(await controller.delete('missing'), isFalse);
    expect(controller.deletedTask!.id, '1');
    await controller.delete('2');
    await controller.undoDelete();
    expect(controller.tasks.single.id, '2');
  });

  test('in-flight deletion prevents concurrent mutation', () async {
    final gate = Completer<void>();
    repository.gate = gate.future;
    final deletion = controller.delete('1');
    expect(controller.busy, isTrue);
    expect(await controller.rename('2', 'Race'), isFalse);
    gate.complete();
    expect(await deletion, isTrue);
    expect(controller.tasks.single.title, 'Second');
  });
}

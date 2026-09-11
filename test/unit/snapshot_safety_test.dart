import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/features/tasks/application/task_controller.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';

void main() {
  final saved = TaskItem(
    id: 'saved',
    title: 'Keep my data',
    createdAt: DateTime.utc(2026),
  );
  test('unloaded controller cannot overwrite an existing snapshot', () async {
    final repo = InMemoryTaskRepository(seed: [saved]);
    final controller = TaskController(repo);
    addTearDown(controller.dispose);
    expect(await controller.add('New draft'), isFalse);
    expect((await repo.load()).single.toJson(), saved.toJson());
  });

  test('failed load blocks writes until explicit successful reload', () async {
    final repo = InMemoryTaskRepository(seed: [saved])..failNext = true;
    final controller = TaskController(repo);
    addTearDown(controller.dispose);
    expect(await controller.load(), isFalse);
    expect(await controller.add('New draft'), isFalse);
    expect((await repo.load()).single.toJson(), saved.toJson());
    expect(await controller.load(), isTrue);
    expect(await controller.add('New draft'), isTrue);
    expect((await repo.load()).map((t) => t.title), [
      'Keep my data',
      'New draft',
    ]);
  });

  test('failed reload blocks stale edit delete toggle and undo', () async {
    final repo = InMemoryTaskRepository(seed: [saved]);
    final controller = TaskController(repo);
    addTearDown(controller.dispose);
    await controller.load();
    await controller.delete(saved.id);
    repo.failNext = true;
    expect(await controller.load(), isFalse);
    expect(await controller.undoDelete(), isFalse);
    expect(await controller.rename(saved.id, 'Wrong'), isFalse);
    expect(await controller.delete(saved.id), isFalse);
    expect(await controller.toggle(saved), isFalse);
    expect(await repo.load(), isEmpty);
    await controller.load();
    expect(await controller.undoDelete(), isTrue);
  });
}

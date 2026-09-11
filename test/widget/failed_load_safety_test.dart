import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/task_screen.dart';

void main() {
  testWidgets('failed initial load preserves saved records and new draft', (
    tester,
  ) async {
    final saved = TaskItem(
      id: 'original',
      title: 'Original record',
      createdAt: DateTime.utc(2026),
    );
    final repo = InMemoryTaskRepository(seed: [saved])..failNext = true;
    await tester.pumpWidget(TaskFlowApp(home: TaskScreen(repository: repo)));
    await tester.pumpAndSettle();
    final title = find.byKey(const Key('task-title'));
    await tester.enterText(title, 'Keep this draft');
    await tester.ensureVisible(find.text('Add task'));
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    expect((await repo.load()).single.toJson(), saved.toJson());
    expect(
      tester.widget<TextFormField>(title).controller!.text,
      'Keep this draft',
    );
    await tester.ensureVisible(find.text('Retry'));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Original record'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(title).controller!.text,
      'Keep this draft',
    );
    await tester.ensureVisible(find.text('Add task'));
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    expect((await repo.load()).map((t) => t.title), [
      'Original record',
      'Keep this draft',
    ]);
    expect(tester.widget<TextFormField>(title).controller!.text, isEmpty);
  });
}

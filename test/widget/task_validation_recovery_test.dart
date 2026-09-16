import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/edit_task_dialog.dart';

import '../support/metadata_workflow.dart';
import '../support/visual_fixture.dart';

void main() {
  void expectFocused(WidgetTester tester, String key) {
    final input = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(EditableText),
      ),
    );
    expect(input.focusNode.hasFocus, isTrue, reason: '$key receives focus');
  }

  for (final width in [390.0, 1100.0]) {
    testWidgets('collapsed invalid details reveal and recover at $width', (
      tester,
    ) async {
      configureViewport(tester, Size(width, 900));
      final repository = InMemoryTaskRepository();
      await tester.pumpWidget(TaskFlowApp(repository: repository));
      await tester.pumpAndSettle();
      await enterVisible(tester, 'task-title', 'Recover metadata');
      await tapVisible(tester, find.text('Task details (optional)'));
      await enterVisible(tester, 'task-notes', 'n' * 2001);
      await enterVisible(tester, 'task-due-date', '2026-02-30');
      await enterVisible(tester, 'task-tags', 't' * 25);

      Future<void> submitCollapsed(String key, String error) async {
        await tapVisible(tester, find.text('Task details (optional)'));
        expect(find.byKey(Key(key)), findsNothing);
        await tapVisible(tester, find.text('Add task'));
        expect(find.text(error), findsOneWidget);
        expectFocused(tester, key);
        expect(await repository.load(), isEmpty);
      }

      await submitCollapsed('task-notes', 'Use 2000 characters or fewer');
      await enterVisible(tester, 'task-notes', 'Preserved notes');
      await submitCollapsed(
        'task-due-date',
        'Enter a valid date as YYYY-MM-DD',
      );
      await enterVisible(tester, 'task-due-date', '2026-02-28');
      await submitCollapsed(
        'task-tags',
        'Use up to 10 tags, each 24 characters or fewer',
      );
      await enterVisible(tester, 'task-tags', 'Study, qa');
      await tapVisible(tester, find.text('Add task'));

      final saved = (await repository.load()).single;
      expect(saved.title, 'Recover metadata');
      expect(saved.details.notes, 'Preserved notes');
      expect(saved.details.dueDate, DateTime(2026, 2, 28));
      expect(saved.details.tags, ['qa', 'study']);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('quick create invalid title restores focus', (tester) async {
    configureViewport(tester, const Size(390, 900));
    final repository = InMemoryTaskRepository();
    await tester.pumpWidget(TaskFlowApp(repository: repository));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Add task'));
    expect(find.text('Enter a task title'), findsOneWidget);
    expectFocused(tester, 'task-title');
    expect(await repository.load(), isEmpty);
  });

  testWidgets('edit submit focuses first invalid field before saving', (
    tester,
  ) async {
    configureViewport(tester, const Size(390, 900));
    var writes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditTaskDialog(
            task: TaskItem(
              id: 'focus',
              title: 'Original',
              createdAt: DateTime(2026),
            ),
            save: (_, _) async {
              writes++;
              return false;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await enterVisible(tester, 'edit-task-title', '');
    await enterVisible(tester, 'task-due-date', 'not a date');
    await tapVisible(tester, find.text('Save changes'));
    expectFocused(tester, 'edit-task-title');
    expect(writes, 0);
    await enterVisible(tester, 'edit-task-title', 'Corrected');
    await tapVisible(tester, find.text('Save changes'));
    expectFocused(tester, 'task-due-date');
    expect(writes, 0);
    await enterVisible(tester, 'task-due-date', '2026-09-16');
    await tapVisible(tester, find.text('Save changes'));
    expect(writes, 1);
    expect(find.text('Corrected'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

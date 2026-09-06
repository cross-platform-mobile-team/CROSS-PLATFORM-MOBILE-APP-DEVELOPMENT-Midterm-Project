import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';

void main() {
  for (final width in [390.0, 1100.0]) {
    testWidgets('edit, cancel deletion, delete and undo at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = InMemoryTaskRepository(
        seed: [
          TaskItem(id: '1', title: 'Original', createdAt: DateTime.utc(2026)),
        ],
      );
      await tester.pumpWidget(TaskFlowApp(repository: repository));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('edit-task-title')), ' ');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a task title'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('edit-task-title')),
        'Updated',
      );
      repository.failNext = true;
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not save. Your changes are still here. Try again.'),
        findsOneWidget,
      );
      expect(find.text('Updated'), findsOneWidget);
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Updated'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Updated'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Updated'), findsNothing);
      expect((await repository.load()), isEmpty);
      await tester.tap(find.text('Undo delete'));
      await tester.pumpAndSettle();
      expect(find.text('Updated'), findsOneWidget);
      expect((await repository.load()).single.title, 'Updated');
      expect(tester.takeException(), isNull);
    });
  }
}

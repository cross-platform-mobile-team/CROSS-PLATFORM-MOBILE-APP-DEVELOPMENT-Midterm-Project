import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';

void main() {
  for (final width in [390.0, 1100.0]) {
    testWidgets('validate, create and complete at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        TaskFlowApp(repository: InMemoryTaskRepository()),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('No tasks yet. Add your first task above.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Add task'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a task title'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('task-title')),
        'Read the test guide',
      );
      await tester.tap(find.text('Add task'));
      await tester.pumpAndSettle();
      expect(find.text('Read the test guide'), findsOneWidget);
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      expect(find.text('Completed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('storage failure offers retry and recovers', (tester) async {
    await tester.pumpWidget(
      TaskFlowApp(repository: InMemoryTaskRepository()..failNext = true),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(
      find.text('No tasks yet. Add your first task above.'),
      findsOneWidget,
    );
  });
}

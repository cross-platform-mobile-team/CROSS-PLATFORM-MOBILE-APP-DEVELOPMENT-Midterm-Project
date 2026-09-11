import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';

import '../support/visual_fixture.dart';

void main() {
  testWidgets(
    'desktop status navigation filters without changing stored tasks',
    (tester) async {
      configureViewport(tester, const Size(1280, 900));
      final repository = InMemoryTaskRepository(seed: visualTasks());
      await tester.pumpWidget(TaskFlowApp(repository: repository));
      await tester.pumpAndSettle();
      expect(find.text('WORKSPACE'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, 'To do'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(CheckboxListTile, 'Review the testing plan'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CheckboxListTile, 'Prepare sample data'),
        findsNothing,
      );
      await tester.tap(find.widgetWithText(ListTile, 'Completed tasks'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(CheckboxListTile, 'Prepare sample data'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CheckboxListTile, 'Review the testing plan'),
        findsNothing,
      );
      await tester.tap(find.widgetWithText(ListTile, 'All tasks'));
      await tester.pumpAndSettle();
      expect(find.byType(CheckboxListTile), findsNWidgets(2));
      expect((await repository.load()).length, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('large text switches desktop rail to single-column workspace', (
    tester,
  ) async {
    configureViewport(tester, const Size(1100, 900));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(TaskFlowApp(repository: InMemoryTaskRepository()));
    await tester.pumpAndSettle();
    expect(find.text('WORKSPACE'), findsNothing);
    expect(find.byKey(const Key('task-title')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

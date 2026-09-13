import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_details.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_filters.dart';

import '../support/visual_fixture.dart';
import '../support/metadata_workflow.dart';

void main() {
  testWidgets('sort menu orders tasks and preserves status filter', (
    tester,
  ) async {
    configureViewport(tester, const Size(1280, 900));
    final repository = InMemoryTaskRepository(seed: visualTasks());
    await tester.pumpWidget(TaskFlowApp(repository: repository));
    await tester.pumpAndSettle();
    expect(find.text('1/2 completed'), findsOneWidget);
    await tapVisible(tester, find.byTooltip('Sort tasks'));
    await tapVisible(
      tester,
      find.widgetWithText(CheckedPopupMenuItem<TaskSort>, 'Title A–Z'),
    );
    final rows = tester
        .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
        .toList();
    expect((rows.first.title! as Text).data, 'Prepare sample data');
    await tapVisible(tester, find.widgetWithText(ListTile, 'To do'));
    await tapVisible(tester, find.byTooltip('Sort tasks'));
    await tapVisible(
      tester,
      find.widgetWithText(CheckedPopupMenuItem<TaskSort>, 'Priority'),
    );
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(
      find.widgetWithText(CheckboxListTile, 'Review the testing plan'),
      findsOneWidget,
    );
    expect((await repository.load()).length, 2);
    expect(tester.takeException(), isNull);
  });
  testWidgets('search shortcuts focus the actual field', (tester) async {
    configureViewport(tester, const Size(1280, 900));
    await tester.pumpWidget(TaskFlowApp(repository: InMemoryTaskRepository()));
    await tester.pumpAndSettle();
    for (final modifier in [
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.metaLeft,
    ]) {
      await tester.sendKeyDownEvent(modifier);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(modifier);
      await tester.pumpAndSettle();
      final input = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Search tasks'),
      );
      expect(input.focusNode!.hasFocus, isTrue, reason: modifier.debugName);
      await tester.tap(find.byKey(const Key('task-title')));
      await tester.pump();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick priority and date save and reset together', (
    tester,
  ) async {
    configureViewport(tester, const Size(1280, 900));
    final repository = InMemoryTaskRepository();
    await tester.pumpWidget(TaskFlowApp(repository: repository));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byTooltip('Quick priority'));
    await tapVisible(tester, find.text('high').last);
    await tapVisible(tester, find.byTooltip('Choose due date'));
    await tapVisible(tester, find.text('OK'));
    await enterVisible(tester, 'task-title', 'Quick capture');
    await tapVisible(tester, find.text('Add task'));
    final saved = (await repository.load()).single;
    expect(saved.details.priority, TaskPriority.high);
    expect(saved.details.dueDate, isNotNull);
    await enterVisible(tester, 'task-title', 'Fresh capture');
    await tapVisible(tester, find.text('Add task'));
    final fresh = (await repository.load()).singleWhere(
      (t) => t.title == 'Fresh capture',
    );
    expect(fresh.details.priority, TaskPriority.medium);
    expect(fresh.details.dueDate, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('resize keeps raw draft and large text does not overflow', (
    tester,
  ) async {
    configureViewport(tester, const Size(1280, 900));
    await tester.pumpWidget(TaskFlowApp(repository: InMemoryTaskRepository()));
    await tester.pumpAndSettle();
    await enterVisible(tester, 'task-title', 'Keep across resize');
    await tapVisible(tester, find.text('Task details (optional)'));
    await enterVisible(tester, 'task-due-date', 'invalid date');
    for (final size in [const Size(390, 900), const Size(1280, 600)]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('task-title')))
            .controller!
            .text,
        'Keep across resize',
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('task-due-date')))
            .controller!
            .text,
        'invalid date',
      );
      expect(tester.takeException(), isNull);
    }
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';

const emptyMessage = 'No tasks yet. Add your first task above.';
const errorMessage = 'Unable to access your tasks. Please try again.';

void main() {
  Finder addButton() => find.widgetWithText(FilledButton, 'Add task');

  Completer<void> hold(InMemoryTaskRepository repository) {
    final gate = Completer<void>();
    repository.gate = gate.future;
    addTearDown(() {
      if (!gate.isCompleted) gate.complete();
    });
    return gate;
  }

  void expectLoading(WidgetTester tester) {
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .semanticsLabel,
      'Loading tasks',
    );
    expect(tester.widget<FilledButton>(addButton()).onPressed, isNull);
    expect(find.text(emptyMessage), findsNothing);
  }

  for (final width in [390.0, 1100.0]) {
    testWidgets('initial loading blocks submit then shows data at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = InMemoryTaskRepository(
        seed: [
          TaskItem(
            id: 'loading-fixture',
            title: 'Loaded task',
            createdAt: DateTime.utc(2026, 9, 10),
          ),
        ],
      );
      final gate = hold(repository);
      await tester.pumpWidget(TaskFlowApp(repository: repository));
      expectLoading(tester);
      expect(find.byType(CheckboxListTile), findsNothing);

      await tester.enterText(find.byKey(const Key('task-title')), 'Keep draft');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      // Never settle while an unresolved operation keeps the progress bar active.
      await tester.pump();
      expectLoading(tester);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(
        find.widgetWithText(CheckboxListTile, 'Loaded task'),
        findsOneWidget,
      );
      expect(find.byType(CheckboxListTile), findsOneWidget);
      expect(tester.widget<FilledButton>(addButton()).onPressed, isNotNull);
      expect((await repository.load()).single.id, 'loading-fixture');
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('task-title')))
            .controller!
            .text,
        'Keep draft',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('loading failure and gated retry resolve to empty state', (
    tester,
  ) async {
    final repository = InMemoryTaskRepository()..failNext = true;
    final firstLoad = hold(repository);
    await tester.pumpWidget(TaskFlowApp(repository: repository));
    expectLoading(tester);
    expect(find.text(errorMessage), findsNothing);

    firstLoad.complete();
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text(errorMessage), findsOneWidget);
    expect(find.text(emptyMessage), findsNothing);

    final retry = hold(repository);
    await tester.ensureVisible(find.text('Retry'));
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expectLoading(tester);
    expect(find.text(errorMessage), findsNothing);

    retry.complete();
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text(errorMessage), findsNothing);
    expect(find.text(emptyMessage), findsOneWidget);
    expect(tester.widget<FilledButton>(addButton()).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending save retains draft and prevents duplicate submission', (
    tester,
  ) async {
    final repository = InMemoryTaskRepository();
    await tester.pumpWidget(TaskFlowApp(repository: repository));
    await tester.pumpAndSettle();
    final gate = hold(repository);
    final title = find.byKey(const Key('task-title'));
    await tester.enterText(title, 'Save exactly once');
    await tester.tap(addButton());
    await tester.pump();
    expectLoading(tester);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(
      tester.widget<TextFormField>(title).controller!.text,
      'Save exactly once',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expectLoading(tester);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(
      find.widgetWithText(CheckboxListTile, 'Save exactly once'),
      findsOneWidget,
    );
    expect((await repository.load()).single.title, 'Save exactly once');
    expect(tester.widget<TextFormField>(title).controller!.text, isEmpty);
    expect(tester.widget<FilledButton>(addButton()).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });
}

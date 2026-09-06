import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';

import '../support/visual_fixture.dart';

void main() {
  setUpAll(loadVisualFonts);
  for (final state in ['empty', 'populated', 'error', 'validation']) {
    testWidgets('accessibility guidelines: $state', (tester) async {
      configureViewport(tester, const Size(390, 960));
      final repository = InMemoryTaskRepository(
        seed: state == 'populated' ? visualTasks() : [],
      )..failNext = state == 'error';
      await tester.pumpWidget(TaskFlowApp(repository: repository));
      await tester.pumpAndSettle();
      if (state == 'validation') {
        await tester.tap(find.text('Add task'));
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel(RegExp('Enter a task title')),
          findsWidgets,
        );
      }
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  }
  testWidgets('keyboard traverses from title and submits a task', (
    tester,
  ) async {
    final repository = InMemoryTaskRepository();
    await tester.pumpWidget(TaskFlowApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('task-title')));
    await tester.enterText(
      find.byKey(const Key('task-title')),
      'Keyboard task',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(const Key('task-title')),
              matching: find.byType(EditableText),
            ),
          )
          .focusNode
          .hasFocus,
      isFalse,
    );
    await tester.tap(find.byKey(const Key('task-title')));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect((await repository.load()).single.title, 'Keyboard task');
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
  testWidgets('large text at phone width keeps controls usable', (
    tester,
  ) async {
    configureViewport(tester, const Size(390, 960));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      TaskFlowApp(repository: InMemoryTaskRepository(seed: visualTasks())),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Edit').first,
      180,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 20,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

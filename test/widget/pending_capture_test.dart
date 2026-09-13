import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';

void main() {
  for (final width in [390.0, 1280.0]) {
    for (final fail in [false, true]) {
      testWidgets(
        'pending capture preserves newer title at $width fail=$fail',
        (tester) async {
          tester.view.physicalSize = Size(width, 960);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final repository = InMemoryTaskRepository();
          await tester.pumpWidget(TaskFlowApp(repository: repository));
          await tester.pumpAndSettle();
          final input = find.byKey(const Key('task-title'));
          await tester.enterText(input, 'First task');
          final gate = Completer<void>();
          addTearDown(() {
            if (!gate.isCompleted) gate.complete();
          });
          repository.gate = gate.future;
          repository.failNext = fail;
          await tester.tap(find.widgetWithText(FilledButton, 'Add task'));
          await tester.pump();
          await tester.enterText(input, 'Second draft');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pump();
          gate.complete();
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextFormField>(input).controller!.text,
            'Second draft',
          );
          expect(
            (await repository.load()).map((task) => task.title),
            fail ? isEmpty : orderedEquals(['First task']),
          );
          await tester.tap(find.widgetWithText(FilledButton, 'Add task'));
          await tester.pumpAndSettle();
          expect(
            (await repository.load()).map((task) => task.title),
            unorderedEquals(
              fail ? ['Second draft'] : ['First task', 'Second draft'],
            ),
          );
          expect(tester.widget<TextFormField>(input).controller!.text, isEmpty);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_details.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/edit_task_dialog.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    Future<bool> Function(String, TaskDetails)? save,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => EditTaskDialog(
                    task: TaskItem(
                      id: 'draft',
                      title: 'Original',
                      createdAt: DateTime(2026),
                    ),
                    save: save ?? (_, _) async => true,
                  ),
                ),
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('unchanged and reverted edits close without confirmation', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byKey(const Key('edit-task-title')), 'Changed');
    await tester.enterText(
      find.byKey(const Key('edit-task-title')),
      'Original',
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('Edit task'), findsNothing);
  });

  testWidgets('cancel preserves draft or discards without saving', (
    tester,
  ) async {
    var writes = 0;
    await open(
      tester,
      save: (_, _) async {
        writes++;
        return true;
      },
    );
    await tester.enterText(find.byKey(const Key('edit-task-title')), 'Changed');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue editing'));
    await tester.pumpAndSettle();
    expect(find.text('Changed'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Edit task'), findsNothing);
    expect(writes, 0);
  });

  testWidgets('invalid raw date is protected on back and Escape', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byKey(const Key('task-due-date')), 'invalid');
    await tester.pump();
    final context = tester.element(find.byType(EditTaskDialog));
    await Navigator.of(context).maybePop();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Continue editing'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    expect(find.text('invalid'), findsOneWidget);
  });

  testWidgets('pending save prevents dismissal and duplicate writes', (
    tester,
  ) async {
    final gate = Completer<bool>();
    var writes = 0;
    await open(
      tester,
      save: (_, _) {
        writes++;
        return gate.future;
      },
    );
    await tester.enterText(find.byKey(const Key('edit-task-title')), 'Saved');
    await tester.tap(find.text('Save changes'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text('Edit task'), findsOneWidget);
    expect(find.text('Discard changes?'), findsNothing);
    expect(writes, 1);
    gate.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('Edit task'), findsNothing);
  });

  testWidgets('compact large text confirmation remains usable', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await open(tester, textScale: 2);
    await tester.enterText(find.byKey(const Key('edit-task-title')), 'Draft');
    await tester.ensureVisible(find.text('Cancel'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.ensureVisible(find.text('Continue editing'));
    await tester.tap(find.text('Continue editing'));
    await tester.pumpAndSettle();
    expect(find.text('Draft'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

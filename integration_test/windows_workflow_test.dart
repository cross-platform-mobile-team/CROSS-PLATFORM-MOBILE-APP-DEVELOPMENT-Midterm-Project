import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/local_task_repository.dart';

import '../test/support/metadata_workflow.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // The Windows IME can echo stale edits while tester.enterText injects text.
  // Register Flutter's test input channel; rendering and storage remain native.
  setUp(binding.testTextInput.register);
  tearDown(binding.testTextInput.unregister);

  testWidgets('native create, edit, complete, delete, undo and reload', (
    tester,
  ) async {
    const key = 'taskflow.integration.windows.v1';
    final preferences = SharedPreferencesAsync();
    await preferences.remove(key);
    addTearDown(() => preferences.remove(key));
    await tester.pumpWidget(
      TaskFlowApp(repository: LocalTaskRepository(key: key)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('task-title')),
      'Windows persistence check',
    );
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    expect(find.text('Windows persistence check'), findsOneWidget);
    await tapVisible(tester, find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('edit-task-title')),
      'Updated on Windows',
    );
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Updated on Windows'), findsOneWidget);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);

    await tapVisible(tester, find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ),
    );
    await tester.pumpAndSettle();
    expect(await LocalTaskRepository(key: key).load(), isEmpty);
    await tapVisible(tester, find.text('Undo delete'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      TaskFlowApp(repository: LocalTaskRepository(key: key)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Updated on Windows'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(
      (await LocalTaskRepository(key: key).load()).single.completed,
      isTrue,
    );
  });

  testWidgets('native metadata form and filters persist across remount', (
    tester,
  ) async {
    const key = 'taskflow.integration.metadata.v1';
    final preferences = SharedPreferencesAsync();
    await preferences.remove(key);
    addTearDown(() => preferences.remove(key));
    await tester.pumpWidget(
      TaskFlowApp(repository: LocalTaskRepository(key: key)),
    );
    await tester.pumpAndSettle();
    await metadataWorkflow(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      TaskFlowApp(repository: LocalTaskRepository(key: key)),
    );
    await tester.pumpAndSettle();
    final task = (await LocalTaskRepository(key: key).load()).single;
    expect(task.title, 'Prepare presentation');
    expect(task.details.notes, 'Updated diagrams');
    expect(task.details.dueDate, isNull);
    expect(task.details.priority.name, 'high');
    expect(task.details.tags, ['flutter']);
    expect(find.text('Prepare presentation'), findsOneWidget);
  });
}

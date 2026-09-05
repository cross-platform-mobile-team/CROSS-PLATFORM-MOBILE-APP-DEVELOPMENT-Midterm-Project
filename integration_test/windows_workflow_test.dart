import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/local_task_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native create, complete and reload with real local storage', (
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
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      TaskFlowApp(repository: LocalTaskRepository(key: key)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Windows persistence check'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(
      (await LocalTaskRepository(key: key).load()).single.completed,
      isTrue,
    );
  });
}

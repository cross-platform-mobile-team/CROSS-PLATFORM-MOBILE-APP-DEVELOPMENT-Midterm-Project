import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_details.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';

import '../test/support/metadata_workflow.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(binding.testTextInput.register);
  tearDown(binding.testTextInput.unregister);

  Future<void> launch(
    WidgetTester tester,
    InMemoryTaskRepository repository, {
    double width = 1100,
  }) async {
    // Logical viewport override, not an Android device or physical window resize.
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 1600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(TaskFlowApp(repository: repository));
    await tester.pumpAndSettle();
  }

  List<String> titles(WidgetTester tester) => tester
      .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
      .map((tile) => (tile.title! as Text).data!)
      .toList();

  for (final width in [390.0, 1100.0]) {
    testWidgets('independent empty validation correction at width $width', (
      tester,
    ) async {
      final repository = InMemoryTaskRepository();
      await launch(tester, repository, width: width);
      expect(
        find.text('No tasks yet. Add your first task above.'),
        findsOneWidget,
      );
      await tapVisible(tester, find.text('Add task'));
      expect(find.text('Enter a task title'), findsOneWidget);
      expect(await repository.load(), isEmpty);
      await enterVisible(tester, 'task-title', 'Corrected task');
      await tapVisible(tester, find.text('Add task'));
      expect(titles(tester), ['Corrected task']);
      expect((await repository.load()).single.title, 'Corrected task');
      expect(find.text('Enter a task title'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('independent seeded search AND filters and deterministic order', (
    tester,
  ) async {
    TaskItem seeded(
      String id,
      String title,
      int day, {
      TaskPriority priority = TaskPriority.high,
      bool completed = false,
    }) => TaskItem(
      id: id,
      title: title,
      createdAt: DateTime.utc(2026, 9, day),
      completed: completed,
      details: TaskDetails(priority: priority, tags: ['flutter']),
    );
    final repository = InMemoryTaskRepository(
      seed: [
        seeded('a', 'Alpha ready', 1),
        seeded('b', 'Beta ready', 2),
        seeded('c', 'Gamma ready', 3, priority: TaskPriority.low),
        seeded('d', 'Delta ready', 4, completed: true),
      ],
    );
    await launch(tester, repository);
    expect(titles(tester), [
      'Delta ready',
      'Gamma ready',
      'Beta ready',
      'Alpha ready',
    ]);
    final search = find.widgetWithText(TextField, 'Search tasks');
    await tester.enterText(search, '  READY  ');
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Filter and sort'));
    for (final choice in {
      'filter-status': 'pending',
      'filter-priority': 'high',
      'filter-sort': 'title',
    }.entries) {
      await tapVisible(tester, find.byKey(Key(choice.key)));
      await tapVisible(tester, find.text(choice.value).last);
    }
    await enterVisible(tester, 'filter-tag', ' FLUTTER ');
    await tapVisible(tester, find.text('Apply'));
    expect(titles(tester), ['Alpha ready', 'Beta ready']);
    expect(
      tester.getTopLeft(find.text('Alpha ready')).dy,
      lessThan(tester.getTopLeft(find.text('Beta ready')).dy),
    );
    await tester.enterText(search, 'missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching tasks.'), findsOneWidget);
    await tapVisible(tester, find.text('Clear filters'));
    expect(titles(tester), [
      'Delta ready',
      'Gamma ready',
      'Beta ready',
      'Alpha ready',
    ]);
    expect((await repository.load()).length, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'independent load and save failure recover without losing draft',
    (tester) async {
      const error = 'Unable to access your tasks. Please try again.';
      final repository = InMemoryTaskRepository()..failNext = true;
      await launch(tester, repository);
      expect(find.text(error), findsOneWidget);
      // A completion gate makes loading observable without wall-clock sleeps.
      final gate = Completer<void>();
      repository.gate = gate.future;
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Add task'))
            .onPressed,
        isNull,
      );
      gate.complete();
      await tester.pumpAndSettle();
      expect(find.text(error), findsNothing);
      expect(
        find.text('No tasks yet. Add your first task above.'),
        findsOneWidget,
      );
      repository.failNext = true;
      await enterVisible(tester, 'task-title', 'Keep my draft');
      await tapVisible(tester, find.text('Add task'));
      expect(find.text(error), findsOneWidget);
      expect(await repository.load(), isEmpty);
      expect(titles(tester), isEmpty);
      await tapVisible(tester, find.text('Retry'));
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('task-title')))
            .controller!
            .text,
        'Keep my draft',
      );
      await tapVisible(tester, find.text('Add task'));
      expect(titles(tester), ['Keep my draft']);
      expect((await repository.load()).single.title, 'Keep my draft');
      expect(find.text(error), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

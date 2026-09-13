import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/local_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_details.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';

import '../test/support/metadata_workflow.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(binding.testTextInput.register);
  tearDown(binding.testTextInput.unregister);

  Future<LocalTaskRepository> fresh(
    String scenario,
    List<TaskItem> seed,
  ) async {
    final key = 'taskflow.integration.persisted.$scenario.v1';
    final preferences = SharedPreferencesAsync();
    await preferences.remove(key);
    addTearDown(() => preferences.remove(key));
    final repository = LocalTaskRepository(key: key);
    if (seed.isNotEmpty) await repository.save(seed);
    return repository;
  }

  Future<void> mount(WidgetTester tester, String key) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      TaskFlowApp(repository: LocalTaskRepository(key: key)),
    );
    await tester.pumpAndSettle();
  }

  Finder card(String title) => find.ancestor(
    of: find.widgetWithText(CheckboxListTile, title),
    matching: find.byType(Card),
  );
  Finder action(String title, String label) =>
      find.descendant(of: card(title), matching: find.text(label));

  TaskItem fixture(String id, String title, {bool completed = false}) =>
      TaskItem(
        id: id,
        title: title,
        createdAt: DateTime.utc(2026, 9, 1, 9),
        completed: completed,
        details: TaskDetails(
          notes: 'Preserve these notes',
          priority: TaskPriority.high,
          dueDate: DateTime(2026, 9, 30),
          tags: ['flutter', 'course'],
        ),
      );

  testWidgets('independent persisted fresh create and remount', (tester) async {
    final repository = await fresh('create', []);
    await mount(tester, repository.key);
    expect(
      find.text('No tasks yet. Add your first task above.'),
      findsOneWidget,
    );
    await enterVisible(tester, 'task-title', 'Fresh persisted task');
    await tapVisible(tester, find.text('Add task'));
    final saved = (await repository.load()).single;
    expect(saved.title, 'Fresh persisted task');
    expect(saved.completed, isFalse);
    expect(saved.id, isNotEmpty);
    await mount(tester, repository.key);
    expect(find.widgetWithText(CheckboxListTile, saved.title), findsOneWidget);
    expect(
      (await LocalTaskRepository(key: repository.key).load()).single.toJson(),
      saved.toJson(),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'independent persisted edit complete and remount preserves metadata',
    (tester) async {
      final target = fixture('edit-target', 'Edit this task');
      final repository = await fresh('edit', [target]);
      await mount(tester, repository.key);
      await tapVisible(tester, action(target.title, 'Edit'));
      await enterVisible(tester, 'edit-task-title', 'Edited persisted task');
      await enterVisible(tester, 'task-notes', 'Edited notes');
      await tapVisible(tester, find.text('Cancel'));
      expect(find.text('Discard changes?'), findsOneWidget);
      expect((await repository.load()).single.toJson(), target.toJson());
      await tapVisible(tester, find.text('Continue editing'));
      expect(find.text('Edited notes'), findsOneWidget);
      await tapVisible(tester, find.text('Save changes'));
      expect(find.byType(AlertDialog), findsNothing);
      await tapVisible(
        tester,
        find.widgetWithText(CheckboxListTile, 'Edited persisted task'),
      );
      final expected = {
        ...target.toJson(),
        'title': 'Edited persisted task',
        'notes': 'Edited notes',
        'completed': true,
      };
      expect((await repository.load()).single.toJson(), expected);
      await mount(tester, repository.key);
      final tile = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Edited persisted task'),
      );
      expect(tile.value, isTrue);
      expect(
        find.descendant(
          of: card('Edited persisted task'),
          matching: find.text('Completed'),
        ),
        findsOneWidget,
      );
      expect(
        (await LocalTaskRepository(key: repository.key).load()).single.toJson(),
        expected,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'independent persisted cancel delete undo preserves all records',
    (tester) async {
      final target = fixture(
        'delete-target',
        'Delete this task',
        completed: true,
      );
      final survivor = fixture('survivor', 'Keep this task');
      final repository = await fresh('delete', [target, survivor]);
      await mount(tester, repository.key);
      await tapVisible(tester, action(target.title, 'Delete'));
      await tapVisible(tester, find.text('Cancel'));
      expect((await repository.load()).map((t) => t.toJson()).toList(), [
        target.toJson(),
        survivor.toJson(),
      ]);
      expect(
        find.widgetWithText(CheckboxListTile, target.title),
        findsOneWidget,
      );
      await tapVisible(tester, action(target.title, 'Delete'));
      await tapVisible(
        tester,
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Delete'),
        ),
      );
      expect(find.widgetWithText(CheckboxListTile, target.title), findsNothing);
      expect((await repository.load()).single.toJson(), survivor.toJson());
      await tapVisible(tester, find.text('Undo delete'));
      expect(find.text('Undo delete'), findsNothing);
      final restored = await repository.load();
      expect(restored.length, 2);
      expect(
        restored.singleWhere((t) => t.id == target.id).toJson(),
        target.toJson(),
      );
      expect(
        restored.singleWhere((t) => t.id == survivor.id).toJson(),
        survivor.toJson(),
      );
      await mount(tester, repository.key);
      expect(
        find.widgetWithText(CheckboxListTile, target.title),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CheckboxListTile, survivor.title),
        findsOneWidget,
      );
      expect(
        tester
            .widget<CheckboxListTile>(
              find.widgetWithText(CheckboxListTile, target.title),
            )
            .value,
        isTrue,
      );
      expect((await LocalTaskRepository(key: repository.key).load()).length, 2);
      expect(tester.takeException(), isNull);
    },
  );
}

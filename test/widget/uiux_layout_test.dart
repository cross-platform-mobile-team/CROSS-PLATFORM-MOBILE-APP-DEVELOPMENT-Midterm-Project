import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_details.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/task_screen.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/task_card.dart';

import '../support/visual_fixture.dart';
import '../support/metadata_workflow.dart';

void main() {
  setUpAll(loadVisualFonts);
  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(768, 1024),
    const Size(1280, 900),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('layout $size text $scale preserves draft and controls', (
        tester,
      ) async {
        configureViewport(tester, size);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          TaskFlowApp(
            repository: InMemoryTaskRepository(
              seed: [
                TaskItem(
                  id: 'one',
                  title: 'First task',
                  createdAt: DateTime(2026),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (size == const Size(390, 844) && scale == 1) {
          expect(
            tester
                .getBottomRight(find.byKey(const ValueKey('task-card-one')))
                .dy,
            lessThanOrEqualTo(844),
          );
          expect(find.text('Edit').hitTestable(), findsOneWidget);
        }
        await enterVisible(tester, 'task-title', 'Keep this draft');
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Add task'));
        expect(find.text('Add task').hitTestable(), findsOneWidget);
        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('task-title')))
              .controller!
              .text,
          'Keep this draft',
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
    'AND filters are visible and independently removable; search reset is separate',
    (tester) async {
      configureViewport(tester, const Size(390, 844));
      await tester.pumpWidget(
        TaskFlowApp(
          home: TaskScreen(
            clock: () => DateTime(2026, 10, 10),
            repository: InMemoryTaskRepository(
              seed: [
                TaskItem(
                  id: 'one',
                  title: 'Match',
                  createdAt: DateTime(2026),
                  details: TaskDetails(
                    priority: TaskPriority.high,
                    dueDate: DateTime(2026, 10, 9),
                    tags: ['course'],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Filter and sort'));
      for (final entry in {
        'filter-status': 'Pending',
        'filter-priority': 'high',
        'filter-due': 'Overdue',
      }.entries) {
        await tapVisible(tester, find.byKey(Key(entry.key)));
        await tapVisible(tester, find.text(entry.value).last);
      }
      await enterVisible(tester, 'filter-tag', 'course');
      await tapVisible(tester, find.text('Apply'));
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Pending'))
            .selected,
        true,
      );
      expect(find.text('1 results'), findsOneWidget);
      final semantics = tester.ensureSemantics();
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      semantics.dispose();
      expect(find.widgetWithText(InputChip, 'Priority: high'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'Overdue'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'Tag: course'), findsOneWidget);
      tester
          .widget<InputChip>(find.widgetWithText(InputChip, 'Priority: high'))
          .onDeleted!();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(InputChip, 'Overdue'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'Tag: course'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Search tasks'),
        'missing',
      );
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Reset filters').first);
      expect(find.text('No matching tasks.'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.widgetWithText(TextField, 'Search tasks'))
            .controller!
            .text,
        'missing',
      );
      await tapVisible(tester, find.text('Clear search'));
      expect(find.byType(TaskCard), findsOneWidget);
    },
  );
  testWidgets(
    'empty CTA focuses form; hidden addition can be viewed without losing newer draft',
    (tester) async {
      configureViewport(tester, const Size(390, 844));
      await tester.pumpWidget(
        TaskFlowApp(repository: InMemoryTaskRepository()),
      );
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Add your first task'));
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
        true,
      );
      await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Completed'));
      await enterVisible(tester, 'task-title', 'Hidden task');
      await tapVisible(tester, find.text('Add task'));
      expect(
        find.text('Task added. Hidden by current filters.'),
        findsOneWidget,
      );
      await enterVisible(tester, 'task-title', 'Next draft');
      await tapVisible(tester, find.text('View task'));
      expect(find.text('Edit task'), findsOneWidget);
      await tapVisible(tester, find.text('Cancel'));
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('task-title')))
            .controller!
            .text,
        'Next draft',
      );
    },
  );
  testWidgets(
    'lazy list keeps form draft and expanded notes across scrolling',
    (tester) async {
      configureViewport(tester, const Size(390, 844));
      final repo = InMemoryTaskRepository(
        seed: List.generate(
          500,
          (i) => TaskItem(
            id: 'large-$i',
            title: 'Task $i',
            createdAt: DateTime(2026).add(Duration(minutes: i)),
            details: TaskDetails(notes: 'Long note. ' * 180),
          ),
        ),
      );
      await tester.pumpWidget(TaskFlowApp(repository: repo));
      await tester.pumpAndSettle();
      expect(find.byType(TaskCard).evaluate().length, lessThan(20));
      await enterVisible(tester, 'task-title', 'Retain draft');
      await tapVisible(tester, find.text('Task details (optional)'));
      await enterVisible(tester, 'task-due-date', 'invalid raw date');
      await tapVisible(tester, find.text('Task details (optional)'));
      final first = find.byKey(const ValueKey('task-card-large-499'));
      await tapVisible(
        tester,
        find.descendant(of: first, matching: find.text('Show more')),
      );
      final scroll = find
          .descendant(
            of: find.byKey(const ValueKey('workspace-canvas')),
            matching: find.byType(Scrollable),
          )
          .first;
      final position = tester.state<ScrollableState>(scroll).position;
      position.jumpTo(20000);
      await tester.pumpAndSettle();
      expect(find.byType(TaskCard).evaluate().length, lessThan(25));
      position.jumpTo(0);
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: first, matching: find.text('Show less')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('task-title')))
            .controller!
            .text,
        'Retain draft',
      );
      await tapVisible(tester, find.text('Task details (optional)'));
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('task-due-date')))
            .controller!
            .text,
        'invalid raw date',
      );
      expect(tester.takeException(), isNull);
    },
  );
  test('calendar labels around midnight, leap day and completed overdue', () {
    TaskItem task(DateTime date, {bool completed = false}) => TaskItem(
      id: 'x',
      title: 'x',
      createdAt: DateTime(2026),
      completed: completed,
      details: TaskDetails(dueDate: date),
    );
    expect(
      taskDueLabel(
        task(DateTime(2026, 10, 10)),
        DateTime(2026, 10, 10, 23, 59),
      ),
      startsWith('Today:'),
    );
    expect(
      taskDueLabel(task(DateTime(2026, 10, 10)), DateTime(2026, 10, 11)),
      startsWith('Overdue:'),
    );
    expect(
      taskDueLabel(
        task(DateTime(2026, 10, 10), completed: true),
        DateTime(2026, 10, 11),
      ),
      startsWith('Due:'),
    );
    expect(
      taskDueLabel(task(DateTime(2028, 2, 29)), DateTime(2028, 2, 28, 23, 59)),
      startsWith('Tomorrow:'),
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> enterVisible(WidgetTester tester, String key, String text) async {
  final finder = find.byKey(Key(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
  expect(
    tester
        .widget<EditableText>(
          find.descendant(of: finder, matching: find.byType(EditableText)),
        )
        .controller
        .text,
    text,
  );
}

/// The same user interactions run against both fake and native storage.
Future<void> metadataWorkflow(WidgetTester tester) async {
  await enterVisible(tester, 'task-title', 'Prepare presentation');
  await tapVisible(tester, find.text('Task details (optional)'));
  await enterVisible(tester, 'task-notes', 'Bring the diagrams');
  await tapVisible(tester, find.byKey(const Key('task-priority')));
  await tapVisible(tester, find.text('high').last);
  await enterVisible(tester, 'task-due-date', '2026-02-30');
  await tapVisible(tester, find.text('Add task'));
  expect(find.text('Enter a valid date as YYYY-MM-DD'), findsOneWidget);
  await enterVisible(tester, 'task-due-date', '2026-09-30');
  await enterVisible(tester, 'task-tags', 'Course, Flutter, COURSE');
  await tapVisible(tester, find.text('Add task'));
  expect(
    find.descendant(
      of: find.byType(CheckboxListTile),
      matching: find.text('Prepare presentation'),
    ),
    findsOneWidget,
  );

  await tapVisible(tester, find.text('Filter and sort'));
  await tapVisible(tester, find.byKey(const Key('filter-priority')));
  await tapVisible(tester, find.text('low').last);
  await tapVisible(tester, find.text('Apply'));
  await tester.scrollUntilVisible(
    find.text('No matching tasks.'),
    150,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 20,
  );
  await tester.pumpAndSettle();
  expect(find.text('No matching tasks.'), findsOneWidget);
  await tapVisible(tester, find.text('Clear filters'));
  expect(find.text('Prepare presentation'), findsOneWidget);

  await tapVisible(tester, find.text('Edit'));
  await enterVisible(tester, 'task-notes', 'Updated diagrams');
  await enterVisible(tester, 'task-due-date', '');
  await enterVisible(tester, 'task-tags', 'Flutter');
  await tapVisible(tester, find.text('Save changes'));
  expect(find.byType(AlertDialog), findsNothing);
}

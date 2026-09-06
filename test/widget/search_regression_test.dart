import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';

void main() {
  testWidgets('search regression: a middle word must match the saved task', (
    tester,
  ) async {
    await tester.pumpWidget(
      TaskFlowApp(
        repository: InMemoryTaskRepository(
          seed: [
            TaskItem(
              id: 'target',
              title: 'Review Flutter testing',
              createdAt: DateTime.utc(2026),
            ),
            TaskItem(
              id: 'other',
              title: 'Write report',
              createdAt: DateTime.utc(2026),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Search tasks'),
      ' FLUTTER ',
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(CheckboxListTile),
        matching: find.text('Review Flutter testing'),
      ),
      findsOneWidget,
    );
    expect(find.text('Write report'), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/task_screen.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/edit_task_dialog.dart';

import '../support/visual_fixture.dart';
import '../support/metadata_workflow.dart';

void main() {
  setUpAll(loadVisualFonts);
  testWidgets('audit phone 390x844 first complete task', (tester) async {
    configureViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      TaskFlowApp(
        home: TaskScreen(
          repository: InMemoryTaskRepository(seed: visualTasks()),
          clock: () => DateTime(2026, 10, 10),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getBottomRight(find.byKey(const ValueKey('task-card-task-a'))).dy,
      lessThan(844),
    );
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('baselines/audit-phone-390x844.png'),
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  testWidgets('audit retained draft and latest version comparison', (
    tester,
  ) async {
    configureViewport(tester, const Size(768, 1024));
    final task = visualTasks().first;
    await tester.pumpWidget(
      TaskFlowApp(
        home: Scaffold(
          body: EditTaskDialog(
            task: task,
            save: (_, _) async => false,
            reload: () async => TaskItem(
              id: task.id,
              title: 'Updated by another client',
              createdAt: task.createdAt,
              details: task.details,
            ),
            failureMessage: () =>
                'Another client changed this task. Your draft is preserved.',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await enterVisible(tester, 'edit-task-title', 'My retained task title');
    await tapVisible(tester, find.text('Save changes'));
    await tapVisible(tester, find.text('Load latest; keep my draft'));
    await tapVisible(tester, find.text('Latest saved version'));
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('baselines/audit-edit-recovery.png'),
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}

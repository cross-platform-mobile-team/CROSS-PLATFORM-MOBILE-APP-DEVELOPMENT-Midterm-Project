import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_details.dart';

import '../support/metadata_workflow.dart';

void main() {
  for (final width in [390.0, 1100.0]) {
    testWidgets('metadata validation, filter and clear at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = InMemoryTaskRepository();
      await tester.pumpWidget(TaskFlowApp(repository: repo));
      await tester.pumpAndSettle();
      await metadataWorkflow(tester);
      final saved = (await repo.load()).single;
      expect(saved.details.notes, 'Updated diagrams');
      expect(saved.details.dueDate, isNull);
      expect(saved.details.priority, TaskPriority.high);
      expect(saved.details.tags, ['flutter']);
      expect(tester.takeException(), isNull);
    });
  }
}

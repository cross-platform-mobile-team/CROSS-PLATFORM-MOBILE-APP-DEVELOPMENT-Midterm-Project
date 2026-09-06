import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';

import '../support/visual_fixture.dart';

void main() {
  setUpAll(loadVisualFonts);
  for (final scenario in [
    'phone-empty',
    'phone-populated',
    'phone-validation',
    'phone-error',
    'wide-empty',
    'wide-populated',
    'wide-validation',
    'wide-error',
  ]) {
    testWidgets('golden $scenario', (tester) async {
      configureViewport(
        tester,
        scenario.startsWith('phone')
            ? const Size(390, 960)
            : const Size(1280, 900),
      );
      final repository = InMemoryTaskRepository(
        seed: scenario.endsWith('populated') ? visualTasks() : [],
      )..failNext = scenario.endsWith('error');
      await tester.pumpWidget(TaskFlowApp(repository: repository));
      await tester.pumpAndSettle();
      if (scenario.endsWith('validation')) {
        await tester.tap(find.text('Add task'));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('baselines/$scenario.png'),
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  }
}

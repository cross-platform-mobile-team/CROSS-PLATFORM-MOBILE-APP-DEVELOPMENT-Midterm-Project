import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/core/theme/app_theme.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_filters.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/edit_task_dialog.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/task_filter_dialog.dart';

import '../support/visual_fixture.dart';

void main() {
  setUpAll(loadVisualFonts);
  for (final name in ['edit', 'filter']) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('$name dialog at text scale $scale', (tester) async {
        configureViewport(tester, const Size(390, 960));
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Scaffold(
              body: name == 'edit'
                  ? EditTaskDialog(
                      task: visualTasks().first,
                      save: (_, _) async => true,
                    )
                  : const TaskFilterDialog(
                      initial: TaskFilters(status: TaskStatusFilter.completed),
                    ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('baselines/$name-dialog-${scale.toInt()}x.png'),
        );
      }, variant: TargetPlatformVariant.only(TargetPlatform.android));
    }
  }
}

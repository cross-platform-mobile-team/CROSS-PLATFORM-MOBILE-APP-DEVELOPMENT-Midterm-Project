import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_details.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/task_screen.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(binding.testTextInput.register);
  tearDown(binding.testTextInput.unregister);
  for (final count in [100, 500]) {
    testWidgets(
      'profile isolated $count tasks: search, filter, scroll',
      (tester) async {
        expect(
          kProfileMode,
          true,
          reason: 'Use --profile; debug durations are not runtime evidence.',
        );
        final repo = InMemoryTaskRepository(
          seed: List.generate(
            count,
            (i) => TaskItem(
              id: 'perf-$i',
              title: 'Task $i study',
              createdAt: DateTime(2026, 1, 1).add(Duration(minutes: i)),
              completed: i.isEven,
              details: TaskDetails(
                notes: 'Long synthetic note. ' * 95,
                tags: ['study'],
                priority: TaskPriority.values[i % 3],
              ),
            ),
          ),
        );
        await tester.pumpWidget(
          TaskFlowApp(
            home: TaskScreen(
              repository: repo,
              clock: () => DateTime(2026, 10, 10),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final size = tester.view.physicalSize / tester.view.devicePixelRatio;
        for (final phase in ['search', 'filter', 'scroll']) {
          final key = '$count-$phase';
          await binding.watchPerformance(() async {
            if (phase == 'search') {
              for (final query in ['Task 1', 'Task 12', 'Task', '']) {
                await tester.enterText(
                  find.widgetWithText(TextField, 'Search tasks'),
                  query,
                );
                await tester.pumpAndSettle();
              }
            } else if (phase == 'filter') {
              for (final status in ['To do', 'Completed', 'All tasks']) {
                final rail = find.widgetWithText(
                  ListTile,
                  status == 'Completed' ? 'Completed tasks' : status,
                );
                if (rail.evaluate().isNotEmpty) {
                  await tester.tap(rail);
                } else {
                  await tester.tap(
                    find.widgetWithText(
                      ChoiceChip,
                      status == 'To do'
                          ? 'Pending'
                          : status == 'All tasks'
                          ? 'All'
                          : status,
                    ),
                  );
                }
                await tester.pumpAndSettle();
              }
            } else {
              final scroll = find
                  .descendant(
                    of: find.byKey(const ValueKey('workspace-canvas')),
                    matching: find.byType(Scrollable),
                  )
                  .first;
              for (var i = 0; i < 8; i++) {
                await tester.fling(scroll, const Offset(0, -600), 1200);
                await tester.pumpAndSettle();
              }
            }
          }, reportKey: key);
          // Only synthetic frame metrics, never account data.
          debugPrint(
            'UIUX_PROFILE ${jsonEncode({
              'tasks': count,
              'phase': phase,
              'viewport': {'width': size.width, 'height': size.height},
              'mode': 'profile',
              'metrics': binding.reportData![key],
            })}',
          );
        }
        expect(tester.takeException(), isNull);
      },
      timeout: const Timeout(Duration(minutes: 3)),
      skip: !kProfileMode,
    );
  }
}

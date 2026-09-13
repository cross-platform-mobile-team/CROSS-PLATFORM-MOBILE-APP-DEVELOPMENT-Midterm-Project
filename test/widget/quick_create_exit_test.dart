import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/core/network/api_client.dart';
import 'package:taskflow_qa_lab/features/account/presentation/account_gateway.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';

import '../support/metadata_workflow.dart';
import '../support/visual_fixture.dart';

class PendingRepository extends InMemoryTaskRepository {
  final saveGate = Completer<void>();
  @override
  Future<void> save(List<TaskItem> tasks) async {
    await saveGate.future;
    await super.save(tasks);
  }
}

void main() {
  Future<void> open(
    WidgetTester tester,
    String mode,
    InMemoryTaskRepository repository,
  ) async {
    configureViewport(tester, const Size(1100, 1600));
    final api = ApiClient(
      Uri.parse('http://localhost:8080'),
      client: MockClient((_) async => throw StateError('No network allowed')),
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(
      TaskFlowApp(
        home: AccountGateway(api: api, offlineRepository: repository),
      ),
    );
    await tapVisible(
      tester,
      find.text(mode == 'offline' ? 'Use offline demo' : 'Try sample sandbox'),
    );
  }

  for (final mode in ['offline', 'sample']) {
    final tooltip = mode == 'offline'
        ? 'Return to sign in'
        : 'Exit sample sandbox';
    testWidgets('$mode exit keeps or discards draft without storage writes', (
      tester,
    ) async {
      final repository = InMemoryTaskRepository();
      await open(tester, mode, repository);
      await enterVisible(tester, 'task-title', 'Unsaved');
      await tapVisible(tester, find.byTooltip(tooltip));
      expect(find.text('Discard new task draft?'), findsOneWidget);
      await tapVisible(tester, find.text('Continue editing'));
      expect(find.text('Unsaved'), findsOneWidget);
      await tapVisible(tester, find.byTooltip(tooltip));
      await tapVisible(tester, find.text('Discard and leave'));
      expect(find.text('Use offline demo'), findsOneWidget);
      expect(await repository.load(), isEmpty);
      await tapVisible(
        tester,
        find.text(
          mode == 'offline' ? 'Use offline demo' : 'Try sample sandbox',
        ),
      );
      expect(find.text('Unsaved'), findsNothing);
    });

    testWidgets('$mode blank draft exits without confirmation', (tester) async {
      await open(tester, mode, InMemoryTaskRepository());
      await enterVisible(tester, 'task-title', '   ');
      await tapVisible(tester, find.byTooltip(tooltip));
      expect(find.text('Discard new task draft?'), findsNothing);
      expect(find.text('Use offline demo'), findsOneWidget);
    });

    testWidgets('$mode metadata-only invalid date is protected', (
      tester,
    ) async {
      await open(tester, mode, InMemoryTaskRepository());
      await tapVisible(tester, find.text('Task details (optional)'));
      await enterVisible(tester, 'task-due-date', 'bad date');
      await tapVisible(tester, find.byTooltip(tooltip));
      expect(find.text('Discard new task draft?'), findsOneWidget);
      await tapVisible(tester, find.text('Continue editing'));
      expect(find.text('bad date'), findsOneWidget);
    });
  }

  testWidgets('metadata draft remains dirty after unrelated screen rebuild', (
    tester,
  ) async {
    await open(tester, 'offline', InMemoryTaskRepository());
    await tapVisible(tester, find.text('Task details (optional)'));
    await enterVisible(tester, 'task-notes', 'Only metadata');
    final search = find.widgetWithText(TextField, 'Search tasks');
    await tester.ensureVisible(search);
    await tester.enterText(search, 'query');
    await tester.pumpAndSettle();
    await enterVisible(tester, 'task-notes', 'Only metadata changed');
    await enterVisible(tester, 'task-notes', 'Only metadata');
    await tapVisible(tester, find.byTooltip('Return to sign in'));
    expect(find.text('Discard new task draft?'), findsOneWidget);
  });

  testWidgets('pending save blocks exit then saved draft exits cleanly', (
    tester,
  ) async {
    final repository = PendingRepository();
    await open(tester, 'offline', repository);
    await enterVisible(tester, 'task-title', 'Saved after gate');
    await tester.ensureVisible(find.text('Add task'));
    await tester.tap(find.text('Add task'));
    await tester.pump();
    await tester.ensureVisible(find.byTooltip('Return to sign in'));
    await tester.pump();
    await tester.tap(find.byTooltip('Return to sign in'));
    await tester.pump();
    expect(
      find.text('Wait for the current operation to finish.'),
      findsOneWidget,
    );
    expect(find.text('Use offline demo'), findsNothing);
    repository.saveGate.complete();
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byTooltip('Return to sign in'));
    expect(find.text('Discard new task draft?'), findsNothing);
    expect((await repository.load()).single.title, 'Saved after gate');
  });
}

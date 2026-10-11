import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/core/network/api_client.dart';
import 'package:taskflow_qa_lab/features/tasks/data/remote_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_details.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/task_screen.dart';

import '../unit/api_client_test.dart' show jsonResponse, loginData, failure;
import '../support/metadata_workflow.dart';
import '../support/visual_fixture.dart';

void main() {
  for (final scenario in [
    'conflict',
    'timeout after commit',
    'deleted',
    'recreate timeout',
    'reload fails',
  ]) {
    testWidgets('online edit recovery: $scenario', (tester) async {
      configureViewport(tester, const Size(1280, 1000));
      final original = TaskItem(
        id: 'one',
        title: 'Original',
        createdAt: DateTime(2026),
        details: TaskDetails(notes: 'old notes'),
      );
      var tasks = [original.toJson()];
      var revision = 1, writes = 0, reads = 0;
      final gate = Completer<void>();
      addTearDown(() {
        if (!gate.isCompleted) gate.complete();
      });
      final api = ApiClient(
        Uri.parse('http://localhost:8080'),
        client: MockClient((request) async {
          if (request.url.path.endsWith('/login')) {
            return jsonResponse(loginData());
          }
          if (request.method == 'GET') {
            reads++;
            if (scenario == 'reload fails' && reads == 2) {
              return failure('network', 503);
            }
            return jsonResponse({'revision': revision, 'tasks': tasks});
          }
          writes++;
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['revision'], revision);
          if (writes == 1) {
            await gate.future;
            revision++;
            if (scenario == 'timeout after commit') {
              tasks = (body['tasks'] as List).cast<Map<String, dynamic>>();
              throw TimeoutException('response lost after commit');
            }
            tasks = (scenario == 'deleted' || scenario == 'recreate timeout')
                ? []
                : [
                    {
                      ...original.toJson(),
                      'title': 'Other client',
                      'completed': true,
                    },
                  ];
            return failure('conflict', 409);
          }
          tasks = (body['tasks'] as List).cast<Map<String, dynamic>>();
          revision++;
          if (scenario == 'recreate timeout' && writes == 2) {
            throw TimeoutException('recreated task response lost');
          }
          return jsonResponse({'revision': revision});
        }),
      );
      addTearDown(api.dispose);
      await api.signIn(
        email: 'alice@example.test',
        password: 'test-only-password',
      );
      await tester.pumpWidget(
        TaskFlowApp(
          home: TaskScreen(repository: RemoteTaskRepository(api), online: true),
        ),
      );
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Edit'));
      await enterVisible(tester, 'edit-task-title', 'My draft');
      await enterVisible(tester, 'task-notes', 'Preserve these notes');
      await tapVisible(tester, find.byKey(const Key('task-priority')));
      await tapVisible(tester, find.text('high').last);
      await enterVisible(tester, 'task-due-date', '2026-10-11');
      await enterVisible(tester, 'task-tags', 'course, flutter');
      await tester.ensureVisible(find.text('Save changes'));
      await tester.tap(find.text('Save changes'));
      await tester.pump();
      expect(find.text('Saving…'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Saving…'))
            .onPressed,
        isNull,
      );
      expect(writes, 1);
      gate.complete();
      await tester.pumpAndSettle();
      expect(find.text('Load latest; keep my draft'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Save changes'),
            )
            .onPressed,
        isNull,
      );
      await tapVisible(tester, find.text('Load latest; keep my draft'));
      if (scenario == 'reload fails') {
        expect(
          find.text(
            'Could not reload. Your draft is still here. Try loading again.',
          ),
          findsOneWidget,
        );
        expect(writes, 1);
        await tapVisible(tester, find.text('Load latest; keep my draft'));
      }
      for (final entry in {
        'edit-task-title': 'My draft',
        'task-notes': 'Preserve these notes',
        'task-due-date': '2026-10-11',
        'task-tags': 'course, flutter',
      }.entries) {
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: find.byKey(Key(entry.key)),
                  matching: find.byType(EditableText),
                ),
              )
              .controller
              .text,
          entry.value,
        );
      }
      expect(writes, 1, reason: 'Reload must never replay a write');
      if (scenario == 'timeout after commit') {
        await tapVisible(tester, find.text('Close; already saved'));
        expect(writes, 1);
      } else if (scenario == 'deleted' || scenario == 'recreate timeout') {
        await tapVisible(tester, find.text('Save as new task'));
        if (scenario == 'recreate timeout') {
          await tapVisible(tester, find.text('Load latest; keep my draft'));
          await tapVisible(tester, find.text('Close; already saved'));
        }
        expect(tasks.single['id'], isNot('one'));
        expect(writes, 2);
      } else {
        await tapVisible(tester, find.text('Latest saved version'));
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.textContaining('Other client'),
          ),
          findsOneWidget,
        );
        await tapVisible(tester, find.text('Apply my draft'));
        expect(
          tasks.single['completed'],
          true,
          reason: 'Preserve latest server status',
        );
        expect(writes, 2);
      }
      expect(tasks.single['title'], 'My draft');
      expect(tasks.single['notes'], 'Preserve these notes');
      expect(tasks.single['priority'], 'high');
      expect(tasks.single['dueDate'], '2026-10-11');
      expect(tasks.single['tags'], ['course', 'flutter']);
      expect(tester.takeException(), isNull);
    });
  }
}

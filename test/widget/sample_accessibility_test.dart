import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/core/network/api_client.dart';
import 'package:taskflow_qa_lab/features/account/presentation/account_gateway.dart';
import 'package:taskflow_qa_lab/features/account/presentation/auth_screen.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';

import '../support/metadata_workflow.dart';
import '../support/visual_fixture.dart';

void main() {
  setUpAll(loadVisualFonts);
  testWidgets(
    'sample sandbox resets and never touches offline data or network',
    (tester) async {
      configureViewport(tester, const Size(1100, 1600));
      var requests = 0;
      final api = ApiClient(
        Uri.parse('http://localhost:8080'),
        client: MockClient((_) async {
          requests++;
          throw StateError('Sandbox must not call API');
        }),
      );
      addTearDown(api.dispose);
      final saved = TaskItem(
        id: 'private',
        title: 'Private offline task',
        createdAt: DateTime.utc(2026),
      );
      final offline = InMemoryTaskRepository(seed: [saved]);
      await tester.pumpWidget(
        TaskFlowApp(
          home: AccountGateway(api: api, offlineRepository: offline),
        ),
      );
      await tapVisible(tester, find.text('Try sample sandbox'));
      expect(find.text('Review Flutter testing'), findsOneWidget);
      expect(find.bySemanticsLabel('Tag: flutter'), findsOneWidget);
      expect(find.text('Private offline task'), findsNothing);
      await enterVisible(tester, 'task-title', 'Temporary example');
      await tapVisible(tester, find.text('Add task'));
      expect(find.text('Temporary example'), findsOneWidget);
      await tapVisible(tester, find.byTooltip('Exit sample sandbox'));
      await tapVisible(tester, find.text('Try sample sandbox'));
      expect(find.text('Temporary example'), findsNothing);
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
      await tapVisible(tester, find.byTooltip('Exit sample sandbox'));
      await tapVisible(tester, find.text('Use offline demo'));
      expect(find.text('Private offline task'), findsOneWidget);
      expect((await offline.load()).single.toJson(), saved.toJson());
      expect(requests, 0);
    },
  );

  Widget auth() => TaskFlowApp(
    home: AuthScreen(
      authenticate: (_, _, _) async {},
      recover: (_, _, _) async {},
      offline: () {},
      samples: () {},
    ),
  );
  for (final mode in ['login', 'register', 'recovery']) {
    testWidgets('account $mode invalid form accessibility guidelines', (
      tester,
    ) async {
      configureViewport(tester, const Size(390, 1400));
      await tester.pumpWidget(auth());
      await tester.pumpAndSettle();
      if (mode != 'login') {
        await tapVisible(
          tester,
          find.text(mode == 'register' ? 'Create account' : 'Forgot password?'),
        );
      }
      await tapVisible(tester, find.byKey(const Key('account-submit')));
      expect(
        find.bySemanticsLabel(RegExp('Enter a valid email')),
        findsWidgets,
      );
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  }
  testWidgets('account keyboard focus moves email to password and submits', (
    tester,
  ) async {
    var submitted = false;
    await tester.pumpWidget(
      TaskFlowApp(
        home: AuthScreen(
          authenticate: (_, _, _) async {
            submitted = true;
          },
          recover: (_, _, _) async {},
          offline: () {},
        ),
      ),
    );
    await enterVisible(tester, 'account-email', 'keyboard@example.test');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final password = find.byKey(const Key('account-password'));
    expect(
      tester
          .widget<EditableText>(
            find.descendant(of: password, matching: find.byType(EditableText)),
          )
          .focusNode
          .hasFocus,
      isTrue,
    );
    await tester.enterText(password, 'test-only-password');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(submitted, isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
  testWidgets('account register remains usable at 200 percent text', (
    tester,
  ) async {
    configureViewport(tester, const Size(390, 960));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(auth());
    await tapVisible(tester, find.text('Create account'));
    await tapVisible(tester, find.byKey(const Key('account-submit')));
    expect(find.text('Enter a valid email.'), findsOneWidget);
    await tapVisible(tester, find.text('Back to sign in'));
    expect(find.text('Welcome back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

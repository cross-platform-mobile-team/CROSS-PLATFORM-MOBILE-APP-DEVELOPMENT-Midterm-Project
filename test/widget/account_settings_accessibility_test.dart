import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/core/network/api_client.dart';
import 'package:taskflow_qa_lab/features/account/presentation/account_screen.dart';

import '../support/visual_fixture.dart';
import '../unit/api_client_test.dart' show jsonResponse, loginData;

void main() {
  setUpAll(loadVisualFonts);

  Future<ApiClient> signedInApi() async {
    final api = ApiClient(
      Uri.parse('http://localhost:8080'),
      client: MockClient((request) async {
        if (request.url.path.endsWith('/login')) {
          return jsonResponse(loginData());
        }
        if (request.url.path.endsWith('/sessions')) {
          return jsonResponse({
            'sessions': [
              {
                'id': 'current-session',
                'current': true,
                'createdAt': '2026-09-09T01:00:00.000Z',
                'expiresAt': '2026-09-10T01:00:00.000Z',
              },
            ],
          });
        }
        return http.Response('Not found', 404);
      }),
    );
    addTearDown(api.dispose);
    await api.signIn(
      email: 'alice@example.test',
      password: 'test-only-password',
    );
    return api;
  }

  bool editableHasFocus(WidgetTester tester, Finder field) => tester
      .widget<EditableText>(
        find.descendant(of: field, matching: find.byType(EditableText)),
      )
      .focusNode
      .hasFocus;

  testWidgets(
    'account settings exposes headings, validation and logical keyboard focus',
    (tester) async {
      configureViewport(tester, const Size(390, 1600));
      final api = await signedInApi();
      await tester.pumpWidget(TaskFlowApp(home: AccountScreen(api: api)));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('alice@example.test'), findsOneWidget);
      expect(find.bySemanticsLabel('Profile'), findsOneWidget);
      expect(find.bySemanticsLabel('Password and security'), findsOneWidget);
      expect(find.bySemanticsLabel('Active sessions'), findsOneWidget);

      final profileName = find.byKey(const Key('profile-name'));
      await tester.enterText(profileName, '');
      await tester.tap(find.byKey(const Key('save-profile')));
      await tester.pumpAndSettle();
      expect(find.text('Enter 1-80 characters.'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Enter 1-80 characters')),
        findsWidgets,
      );
      expect(editableHasFocus(tester, profileName), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('save-profile')))
            .focusNode!
            .hasFocus,
        isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final currentPassword = find.byKey(const Key('current-password'));
      expect(editableHasFocus(tester, currentPassword), isTrue);

      await tester.ensureVisible(find.byKey(const Key('change-password')));
      await tester.tap(find.byKey(const Key('change-password')));
      await tester.pump();
      expect(find.text('Enter your current password.'), findsOneWidget);
      expect(find.text('Enter 12-128 characters.'), findsOneWidget);
      expect(editableHasFocus(tester, currentPassword), isTrue);

      await tester.enterText(currentPassword, 'test-only-password');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      final newPassword = find.byKey(const Key('new-password'));
      expect(editableHasFocus(tester, newPassword), isTrue);
      await tester.enterText(newPassword, 'short');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('Enter 12-128 characters.'), findsOneWidget);
      expect(editableHasFocus(tester, newPassword), isTrue);

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets('account deletion error stays usable at 200 percent text', (
    tester,
  ) async {
    configureViewport(tester, const Size(390, 900));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final api = await signedInApi();
    await tester.pumpWidget(TaskFlowApp(home: AccountScreen(api: api)));
    await tester.pumpAndSettle();

    final deleteAccount = find.byKey(const Key('delete-account'));
    await tester.scrollUntilVisible(
      deleteAccount,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(deleteAccount);
    await tester.pumpAndSettle();
    const message = 'Enter your current password before deleting your account.';
    expect(find.text(message), findsOneWidget);
    expect(find.bySemanticsLabel(message), findsOneWidget);
    expect(
      editableHasFocus(tester, find.byKey(const Key('current-password'))),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}

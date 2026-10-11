import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/core/network/api_client.dart';
import 'package:taskflow_qa_lab/features/account/presentation/account_screen.dart';

import '../unit/api_client_test.dart' show jsonResponse, loginData;
import '../support/visual_fixture.dart';
import '../support/metadata_workflow.dart';

void main() {
  for (final state in ['unchanged', 'dirty', 'reverted', 'password']) {
    testWidgets('account Back protects $state draft', (tester) async {
      configureViewport(tester, const Size(900, 1600));
      final api = ApiClient(
        Uri.parse('http://localhost:8080'),
        client: MockClient(
          (r) async => jsonResponse(
            r.url.path.endsWith('/login') ? loginData() : {'sessions': []},
          ),
        ),
      );
      addTearDown(api.dispose);
      await api.signIn(
        email: 'alice@example.test',
        password: 'test-only-password',
      );
      await tester.pumpWidget(
        TaskFlowApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => AccountScreen(api: api),
                  ),
                ),
                child: const Text('Settings'),
              ),
            ),
          ),
        ),
      );
      await tapVisible(tester, find.text('Settings'));
      if (state == 'dirty' || state == 'reverted') {
        await enterVisible(tester, 'profile-name', 'Changed');
      }
      if (state == 'reverted') {
        await enterVisible(tester, 'profile-name', 'Alice');
      }
      if (state == 'password') {
        await enterVisible(tester, 'current-password', 'secret draft');
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: find.byKey(const Key('current-password')),
                  matching: find.byType(EditableText),
                ),
              )
              .obscureText,
          true,
        );
        await tapVisible(tester, find.byTooltip('Show current password'));
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: find.byKey(const Key('current-password')),
                  matching: find.byType(EditableText),
                ),
              )
              .obscureText,
          false,
        );
      }
      await tester.pageBack();
      await tester.pumpAndSettle();
      if (state == 'dirty' || state == 'password') {
        expect(find.text('Discard account changes?'), findsOneWidget);
        await tapVisible(tester, find.text('Continue editing'));
        expect(find.text('Account settings'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tapVisible(tester, find.text('Discard and leave'));
      }
      expect(find.text('Settings'), findsOneWidget);
      await tapVisible(tester, find.text('Settings'));
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('profile-name')))
            .controller!
            .text,
        'Alice',
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('current-password')))
            .controller!
            .text,
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

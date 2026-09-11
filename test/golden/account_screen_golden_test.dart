import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/core/network/api_client.dart';
import 'package:taskflow_qa_lab/features/account/presentation/account_screen.dart';

import '../support/visual_fixture.dart';
import '../unit/api_client_test.dart' show jsonResponse, loginData;

void main() {
  setUpAll(loadVisualFonts);
  testWidgets('golden account settings with synthetic session', (tester) async {
    configureViewport(tester, const Size(900, 1600));
    final api = ApiClient(
      Uri.parse('http://localhost:8080'),
      client: MockClient((request) async {
        if (request.url.path.endsWith('/login')) {
          return jsonResponse(loginData());
        }
        return jsonResponse({
          'sessions': [
            {
              'id': 'visual-session',
              'current': true,
              'createdAt': '2026-09-11T09:00:00Z',
              'expiresAt': '2026-09-12T09:00:00Z',
            },
          ],
        });
      }),
    );
    addTearDown(api.dispose);
    await api.signIn(
      email: 'alice@example.test',
      password: 'test-only-password',
    );
    await tester.pumpWidget(TaskFlowApp(home: AccountScreen(api: api)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('baselines/account-settings.png'),
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}

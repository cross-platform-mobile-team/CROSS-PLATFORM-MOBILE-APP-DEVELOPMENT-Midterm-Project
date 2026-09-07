import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/core/network/api_client.dart';
import 'package:taskflow_qa_lab/features/account/presentation/account_gateway.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';

import '../unit/api_client_test.dart' show jsonResponse, loginData, failure;

void main() {
  testWidgets(
    'registration validates, shows recovery code and opens private tasks',
    (tester) async {
      var registrations = 0;
      final api = ApiClient(
        Uri.parse('http://localhost:8080'),
        client: MockClient((req) async {
          if (req.url.path.endsWith('/register')) {
            registrations++;
            return jsonResponse({
              ...loginData(),
              'recoveryCode': 'test-recovery-code',
            }, 201);
          }
          return jsonResponse({'revision': 0, 'tasks': []});
        }),
      );
      addTearDown(api.dispose);
      await tester.pumpWidget(
        TaskFlowApp(
          home: AccountGateway(
            api: api,
            offlineRepository: InMemoryTaskRepository(),
          ),
        ),
      );
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('account-submit')));
      await tester.pumpAndSettle();
      expect(registrations, 0);
      expect(find.text('Enter a valid email.'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('account-name')), 'Alice');
      await tester.enterText(
        find.byKey(const Key('account-email')),
        'alice@example.test',
      );
      await tester.enterText(
        find.byKey(const Key('account-password')),
        'a-test-only-password',
      );
      await tester.ensureVisible(find.byKey(const Key('account-submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('account-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Save your recovery code'), findsOneWidget);
      expect(find.text('test-recovery-code'), findsOneWidget);
      await tester.tap(find.text('I saved my recovery code'));
      await tester.pumpAndSettle();
      expect(
        find.text('No tasks yet. Add your first task above.'),
        findsOneWidget,
      );
      expect(find.byTooltip('Account settings'), findsOneWidget);
    },
  );
  testWidgets(
    'failed login is readable; offline mode does not call the backend',
    (tester) async {
      var requests = 0;
      final api = ApiClient(
        Uri.parse('http://localhost:8080'),
        client: MockClient((req) async {
          requests++;
          return failure('invalid_credentials', 401);
        }),
      );
      addTearDown(api.dispose);
      await tester.pumpWidget(
        TaskFlowApp(
          home: AccountGateway(
            api: api,
            offlineRepository: InMemoryTaskRepository(),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const Key('account-email')),
        'alice@example.test',
      );
      await tester.enterText(
        find.byKey(const Key('account-password')),
        'wrong',
      );
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('invalid_credentials'), findsOneWidget);
      await tester.ensureVisible(find.text('Use offline demo'));
      await tester.tap(find.text('Use offline demo'));
      await tester.pumpAndSettle();
      expect(
        find.text('No tasks yet. Add your first task above.'),
        findsOneWidget,
      );
      expect(requests, 1);
      await tester.tap(find.byTooltip('Return to sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
    },
  );
}

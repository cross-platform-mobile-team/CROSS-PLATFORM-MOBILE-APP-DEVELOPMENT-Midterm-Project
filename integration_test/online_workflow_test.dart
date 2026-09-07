import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/core/network/api_client.dart';
import 'package:taskflow_qa_lab/features/account/presentation/account_gateway.dart';
import 'package:taskflow_qa_lab/features/tasks/data/remote_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/data/in_memory_task_repository.dart';
import 'package:taskflow_qa_lab/core/errors/app_failure.dart';

Future<void> visible(WidgetTester tester, Finder finder) async {
  // Native network/SQLite requests are observed, not assumed to finish in a sleep.
  for (var frame = 0; frame < 150; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Expected UI did not appear within 15 seconds: $finder');
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await visible(tester, finder);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(binding.testTextInput.register);
  tearDown(binding.testTextInput.unregister);
  testWidgets(
    'online account lifecycle, isolation and optimistic conflict on Windows',
    (tester) async {
      final api = ApiClient(
        Uri.parse(
          const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://127.0.0.1:8081',
          ),
        ),
      );
      final second = ApiClient(api.baseUri), stranger = ApiClient(api.baseUri);
      addTearDown(() {
        api.dispose();
        second.dispose();
        stranger.dispose();
      });
      const address = 'native-e2e@example.test';
      const password = 'Native-e2e-test-password!';
      await tester.pumpWidget(
        TaskFlowApp(
          home: AccountGateway(
            api: api,
            offlineRepository: InMemoryTaskRepository(),
          ),
        ),
      );
      await tap(tester, find.text('Create account'));
      await visible(tester, find.byKey(const Key('account-name')));
      await tester.enterText(
        find.byKey(const Key('account-name')),
        'Native tester',
      );
      await tester.enterText(find.byKey(const Key('account-email')), address);
      await tester.enterText(
        find.byKey(const Key('account-password')),
        password,
      );
      await tap(tester, find.byKey(const Key('account-submit')));
      await visible(tester, find.text('Save your recovery code'));
      await tap(tester, find.text('I saved my recovery code'));
      await visible(
        tester,
        find.text('No tasks yet. Add your first task above.'),
      );
      await tester.enterText(
        find.byKey(const Key('task-title')),
        'Persisted by the real API',
      );
      await tap(tester, find.text('Add task'));
      final savedCard = find.descendant(
        of: find.byType(CheckboxListTile),
        matching: find.text('Persisted by the real API'),
      );
      await visible(tester, savedCard);
      await second.signIn(email: address, password: password);
      final otherRepo = RemoteTaskRepository(second);
      final persisted = await otherRepo.load();
      expect(persisted.single.title, 'Persisted by the real API');
      await stranger.signIn(
        email: 'other-e2e@example.test',
        password: password,
        name: 'Other',
      );
      expect(await RemoteTaskRepository(stranger).load(), isEmpty);
      await tap(tester, find.byType(CheckboxListTile));
      await visible(tester, find.text('Completed'));
      // Other session's revision is now stale; it must not erase the completed task.
      await expectLater(
        otherRepo.save([]),
        throwsA(isA<AppFailure>().having((e) => e.code, 'code', 'conflict')),
      );
      expect((await otherRepo.load()).single.completed, isTrue);
      await tap(tester, find.byTooltip('Account settings'));
      await visible(tester, find.text('Sign out'));
      await tap(tester, find.text('Sign out'));
      await visible(tester, find.text('Welcome back'));
      await tester.enterText(find.byKey(const Key('account-email')), address);
      await tester.enterText(
        find.byKey(const Key('account-password')),
        password,
      );
      await tap(tester, find.text('Sign in'));
      await visible(tester, savedCard);
      expect(find.text('Completed'), findsOneWidget);
      await api.deleteAccount(password);
      await stranger.deleteAccount(password);
      await visible(tester, find.text('Welcome back'));
    },
  );
}

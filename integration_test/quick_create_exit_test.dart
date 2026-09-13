import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow_qa_lab/app/app.dart';
import 'package:taskflow_qa_lab/core/network/api_client.dart';
import 'package:taskflow_qa_lab/features/account/presentation/account_gateway.dart';
import 'package:taskflow_qa_lab/features/tasks/data/local_task_repository.dart';

import '../test/support/metadata_workflow.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(binding.testTextInput.register);
  tearDown(binding.testTextInput.unregister);
  testWidgets('offline draft exit decisions preserve persisted tasks', (
    tester,
  ) async {
    const key = 'taskflow.integration.quick-create-exit.v1';
    final preferences = SharedPreferencesAsync();
    await preferences.remove(key);
    addTearDown(() => preferences.remove(key));
    final repository = LocalTaskRepository(key: key);
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
    await tapVisible(tester, find.text('Use offline demo'));
    await enterVisible(tester, 'task-title', 'Kept draft');
    await tapVisible(tester, find.byTooltip('Return to sign in'));
    await tapVisible(tester, find.text('Continue editing'));
    expect(find.text('Kept draft'), findsOneWidget);
    expect(await repository.load(), isEmpty);
    await tapVisible(tester, find.text('Add task'));
    final saved = (await repository.load()).single.toJson();
    await tapVisible(tester, find.byTooltip('Return to sign in'));
    expect(find.text('Discard new task draft?'), findsNothing);
    await tapVisible(tester, find.text('Use offline demo'));
    expect(find.text('Kept draft'), findsOneWidget);
    await enterVisible(tester, 'task-title', 'Discard this');
    await tapVisible(tester, find.byTooltip('Return to sign in'));
    await tapVisible(tester, find.text('Discard and leave'));
    expect((await LocalTaskRepository(key: key).load()).single.toJson(), saved);
    await tapVisible(tester, find.text('Use offline demo'));
    expect(find.text('Discard this'), findsNothing);
    expect(find.text('Kept draft'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

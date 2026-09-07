import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/network/api_client.dart';
import 'features/account/presentation/account_gateway.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskFlowClient());
}

class TaskFlowClient extends StatefulWidget {
  const TaskFlowClient({super.key});
  @override
  State<TaskFlowClient> createState() => _TaskFlowClientState();
}

class _TaskFlowClientState extends State<TaskFlowClient> {
  final api = ApiClient(
    Uri.parse(
      const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://127.0.0.1:8080',
      ),
    ),
  );
  @override
  void dispose() {
    api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      TaskFlowApp(home: AccountGateway(api: api));
}

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/tasks/data/local_task_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TaskFlowApp(repository: LocalTaskRepository()));
}

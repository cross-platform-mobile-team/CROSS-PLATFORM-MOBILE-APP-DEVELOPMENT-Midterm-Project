import 'package:flutter/material.dart';

import '../features/tasks/domain/task_repository.dart';
import '../features/tasks/presentation/task_screen.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key, required this.repository});
  final TaskRepository repository;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TaskFlow QA Lab',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF385A64)),
      useMaterial3: true,
    ),
    home: TaskScreen(repository: repository),
  );
}

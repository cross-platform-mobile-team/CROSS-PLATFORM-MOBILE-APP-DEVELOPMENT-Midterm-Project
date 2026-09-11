import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

import '../features/tasks/domain/task_repository.dart';
import '../features/tasks/presentation/task_screen.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key, this.repository, this.home})
    : assert(repository != null || home != null);
  final TaskRepository? repository;
  final Widget? home;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TaskFlow QA Lab',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: home ?? TaskScreen(repository: repository!),
  );
}

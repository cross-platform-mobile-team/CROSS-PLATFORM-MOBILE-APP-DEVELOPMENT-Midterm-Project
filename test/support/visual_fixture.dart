import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_details.dart';

Future<void> loadVisualFonts() async {
  final loader = FontLoader('Roboto');
  for (final weight in ['regular', 'medium', 'bold']) {
    loader.addFont(
      File('test/fonts/roboto-$weight.ttf')
          .readAsBytes()
          .then((bytes) => ByteData.sublistView(bytes)),
    );
  }
  await loader.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await icons.load();
}

void configureViewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearLocaleTestValue();
  });
}

List<TaskItem> visualTasks() => [
  TaskItem(
    id: 'task-a',
    title: 'Review the testing plan',
    createdAt: DateTime.utc(2026, 9, 6),
    details: TaskDetails(
      notes: 'Cover the important user workflows.',
      priority: TaskPriority.high,
      dueDate: DateTime(2026, 9, 30),
      tags: ['course', 'testing'],
    ),
  ),
  TaskItem(
    id: 'task-b',
    title: 'Prepare sample data',
    createdAt: DateTime.utc(2026, 9, 5),
    completed: true,
  ),
];

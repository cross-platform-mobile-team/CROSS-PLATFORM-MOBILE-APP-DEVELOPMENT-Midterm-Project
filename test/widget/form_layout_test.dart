import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_qa_lab/core/theme/app_theme.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_filters.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/edit_task_dialog.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/task_filter_dialog.dart';
import 'package:taskflow_qa_lab/features/tasks/presentation/task_details_fields.dart';

void main() {
  Future<void> mount(
    WidgetTester tester,
    Widget dialog, {
    double scale = 1,
  }) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(body: dialog),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'edit fields have breathing room and stable scroll while typing',
    (tester) async {
      await mount(
        tester,
        EditTaskDialog(
          task: TaskItem(id: 'a', title: 'Original', createdAt: DateTime(2026)),
          save: (_, _) async => true,
        ),
      );
      final title = find.byKey(const Key('edit-task-title'));
      final notes = find.byKey(const Key('task-notes'));
      expect(
        tester.getTopLeft(notes).dy - tester.getBottomLeft(title).dy,
        greaterThanOrEqualTo(16),
      );
      final priority = find.byKey(const Key('task-priority'));
      final date = find.byKey(const Key('task-due-date'));
      expect(
        tester.getTopLeft(date).dy - tester.getBottomLeft(priority).dy,
        greaterThanOrEqualTo(16),
      );
      await tester.enterText(title, 'First');
      await tester.pumpAndSettle();
      final before = tester.getTopLeft(notes);
      final metadataWidget = tester.widget(find.byType(TaskDetailsFields));
      await tester.enterText(title, 'Second');
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(notes), before);
      expect(
        tester.widget(find.byType(TaskDetailsFields)),
        same(metadataWidget),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('filter fields have separate boxes', (tester) async {
    await mount(tester, const TaskFilterDialog(initial: TaskFilters()));
    final status = find.byKey(const Key('filter-status'));
    final priority = find.byKey(const Key('filter-priority'));
    expect(
      tester.getTopLeft(priority).dy - tester.getBottomLeft(status).dy,
      greaterThanOrEqualTo(16),
    );
  });

  testWidgets('large text filter selections fit without overflow', (
    tester,
  ) async {
    await mount(
      tester,
      const TaskFilterDialog(
        initial: TaskFilters(status: TaskStatusFilter.completed),
      ),
      scale: 2,
    );
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const Key('filter-status')));
    await tester.tap(find.byKey(const Key('filter-status')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

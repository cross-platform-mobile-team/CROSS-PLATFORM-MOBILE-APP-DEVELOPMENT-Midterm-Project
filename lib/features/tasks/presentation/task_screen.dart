import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ui_components.dart';

import '../application/task_controller.dart';
import '../domain/task_item.dart';
import '../domain/task_repository.dart';
import 'edit_task_dialog.dart';
import '../domain/task_details.dart';
import '../domain/task_filters.dart';
import 'task_details_fields.dart';
import 'task_filter_dialog.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({
    super.key,
    required this.repository,
    this.actions,
    this.online = false,
    this.notice,
  });
  final TaskRepository repository;
  final List<Widget>? actions;
  final bool online;
  final String? notice;
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final TaskController controller;
  final title = TextEditingController();
  final form = GlobalKey<FormState>();
  String query = '';
  final search = TextEditingController();
  TaskDetails draftDetails = TaskDetails();
  int draftRevision = 0;
  TaskFilters filters = const TaskFilters();

  void selectStatus(TaskStatusFilter status) => setState(() {
    filters = TaskFilters(
      status: status,
      priority: filters.priority,
      due: filters.due,
      sort: filters.sort,
      tag: filters.tag,
    );
  });

  Widget addAction() => FilledButton.icon(
    onPressed: controller.busy ? null : add,
    icon: const Icon(Icons.add),
    label: const Text('Add task'),
  );

  Widget sidebar() => Container(
    width: 208,
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: AppTheme.line)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12, bottom: 18),
          child: Text(
            'WORKSPACE',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
              color: AppTheme.muted,
            ),
          ),
        ),
        for (final item in [
          (TaskStatusFilter.all, Icons.grid_view_rounded, 'All tasks'),
          (TaskStatusFilter.pending, Icons.radio_button_unchecked, 'To do'),
          (
            TaskStatusFilter.completed,
            Icons.task_alt_rounded,
            'Completed tasks',
          ),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                minLeadingWidth: 20,
                horizontalTitleGap: 10,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                selected: filters.status == item.$1,
                selectedTileColor: const Color(0xFFEEF1FF),
                selectedColor: AppTheme.accent,
                leading: Icon(item.$2, size: 20),
                title: Text(
                  item.$3,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => selectStatus(item.$1),
              ),
            ),
          ),
        const Spacer(),
        const Divider(),
        const SizedBox(height: 16),
        Icon(
          widget.online ? Icons.cloud_outlined : Icons.devices_outlined,
          color: AppTheme.muted,
        ),
        const SizedBox(height: 10),
        Text(
          widget.online ? 'Account workspace' : 'Local workspace',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          widget.online
              ? 'Your tasks, connected to your account.'
              : 'A little more focus.\nOne task at a time.',
          style: const TextStyle(
            color: AppTheme.muted,
            fontSize: 12,
            height: 1.6,
          ),
        ),
      ],
    ),
  );
  @override
  void initState() {
    super.initState();
    controller = TaskController(widget.repository);
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    title.dispose();
    search.dispose();
    super.dispose();
  }

  Future<void> add() async {
    if (!form.currentState!.validate()) return;
    if (await controller.add(title.text, details: draftDetails) && mounted) {
      title.clear();
      form.currentState!.reset();
      setState(() {
        draftDetails = TaskDetails();
        draftRevision++;
      });
    }
  }

  Future<void> edit(TaskItem task) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => EditTaskDialog(
      task: task,
      failureMessage: widget.online
          ? () =>
                '${controller.error ?? 'Could not save.'} Your draft is still here. If a reload is needed, copy your changes, cancel this dialog and reload tasks.'
          : null,
      save: (value, details) =>
          controller.rename(task.id, value, details: details),
    ),
  );

  Future<void> delete(TaskItem task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text(
          'Delete "${task.title}"? You can undo the most recent deletion during this session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await controller.delete(task.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const BrandTitle(),
      actions: [
        if (widget.online)
          IconButton(
            tooltip: 'Reload server tasks',
            onPressed: () => controller.load(),
            icon: const Icon(Icons.refresh),
          ),
        ...?widget.actions,
      ],
    ),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final tasks = controller.matching(query, filters: filters);
              final wide =
                  MediaQuery.sizeOf(context).width >= 1100 &&
                  MediaQuery.textScalerOf(context).scale(14) <= 20;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (wide) sidebar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(wide ? 28 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.notice != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF1FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Semantics(
                                liveRegion: true,
                                child: Text(
                                  widget.notice!,
                                  style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          StudioHeader(
                            summary:
                                '${controller.tasks.where((task) => !task.completed).length} pending · ${controller.tasks.where((task) => task.completed).length} completed',
                          ),
                          const SizedBox(height: 20),
                          SurfacePanel(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: form,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SectionHeading(
                                    'Capture your next task',
                                    icon: Icons.add_circle_outline,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: title,
                                          key: const Key('task-title'),
                                          decoration: const InputDecoration(
                                            labelText: 'Task title',
                                          ),
                                          validator: TaskItem.validateTitle,
                                          onFieldSubmitted: (_) {
                                            if (!controller.busy) add();
                                          },
                                        ),
                                      ),
                                      if (wide) ...[
                                        const SizedBox(width: 12),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: addAction(),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ExpansionTile(
                                    key: ValueKey('details-$draftRevision'),
                                    title: const Text(
                                      'Task details (optional)',
                                    ),
                                    maintainState: true,
                                    children: [
                                      TaskDetailsFields(
                                        initial: draftDetails,
                                        enabled: !controller.busy,
                                        onChanged: (value) =>
                                            draftDetails = value,
                                      ),
                                    ],
                                  ),
                                  if (!wide) addAction(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: search,
                            decoration: const InputDecoration(
                              labelText: 'Search tasks',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) => setState(() => query = value),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.filter_list),
                                label: const Text('Filter and sort'),
                                onPressed: () async {
                                  final value = await showDialog<TaskFilters>(
                                    context: context,
                                    builder: (_) =>
                                        TaskFilterDialog(initial: filters),
                                  );
                                  if (value != null && mounted) {
                                    setState(() => filters = value);
                                  }
                                },
                              ),
                              TextButton(
                                onPressed: () {
                                  search.clear();
                                  setState(() {
                                    query = '';
                                    filters = const TaskFilters();
                                  });
                                },
                                child: const Text('Clear filters'),
                              ),
                            ],
                          ),
                          if (controller.deletedTask != null)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Semantics(
                                      liveRegion: true,
                                      child: Text(
                                        'Deleted: ${controller.deletedTask!.title}',
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: controller.busy
                                          ? null
                                          : controller.undoDelete,
                                      icon: const Icon(Icons.undo),
                                      label: const Text('Undo delete'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (controller.busy)
                            const LinearProgressIndicator(
                              semanticsLabel: 'Loading tasks',
                            ),
                          if (controller.error != null)
                            StatePanel(
                              icon: Icons.cloud_off_rounded,
                              title: 'Let’s try that again',
                              message: controller.error!,
                              error: true,
                              action: TextButton(
                                onPressed: controller.busy
                                    ? null
                                    : controller.load,
                                child: const Text('Retry'),
                              ),
                            ),
                          if (!controller.busy &&
                              controller.error == null &&
                              tasks.isEmpty)
                            StatePanel(
                              icon: controller.tasks.isEmpty
                                  ? Icons.playlist_add_check_rounded
                                  : Icons.search_off_rounded,
                              title: controller.tasks.isEmpty
                                  ? 'A fresh start'
                                  : 'Nothing here just yet',
                              message: controller.tasks.isEmpty
                                  ? 'No tasks yet. Add your first task above.'
                                  : 'No matching tasks.',
                            ),
                          for (final task in tasks)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                color: task.completed
                                    ? const Color(0xFFF1FAF6)
                                    : switch (task.details.priority) {
                                        TaskPriority.high => const Color(
                                          0xFFFFF6F1,
                                        ),
                                        TaskPriority.medium => Colors.white,
                                        TaskPriority.low => const Color(
                                          0xFFF7F4FF,
                                        ),
                                      },
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: [
                                    CheckboxListTile(
                                      value: task.completed,
                                      onChanged: controller.busy
                                          ? null
                                          : (_) => controller.toggle(task),
                                      title: Text(
                                        task.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: task.completed
                                              ? AppTheme.muted
                                              : AppTheme.ink,
                                          decoration: task.completed
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      subtitle: Text(
                                        task.completed
                                            ? 'Completed'
                                            : 'Pending',
                                      ),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    task.details.priority ==
                                                        TaskPriority.high
                                                    ? const Color(0xFFFFEFF1)
                                                    : task.details.priority ==
                                                          TaskPriority.low
                                                    ? AppTheme.mint
                                                    : const Color(0xFFFFF2D5),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Priority: ${task.details.priority.name}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      task.details.priority ==
                                                          TaskPriority.high
                                                      ? const Color(0xFFAB263D)
                                                      : task.details.priority ==
                                                            TaskPriority.low
                                                      ? AppTheme.tealInk
                                                      : AppTheme.amberInk,
                                                ),
                                              ),
                                            ),
                                            if (task.details.dueDate != null)
                                              Text(
                                                'Due: ${TaskDetails.dateLabel(task.details.dueDate!)}',
                                              ),
                                            if (task.details.notes.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                  bottom: 4,
                                                ),
                                                child: Text(
                                                  task.details.notes,
                                                  style: const TextStyle(
                                                    color: AppTheme.muted,
                                                  ),
                                                ),
                                              ),
                                            if (task.details.tags.isNotEmpty)
                                              Wrap(
                                                spacing: 6,
                                                children: task.details.tags
                                                    .map(
                                                      (tag) => Semantics(
                                                        container: true,
                                                        label: 'Tag: $tag',
                                                        excludeSemantics: true,
                                                        child: Chip(
                                                          label: Text(tag),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        right: 12,
                                        bottom: 8,
                                      ),
                                      child: Wrap(
                                        alignment: WrapAlignment.end,
                                        spacing: 8,
                                        children: [
                                          TextButton.icon(
                                            onPressed: controller.busy
                                                ? null
                                                : () => edit(task),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                            ),
                                            label: const Text('Edit'),
                                          ),
                                          TextButton.icon(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                            onPressed: controller.busy
                                                ? null
                                                : () => delete(task),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            label: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

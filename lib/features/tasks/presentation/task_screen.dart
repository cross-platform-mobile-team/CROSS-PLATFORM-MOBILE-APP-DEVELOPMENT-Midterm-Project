import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ui_components.dart';

import '../application/task_controller.dart';
import '../domain/task_item.dart';
import '../domain/task_repository.dart';
import 'edit_task_dialog.dart';
import '../domain/task_details.dart';
import '../domain/task_filters.dart';
import 'quick_task_input.dart';
import 'workspace_components.dart';
import 'task_filter_dialog.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({
    super.key,
    required this.repository,
    this.actions,
    this.exitActions,
    this.online = false,
    this.notice,
    this.temporary = false,
  });
  final TaskRepository repository;
  final List<Widget>? actions;

  /// Actions that remove this workspace must await the supplied draft guard.
  final List<Widget> Function(Future<bool> Function() confirmExit)? exitActions;
  final bool online;
  final String? notice;
  final bool temporary;
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final TaskController controller;
  final title = TextEditingController();
  final form = GlobalKey<FormState>();
  String query = '';
  final search = TextEditingController();
  final searchFocus = FocusNode();
  TaskDetails draftDetails = TaskDetails();
  bool metadataDirty = false;
  bool confirmingExit = false;
  int draftRevision = 0;
  TaskFilters filters = const TaskFilters();

  Future<bool> confirmExit() async {
    if (confirmingExit) return false;
    if (controller.busy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: EdgeInsets.fromLTRB(isWide(context) ? 270 : 16, 0, 16, 16),
          content: const Text('Wait for the current operation to finish.'),
        ),
      );
      return false;
    }
    if (title.text.trim().isEmpty && !metadataDirty) return true;
    confirmingExit = true;
    try {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard new task draft?'),
          content: const Text(
            'Your unsaved task will be lost when you leave this workspace.',
          ),
          actions: [
            TextButton(
              autofocus: true,
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Continue editing'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard and leave'),
            ),
          ],
        ),
      );
      return mounted && discard == true && !controller.busy;
    } finally {
      confirmingExit = false;
    }
  }

  void selectStatus(TaskStatusFilter status) => setState(() {
    filters = TaskFilters(
      status: status,
      priority: filters.priority,
      due: filters.due,
      sort: filters.sort,
      tag: filters.tag,
    );
  });

  bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1100 &&
      MediaQuery.textScalerOf(context).scale(14) <= 20;

  List<Widget> workspaceActions() => [
    if (widget.online)
      IconButton(
        tooltip: 'Reload server tasks',
        onPressed: controller.busy ? null : controller.load,
        icon: const Icon(Icons.refresh),
      ),
    ...?widget.actions,
    ...?widget.exitActions?.call(confirmExit),
  ];

  void focusSearch() {
    if (ModalRoute.of(context)?.isCurrent != true) return;
    searchFocus.requestFocus();
    final target = searchFocus.context;
    if (target != null) Scrollable.ensureVisible(target);
  }

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
    searchFocus.dispose();
    super.dispose();
  }

  Future<void> add() async {
    if (!form.currentState!.validate()) return;
    if (await controller.add(title.text, details: draftDetails) && mounted) {
      title.clear();
      form.currentState!.reset();
      setState(() {
        draftDetails = TaskDetails();
        metadataDirty = false;
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
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.keyK, control: true):
          focusSearch,
      const SingleActivator(LogicalKeyboardKey.keyK, meta: true): focusSearch,
    },
    child: Focus(
      autofocus: true,
      child: Scaffold(
        appBar: isWide(context)
            ? null
            : AppBar(title: const BrandTitle(), actions: workspaceActions()),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1600),
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
                      if (wide)
                        SidebarNavigation(
                          total: controller.tasks.length,
                          completed: controller.tasks
                              .where((task) => task.completed)
                              .length,
                          selected: filters.status,
                          onSelected: selectStatus,
                          online: widget.online,
                          temporary: widget.temporary,
                          actions: workspaceActions(),
                        ),
                      Expanded(
                        key: const ValueKey('workspace-canvas'),
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
                              TaskHeader(
                                total: controller.tasks.length,
                                completed: controller.tasks
                                    .where((task) => task.completed)
                                    .length,
                              ),
                              const SizedBox(height: 24),
                              QuickTaskInput(
                                key: ValueKey('quick-create-$draftRevision'),
                                formKey: form,
                                title: title,
                                busy: controller.busy,
                                onSubmit: add,
                                onDetailsChanged: (value) =>
                                    draftDetails = value,
                                onDirtyChanged: (value) =>
                                    metadataDirty = value,
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: search,
                                focusNode: searchFocus,
                                decoration: InputDecoration(
                                  labelText: 'Search tasks',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: wide
                                      ? const Padding(
                                          padding: EdgeInsets.all(14),
                                          child: Text(
                                            'Ctrl + K',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.muted,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                onChanged: (value) =>
                                    setState(() => query = value),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      shape: const StadiumBorder(),
                                    ),
                                    icon: const Icon(Icons.filter_list),
                                    label: const Text('Filter and sort'),
                                    onPressed: () async {
                                      final value =
                                          await showDialog<TaskFilters>(
                                            context: context,
                                            builder: (_) => TaskFilterDialog(
                                              initial: filters,
                                            ),
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
                                  PopupMenuButton<TaskSort>(
                                    tooltip: 'Sort tasks',
                                    initialValue: filters.sort,
                                    onSelected: (sort) => setState(() {
                                      filters = TaskFilters(
                                        status: filters.status,
                                        priority: filters.priority,
                                        due: filters.due,
                                        tag: filters.tag,
                                        sort: sort,
                                      );
                                    }),
                                    itemBuilder: (_) => TaskSort.values
                                        .map(
                                          (sort) => CheckedPopupMenuItem(
                                            value: sort,
                                            checked: sort == filters.sort,
                                            child: Text(switch (sort) {
                                              TaskSort.newest => 'Newest first',
                                              TaskSort.priority => 'Priority',
                                              TaskSort.dueDate => 'Due date',
                                              TaskSort.title => 'Title A–Z',
                                            }),
                                          ),
                                        )
                                        .toList(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      decoration: ShapeDecoration(
                                        shape: StadiumBorder(
                                          side: BorderSide(
                                            color: AppTheme.line,
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.sort, size: 18),
                                          SizedBox(width: 8),
                                          Text('Sort'),
                                          SizedBox(width: 4),
                                          Icon(Icons.expand_more, size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (controller.deletedTask != null)
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                EmptyStateWidget(
                                  empty: controller.tasks.isEmpty,
                                ),
                              for (final task in tasks)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Card(
                                    color: Colors.white,
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
                                                        ? const Color(
                                                            0xFFFFEFF1,
                                                          )
                                                        : task
                                                                  .details
                                                                  .priority ==
                                                              TaskPriority.low
                                                        ? AppTheme.mint
                                                        : const Color(
                                                            0xFFFFF2D5,
                                                          ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'Priority: ${task.details.priority.name}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          task
                                                                  .details
                                                                  .priority ==
                                                              TaskPriority.high
                                                          ? const Color(
                                                              0xFFAB263D,
                                                            )
                                                          : task
                                                                    .details
                                                                    .priority ==
                                                                TaskPriority.low
                                                          ? AppTheme.tealInk
                                                          : AppTheme.amberInk,
                                                    ),
                                                  ),
                                                ),
                                                if (task.details.dueDate !=
                                                    null)
                                                  Text(
                                                    'Due: ${TaskDetails.dateLabel(task.details.dueDate!)}',
                                                  ),
                                                if (task
                                                    .details
                                                    .notes
                                                    .isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
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
                                                if (task
                                                    .details
                                                    .tags
                                                    .isNotEmpty)
                                                  Wrap(
                                                    spacing: 6,
                                                    children: task.details.tags
                                                        .map(
                                                          (tag) => Semantics(
                                                            container: true,
                                                            label: 'Tag: $tag',
                                                            excludeSemantics:
                                                                true,
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
                                                  foregroundColor: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
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
      ),
    ),
  );
}

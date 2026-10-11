import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import 'task_card.dart';
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
    this.clock,
  });
  final TaskRepository repository;
  final List<Widget>? actions;

  /// Actions that remove this workspace must await the supplied draft guard.
  final List<Widget> Function(Future<bool> Function() confirmExit)? exitActions;
  final bool online;
  final String? notice;
  final bool temporary;
  final DateTime Function()? clock;
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
  final newTaskFocus = FocusNode();
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

  bool get hasFilters =>
      filters.status != TaskStatusFilter.all ||
      filters.priority != null ||
      filters.due != DueFilter.all ||
      filters.tag.trim().isNotEmpty;
  void clearSearch() {
    search.clear();
    setState(() => query = '');
  }

  void resetFilters() =>
      setState(() => filters = TaskFilters(sort: filters.sort));
  void focusNewTask() {
    newTaskFocus.requestFocus();
    final target = newTaskFocus.context;
    if (target != null) Scrollable.ensureVisible(target);
  }

  void focusSearch() {
    if (ModalRoute.of(context)?.isCurrent != true) return;
    searchFocus.requestFocus();
    final target = searchFocus.context;
    if (target != null) Scrollable.ensureVisible(target);
  }

  @override
  void initState() {
    super.initState();
    controller = TaskController(widget.repository, clock: widget.clock);
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    title.dispose();
    search.dispose();
    searchFocus.dispose();
    newTaskFocus.dispose();
    super.dispose();
  }

  Future<void> add() async {
    if (controller.busy) return;
    if (!form.currentState!.validate()) return;
    final submittedTitle = title.text;
    final submittedDetails = draftDetails;
    final saved = await controller.add(
      submittedTitle,
      details: submittedDetails,
    );
    if (saved && mounted) {
      final added = controller.lastAdded;
      final hidden =
          added != null &&
          !controller
              .matching(query, filters: filters)
              .any((task) => task.id == added.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: EdgeInsets.fromLTRB(isWide(context) ? 270 : 16, 0, 16, 16),
          content: Text(
            hidden ? 'Task added. Hidden by current filters.' : 'Task added.',
          ),
          action: hidden
              ? SnackBarAction(
                  label: 'View task',
                  onPressed: () {
                    search.clear();
                    setState(() {
                      query = '';
                      filters = const TaskFilters();
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) edit(added);
                    });
                  },
                )
              : null,
        ),
      );
    }
    // A completed write owns only the draft it submitted, not newer input.
    if (saved &&
        mounted &&
        title.text == submittedTitle &&
        identical(draftDetails, submittedDetails)) {
      title.clear();
      form.currentState!.reset();
      setState(() {
        draftDetails = TaskDetails();
        metadataDirty = false;
        draftRevision++;
      });
    }
  }

  Future<void> edit(TaskItem task) {
    String? recreatedId;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditTaskDialog(
        task: task,
        failureMessage: widget.online
            ? () => switch (controller.errorCode) {
                'revision_conflict' || 'conflict' => 'Another client changed the task list. Load the latest version to compare; your draft stays here.',
                'network' => 'The response was not confirmed. The server may already have saved your changes. Load the latest version before deciding what to do.',
                _ =>
                  '${controller.error ?? "Could not save."} Load the latest version; your draft stays here.',
              }
            : null,
        reload: widget.online
            ? () async {
                if (!await controller.load()) throw StateError('Reload failed');
                return controller.tasks
                    .where((item) => item.id == (recreatedId ?? task.id))
                    .firstOrNull;
              }
            : null,
        saveAsNew: widget.online
            ? (value, details) {
                recreatedId ??= controller.idGenerator();
                return controller.add(value, details: details, id: recreatedId);
              }
            : null,
        save: (value, details) async {
          final saved = await controller.rename(
            recreatedId ?? task.id,
            value,
            details: details,
          );
          if (saved && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                margin: EdgeInsets.fromLTRB(
                  isWide(context) ? 270 : 16,
                  0,
                  16,
                  16,
                ),
                content: const Text('Task saved.'),
              ),
            );
          }
          return saved;
        },
      ),
    );
  }

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
                        child: CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                wide ? 28 : 16,
                                wide ? 28 : 16,
                                wide ? 28 : 16,
                                0,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (widget.notice != null)
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF1FF),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                    if (!wide)
                                      Text(
                                        widget.temporary
                                            ? 'Sample · changes discarded on exit'
                                            : widget.online
                                            ? 'Account · saved online'
                                            : 'Local · saved on this device',
                                        style: const TextStyle(
                                          color: AppTheme.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    TaskHeader(
                                      total: controller.tasks.length,
                                      completed: controller.tasks
                                          .where((task) => task.completed)
                                          .length,
                                    ),
                                    const SizedBox(height: 12),
                                    QuickTaskInput(
                                      key: ValueKey(
                                        'quick-create-$draftRevision',
                                      ),
                                      formKey: form,
                                      titleFocus: newTaskFocus,
                                      title: title,
                                      busy: controller.busy,
                                      adding:
                                          controller.operation ==
                                          TaskOperation.add,
                                      onSubmit: add,
                                      onDetailsChanged: (value) =>
                                          draftDetails = value,
                                      onDirtyChanged: (value) =>
                                          metadataDirty = value,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: search,
                                      focusNode: searchFocus,
                                      decoration: InputDecoration(
                                        labelText: 'Search tasks',
                                        prefixIcon: const Icon(Icons.search),
                                        suffixIcon: query.isNotEmpty
                                            ? IconButton(
                                                tooltip: 'Clear search',
                                                onPressed: clearSearch,
                                                icon: const Icon(Icons.close),
                                              )
                                            : wide
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
                                    const SizedBox(height: 8),
                                    if (!wide)
                                      Wrap(
                                        spacing: 8,
                                        children: TaskStatusFilter.values
                                            .map(
                                              (status) => ChoiceChip(
                                                label: Text(status.label),
                                                selected:
                                                    filters.status == status,
                                                onSelected: (_) =>
                                                    selectStatus(status),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    Wrap(
                                      spacing: 8,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
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
                                                  builder: (_) =>
                                                      TaskFilterDialog(
                                                        initial: filters,
                                                      ),
                                                );
                                            if (value != null && mounted) {
                                              setState(() => filters = value);
                                            }
                                          },
                                        ),
                                        Text(
                                          'Sort: ${filters.sort.label}',
                                          style: const TextStyle(
                                            color: AppTheme.ink,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${tasks.length} results',
                                          style: const TextStyle(
                                            color: AppTheme.ink,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        if (filters.priority != null)
                                          InputChip(
                                            label: Text(
                                              'Priority: ${filters.priority!.name}',
                                            ),
                                            onDeleted: () => setState(
                                              () => filters = TaskFilters(
                                                status: filters.status,
                                                due: filters.due,
                                                tag: filters.tag,
                                                sort: filters.sort,
                                              ),
                                            ),
                                          ),
                                        if (filters.due != DueFilter.all)
                                          InputChip(
                                            label: Text(filters.due.label),
                                            onDeleted: () => setState(
                                              () => filters = TaskFilters(
                                                status: filters.status,
                                                priority: filters.priority,
                                                tag: filters.tag,
                                                sort: filters.sort,
                                              ),
                                            ),
                                          ),
                                        if (filters.tag.trim().isNotEmpty)
                                          InputChip(
                                            label: Text('Tag: ${filters.tag}'),
                                            onDeleted: () => setState(
                                              () => filters = TaskFilters(
                                                status: filters.status,
                                                priority: filters.priority,
                                                due: filters.due,
                                                sort: filters.sort,
                                              ),
                                            ),
                                          ),
                                        if (hasFilters)
                                          TextButton(
                                            onPressed: resetFilters,
                                            child: const Text('Reset filters'),
                                          ),
                                      ],
                                    ),
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
                                                label: Text(
                                                  controller.operation ==
                                                          TaskOperation.undo
                                                      ? 'Restoring…'
                                                      : 'Undo delete',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if (controller.busy)
                                      LinearProgressIndicator(
                                        semanticsLabel:
                                            controller.operation.label,
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
                                          child: const Text('Reload tasks'),
                                        ),
                                      ),
                                    if (!controller.busy &&
                                        controller.error == null &&
                                        tasks.isEmpty)
                                      EmptyStateWidget(
                                        empty: controller.tasks.isEmpty,
                                        action: TextButton(
                                          onPressed: controller.tasks.isEmpty
                                              ? focusNewTask
                                              : query.isNotEmpty
                                              ? clearSearch
                                              : resetFilters,
                                          child: Text(
                                            controller.tasks.isEmpty
                                                ? 'Add your first task'
                                                : query.isNotEmpty
                                                ? 'Clear search'
                                                : 'Reset filters',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                horizontal: wide ? 28 : 16,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final task = tasks[index];
                                    return Padding(
                                      key: ValueKey('task-card-${task.id}'),
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: Semantics(
                                        container: true,
                                        explicitChildNodes: true,
                                        sortKey: OrdinalSortKey(
                                          index.toDouble(),
                                        ),
                                        child: TaskCard(
                                          task: task,
                                          now: controller.clock(),
                                          busy: controller.busy,
                                          activity:
                                              controller.activeTaskId == task.id
                                              ? controller.operation.label
                                              : null,
                                          onToggle: () =>
                                              controller.toggle(task),
                                          onEdit: () => edit(task),
                                          onDelete: () => delete(task),
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: tasks.length,
                                  findChildIndexCallback: (key) {
                                    final index = tasks.indexWhere(
                                      (task) =>
                                          ValueKey('task-card-${task.id}') ==
                                          key,
                                    );
                                    return index < 0 ? null : index;
                                  },
                                ),
                              ),
                            ),
                          ],
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

import 'package:flutter/material.dart';

import '../application/task_controller.dart';
import '../domain/task_item.dart';
import '../domain/task_repository.dart';
import 'edit_task_dialog.dart';
import '../domain/task_details.dart';
import '../domain/task_filters.dart';
import 'task_details_fields.dart';
import 'task_filter_dialog.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key, required this.repository});
  final TaskRepository repository;
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
    appBar: AppBar(title: const Text('TaskFlow QA Lab')),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final tasks = controller.matching(query, filters: filters);
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Make room for what matters.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${controller.tasks.where((task) => !task.completed).length} pending · ${controller.tasks.where((task) => task.completed).length} completed',
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: title,
                          key: const Key('task-title'),
                          decoration: const InputDecoration(
                            labelText: 'Task title',
                            border: OutlineInputBorder(),
                          ),
                          validator: TaskItem.validateTitle,
                          onFieldSubmitted: (_) {
                            if (!controller.busy) add();
                          },
                        ),
                        const SizedBox(height: 12),
                        ExpansionTile(
                          key: ValueKey('details-$draftRevision'),
                          title: const Text('Task details (optional)'),
                          maintainState: true,
                          children: [
                            TaskDetailsFields(
                              initial: draftDetails,
                              enabled: !controller.busy,
                              onChanged: (value) => draftDetails = value,
                            ),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: controller.busy ? null : add,
                          icon: const Icon(Icons.add),
                          label: const Text('Add task'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: search,
                    decoration: const InputDecoration(
                      labelText: 'Search tasks',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
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
                            builder: (_) => TaskFilterDialog(initial: filters),
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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Semantics(
                              liveRegion: true,
                              child: Text(controller.error!),
                            ),
                            TextButton(
                              onPressed: controller.busy
                                  ? null
                                  : controller.load,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!controller.busy &&
                      controller.error == null &&
                      tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        controller.tasks.isEmpty
                            ? 'No tasks yet. Add your first task above.'
                            : 'No matching tasks.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  for (final task in tasks)
                    Card(
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
                                decoration: task.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              task.completed ? 'Completed' : 'Pending',
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Priority: ${task.details.priority.name}',
                                  ),
                                  if (task.details.dueDate != null)
                                    Text(
                                      'Due: ${TaskDetails.dateLabel(task.details.dueDate!)}',
                                    ),
                                  if (task.details.notes.isNotEmpty)
                                    Text(task.details.notes),
                                  if (task.details.tags.isNotEmpty)
                                    Wrap(
                                      spacing: 6,
                                      children: task.details.tags
                                          .map((tag) => Chip(label: Text(tag)))
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
                              spacing: 8,
                              children: [
                                TextButton.icon(
                                  onPressed: controller.busy
                                      ? null
                                      : () => edit(task),
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Edit'),
                                ),
                                TextButton.icon(
                                  onPressed: controller.busy
                                      ? null
                                      : () => delete(task),
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Delete'),
                                ),
                              ],
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
  );
}

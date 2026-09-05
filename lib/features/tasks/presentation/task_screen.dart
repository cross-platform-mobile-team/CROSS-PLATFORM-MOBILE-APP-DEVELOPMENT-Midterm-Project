import 'package:flutter/material.dart';

import '../application/task_controller.dart';
import '../domain/task_item.dart';
import '../domain/task_repository.dart';

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
    super.dispose();
  }

  Future<void> add() async {
    if (!form.currentState!.validate()) return;
    if (await controller.add(title.text) && mounted) {
      title.clear();
      form.currentState!.reset();
    }
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
              final tasks = controller.matching(query);
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
                    decoration: const InputDecoration(
                      labelText: 'Search tasks',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => query = value),
                  ),
                  const SizedBox(height: 16),
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
                        query.trim().isEmpty
                            ? 'No tasks yet. Add your first task above.'
                            : 'No matching tasks.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  for (final task in tasks)
                    Card(
                      child: CheckboxListTile(
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

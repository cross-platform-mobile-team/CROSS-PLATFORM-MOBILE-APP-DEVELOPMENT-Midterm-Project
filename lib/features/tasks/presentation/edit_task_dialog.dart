import 'package:flutter/material.dart';

import '../domain/task_item.dart';
import '../domain/task_details.dart';
import 'task_details_fields.dart';

class EditTaskDialog extends StatefulWidget {
  const EditTaskDialog({super.key, required this.task, required this.save});
  final TaskItem task;
  final Future<bool> Function(String, TaskDetails) save;

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late final TextEditingController title = TextEditingController(
    text: widget.task.title,
  );
  final form = GlobalKey<FormState>();
  bool saving = false;
  bool failed = false;
  late TaskDetails details = widget.task.details;

  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() {
      saving = true;
      failed = false;
    });
    final success = await widget.save(title.text, details);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        saving = false;
        failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: AlertDialog(
      title: const Text('Edit task'),
      content: Form(
        key: form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('edit-task-title'),
                controller: title,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Task title'),
                validator: TaskItem.validateTitle,
                enabled: !saving,
                onFieldSubmitted: (_) => save(),
              ),
              if (failed)
                Semantics(
                  liveRegion: true,
                  child: const Text(
                    'Could not save. Your changes are still here. Try again.',
                  ),
                ),
              TaskDetailsFields(
                initial: widget.task.details,
                enabled: !saving,
                onChanged: (value) => details = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: saving ? null : save,
          child: Text(saving ? 'Saving…' : 'Save changes'),
        ),
      ],
    ),
  );
}

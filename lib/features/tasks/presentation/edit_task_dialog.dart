import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/task_item.dart';
import '../domain/task_details.dart';
import 'task_details_fields.dart';

class EditTaskDialog extends StatefulWidget {
  const EditTaskDialog({
    super.key,
    required this.task,
    required this.save,
    this.failureMessage,
  });
  final TaskItem task;
  final Future<bool> Function(String, TaskDetails) save;
  final String? Function()? failureMessage;

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
  bool detailsDirty = false;
  bool confirming = false;
  bool get dirty => title.text != widget.task.title || detailsDirty;
  late TaskDetails details = widget.task.details;

  @override
  void initState() {
    super.initState();
    title.addListener(refreshDirty);
  }

  void refreshDirty() => setState(() {});

  Future<void> requestClose() async {
    if (saving || confirming) return;
    if (!dirty) {
      Navigator.of(context).pop();
      return;
    }
    confirming = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your unsaved changes will be lost.'),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    confirming = false;
    if (!mounted) return;
    if (discard == true) Navigator.of(context).pop();
  }

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
    canPop: !saving && !dirty,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) requestClose();
    },
    child: CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): requestClose,
      },
      child: AlertDialog(
        icon: const Icon(Icons.edit_note_rounded),
        title: const Text('Edit task'),
        content: SizedBox(
          width: 440,
          child: Form(
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
                      child: Text(
                        widget.failureMessage?.call() ?? 'Could not save. Your changes are still here. Try again.',
                      ),
                    ),
                  TaskDetailsFields(
                    initial: widget.task.details,
                    enabled: !saving,
                    onChanged: (value) => details = value,
                    onDirtyChanged: (value) =>
                        setState(() => detailsDirty = value),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : requestClose,
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: saving ? null : save,
            child: Text(saving ? 'Saving…' : 'Save changes'),
          ),
        ],
      ),
    ),
  );
}

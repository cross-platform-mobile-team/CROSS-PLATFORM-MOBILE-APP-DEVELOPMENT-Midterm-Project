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
    this.reload,
    this.saveAsNew,
  });
  final TaskItem task;
  final Future<bool> Function(String, TaskDetails) save;
  final String? Function()? failureMessage;
  final Future<TaskItem?> Function()? reload;
  final Future<bool> Function(String, TaskDetails)? saveAsNew;

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late final TextEditingController title = TextEditingController(
    text: widget.task.title,
  );
  final form = GlobalKey<FormState>();
  final titleFocus = FocusNode();
  final fields = GlobalKey<TaskDetailsFieldsState>();
  bool saving = false;
  bool failed = false;
  bool needsReload = false;
  bool reviewed = false;
  TaskItem? latest;
  String? recoveryError;
  bool detailsDirty = false;
  bool titleDirty = false;
  bool confirming = false;
  bool get dirty => title.text != widget.task.title || detailsDirty;
  late TaskDetails details = widget.task.details;

  @override
  void initState() {
    super.initState();
    title.addListener(refreshDirty);
  }

  void refreshDirty() {
    final next = title.text != widget.task.title;
    if (next != titleDirty || reviewed) setState(() => titleDirty = next);
  }

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
    titleFocus.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (saving || needsReload) return;
    if (reviewed && alreadySaved) {
      Navigator.pop(context);
      return;
    }
    if (!form.currentState!.validate()) {
      if (TaskItem.validateTitle(title.text) != null) {
        titleFocus.requestFocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final target = titleFocus.context;
          if (target != null) Scrollable.ensureVisible(target);
        });
      } else {
        fields.currentState?.focusFirstInvalid();
      }
      return;
    }
    setState(() {
      saving = true;
      failed = false;
    });
    final success = reviewed && latest == null
        ? await widget.saveAsNew!(title.text, details)
        : await widget.save(title.text, details);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        saving = false;
        failed = true;
        needsReload = widget.reload != null;
        reviewed = false;
      });
    }
  }

  Future<void> reload() async {
    if (saving) return;
    setState(() {
      saving = true;
      recoveryError = null;
    });
    try {
      final value = await widget.reload!();
      if (!mounted) return;
      setState(() {
        latest = value;
        reviewed = true;
        needsReload = false;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => recoveryError =
              'Could not reload. Your draft is still here. Try loading again.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  String describe(TaskItem task) =>
      '${task.title}\nPriority: ${task.details.priority.name}\nDue: ${task.details.dueDate == null ? "No due date" : TaskDetails.dateLabel(task.details.dueDate!)}\nTags: ${task.details.tags.join(", ")}\n${task.details.notes}';
  bool get alreadySaved =>
      latest != null &&
      latest!.title == title.text.trim() &&
      latest!.details.notes == details.notes &&
      latest!.details.priority == details.priority &&
      latest!.details.dueDate == details.dueDate &&
      latest!.details.tags.join('\n') == details.tags.join('\n');

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
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: const Key('edit-task-title'),
                    controller: title,
                    focusNode: titleFocus,
                    autofocus: true,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(labelText: 'Task title'),
                    validator: TaskItem.validateTitle,
                    enabled: !saving,
                    onFieldSubmitted: (_) => save(),
                  ),
                  const SizedBox(height: 20),
                  if (failed && !reviewed)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        widget.failureMessage?.call() ?? 'Could not save. Your changes are still here. Try again.',
                      ),
                    ),
                  if (recoveryError != null)
                    Semantics(liveRegion: true, child: Text(recoveryError!)),
                  if (needsReload)
                    TextButton(
                      onPressed: saving ? null : reload,
                      child: Text(
                        saving
                            ? 'Loading latest…'
                            : 'Load latest; keep my draft',
                      ),
                    ),
                  if (reviewed)
                    Semantics(
                      liveRegion: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            latest == null
                                ? 'This task was deleted elsewhere. Your draft is preserved. You can choose to save it as a new task.'
                                : alreadySaved
                                ? 'The server already contains this draft. Close without writing again.'
                                : 'Compare the latest saved version below with your draft in the form. Applying your draft replaces these editable fields.',
                          ),
                          if (latest != null)
                            ExpansionTile(
                              title: const Text('Latest saved version'),
                              expandedAlignment: Alignment.centerLeft,
                              childrenPadding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                20,
                              ),
                              children: [SelectableText(describe(latest!))],
                            ),
                        ],
                      ),
                    ),
                  TaskDetailsFields(
                    key: fields,
                    initial: widget.task.details,
                    enabled: !saving,
                    onChanged: (value) => setState(() => details = value),
                    onDirtyChanged: (value) {
                      if (value != detailsDirty) {
                        setState(() => detailsDirty = value);
                      }
                    },
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
            onPressed: saving || needsReload
                ? null
                : reviewed && alreadySaved
                ? () => Navigator.pop(context)
                : save,
            child: Text(
              saving
                  ? 'Saving…'
                  : reviewed
                  ? alreadySaved
                        ? 'Close; already saved'
                        : latest == null
                        ? 'Save as new task'
                        : 'Apply my draft'
                  : 'Save changes',
            ),
          ),
        ],
      ),
    ),
  );
}

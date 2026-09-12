import 'package:flutter/material.dart';

import '../domain/task_details.dart';

class TaskDetailsFields extends StatefulWidget {
  const TaskDetailsFields({
    super.key,
    required this.initial,
    required this.onChanged,
    this.enabled = true,
    this.onDirtyChanged,
  });
  final TaskDetails initial;
  final ValueChanged<TaskDetails> onChanged;
  final bool enabled;
  final ValueChanged<bool>? onDirtyChanged;
  @override
  State<TaskDetailsFields> createState() => _TaskDetailsFieldsState();
}

class _TaskDetailsFieldsState extends State<TaskDetailsFields> {
  late String notes = widget.initial.notes;
  late String tags = widget.initial.tags.join(', ');
  late TaskPriority priority = widget.initial.priority;
  late DateTime? due = widget.initial.dueDate;
  late String rawDate = due == null ? '' : TaskDetails.dateLabel(due!);
  TaskDetails get value => TaskDetails(
    notes: notes,
    tags: tags.split(','),
    priority: priority,
    dueDate: due,
  );
  void emit() {
    widget.onDirtyChanged?.call(
      notes != widget.initial.notes ||
          tags != widget.initial.tags.join(', ') ||
          priority != widget.initial.priority ||
          rawDate !=
              (widget.initial.dueDate == null
                  ? ''
                  : TaskDetails.dateLabel(widget.initial.dueDate!)),
    );
    widget.onChanged(value);
  }

  static String? validateDate(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = DateTime.tryParse(text);
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text) ||
        parsed == null ||
        TaskDetails.dateLabel(parsed) != text) {
      return 'Enter a valid date as YYYY-MM-DD';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextFormField(
        key: const Key('task-notes'),
        initialValue: notes,
        enabled: widget.enabled,
        decoration: const InputDecoration(labelText: 'Notes (optional)'),
        minLines: 1,
        maxLines: 3,
        validator: (text) =>
            (text?.length ?? 0) > 2000 ? 'Use 2000 characters or fewer' : null,
        onChanged: (text) {
          notes = text;
          emit();
        },
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<TaskPriority>(
        key: const Key('task-priority'),
        initialValue: priority,
        decoration: const InputDecoration(labelText: 'Priority'),
        items: TaskPriority.values
            .map(
              (item) => DropdownMenuItem(value: item, child: Text(item.name)),
            )
            .toList(),
        onChanged: widget.enabled
            ? (item) {
                if (item != null) {
                  priority = item;
                  emit();
                }
              }
            : null,
      ),
      TextFormField(
        key: const Key('task-due-date'),
        enabled: widget.enabled,
        initialValue: due == null ? '' : TaskDetails.dateLabel(due!),
        decoration: const InputDecoration(
          labelText: 'Due date (YYYY-MM-DD)',
          helperText: 'Optional. Clear to remove the date.',
        ),
        validator: validateDate,
        onChanged: (text) {
          rawDate = text;
          if (validateDate(text) == null) {
            due = text.trim().isEmpty ? null : DateTime.parse(text.trim());
          }
          emit();
        },
      ),
      TextFormField(
        key: const Key('task-tags'),
        initialValue: tags,
        enabled: widget.enabled,
        decoration: const InputDecoration(labelText: 'Tags (comma-separated)'),
        validator: (text) =>
            TaskDetails(tags: (text ?? '').split(',')).validationError,
        onChanged: (text) {
          tags = text;
          emit();
        },
      ),
    ],
  );
}

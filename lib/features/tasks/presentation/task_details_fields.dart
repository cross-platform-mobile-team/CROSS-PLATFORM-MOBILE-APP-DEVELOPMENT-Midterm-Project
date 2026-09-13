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
  State<TaskDetailsFields> createState() => TaskDetailsFieldsState();
}

class TaskDetailsFieldsState extends State<TaskDetailsFields> {
  late String notes = widget.initial.notes;
  late String tags = widget.initial.tags.join(', ');
  late TaskPriority priority = widget.initial.priority;
  late DateTime? due = widget.initial.dueDate;
  late String rawDate = due == null ? '' : TaskDetails.dateLabel(due!);
  late final dateText = TextEditingController(text: rawDate);
  final priorityField = GlobalKey<FormFieldState<TaskPriority>>();

  void setPriority(TaskPriority value) {
    if (!widget.enabled) return;
    priority = value;
    priorityField.currentState?.didChange(value);
    emit();
  }

  Future<void> pickDate() async {
    if (!widget.enabled) return;
    final initial = due ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 100),
      lastDate: DateTime(initial.year + 100, 12, 31),
    );
    if (!mounted || !widget.enabled || selected == null) return;
    due = selected;
    rawDate = TaskDetails.dateLabel(selected);
    dateText.text = rawDate;
    emit();
  }

  @override
  void dispose() {
    dateText.dispose();
    super.dispose();
  }

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
      const SizedBox(height: 20),
      KeyedSubtree(
        key: const Key('task-priority'),
        child: DropdownButtonFormField<TaskPriority>(
          isExpanded: true,
          isDense: false,
          itemHeight: null,
          key: priorityField,
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
      ),
      const SizedBox(height: 20),
      TextFormField(
        key: const Key('task-due-date'),
        enabled: widget.enabled,
        controller: dateText,
        decoration: const InputDecoration(
          labelText: 'Due date',
          helperText: 'YYYY-MM-DD. Optional; clear to remove.',
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
      const SizedBox(height: 20),
      TextFormField(
        key: const Key('task-tags'),
        initialValue: tags,
        enabled: widget.enabled,
        decoration: const InputDecoration(
          labelText: 'Tags',
          helperText: 'Separate tags with commas.',
        ),
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

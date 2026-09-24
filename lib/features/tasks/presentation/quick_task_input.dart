import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';
import '../domain/task_details.dart';
import '../domain/task_item.dart';
import 'task_details_fields.dart';

class QuickTaskInput extends StatefulWidget {
  const QuickTaskInput({
    super.key,
    required this.formKey,
    required this.title,
    required this.busy,
    required this.onSubmit,
    required this.onDetailsChanged,
    required this.onDirtyChanged,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController title;
  final bool busy;
  final VoidCallback onSubmit;
  final ValueChanged<TaskDetails> onDetailsChanged;
  final ValueChanged<bool> onDirtyChanged;
  @override
  State<QuickTaskInput> createState() => _QuickTaskInputState();
}

class _QuickTaskInputState extends State<QuickTaskInput> {
  final fields = GlobalKey<TaskDetailsFieldsState>();
  final expansion = ExpansibleController();
  final titleFocus = FocusNode();
  TaskDetails details = TaskDetails();

  void submit() {
    if (widget.busy) return;
    if (widget.formKey.currentState!.validate()) {
      widget.onSubmit();
      return;
    }
    if (TaskItem.validateTitle(widget.title.text) != null) {
      titleFocus.requestFocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final target = titleFocus.context;
        if (target != null) Scrollable.ensureVisible(target);
      });
      return;
    }
    expansion.expand();
    // Retained fields cannot receive focus while the tile is still offstage.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) fields.currentState?.focusFirstInvalid();
    });
  }

  @override
  void dispose() {
    expansion.dispose();
    titleFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MotionSurface(
    padding: const EdgeInsets.all(20),
    tint: const Color(0xFFFFFEFF),
    child: Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final input = TextFormField(
                key: const Key('task-title'),
                controller: widget.title,
                focusNode: titleFocus,
                validator: TaskItem.validateTitle,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  hintText: 'What needs to get done?',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  helperText: 'Press Enter to add',
                ),
                onFieldSubmitted: (_) => submit(),
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  IconButton.outlined(
                    tooltip: 'Choose due date',
                    onPressed: widget.busy
                        ? null
                        : () => fields.currentState?.pickDate(),
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                  PopupMenuButton<TaskPriority>(
                    tooltip: 'Quick priority',
                    enabled: !widget.busy,
                    icon: const Icon(Icons.flag_outlined, size: 20),
                    onSelected: (value) =>
                        fields.currentState?.setPriority(value),
                    itemBuilder: (_) => TaskPriority.values
                        .map(
                          (value) => PopupMenuItem(
                            value: value,
                            child: Text(value.name),
                          ),
                        )
                        .toList(),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(shape: const StadiumBorder()),
                    onPressed: widget.busy ? null : submit,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add task'),
                  ),
                  if (details.priority != TaskPriority.medium)
                    Text('Priority: ${details.priority.name}'),
                  if (details.dueDate != null)
                    Text('Due: ${TaskDetails.dateLabel(details.dueDate!)}'),
                ],
              );
              if (constraints.maxWidth >= 700 &&
                  MediaQuery.textScalerOf(context).scale(14) <= 20) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: input),
                    const SizedBox(width: 20),
                    Flexible(child: actions),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [input, const SizedBox(height: 12), actions],
              );
            },
          ),
          const SizedBox(height: 8),
          ExpansionTile(
            key: ObjectKey(fields),
            controller: expansion,
            title: const Text('Task details (optional)'),
            maintainState: true,
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(top: 12, bottom: 8),
            children: [
              TaskDetailsFields(
                key: fields,
                initial: TaskDetails(),
                enabled: !widget.busy,
                onChanged: (value) {
                  setState(() => details = value);
                  widget.onDetailsChanged(value);
                },
                onDirtyChanged: widget.onDirtyChanged,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
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
  TaskDetails details = TaskDetails();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.line),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    ),
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
                onFieldSubmitted: (_) {
                  if (!widget.busy) widget.onSubmit();
                },
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
                    onPressed: widget.busy ? null : widget.onSubmit,
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

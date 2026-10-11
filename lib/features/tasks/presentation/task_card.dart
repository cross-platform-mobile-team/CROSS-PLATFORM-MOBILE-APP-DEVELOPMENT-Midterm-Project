import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/task_item.dart';
import '../domain/task_details.dart';

String taskDueLabel(TaskItem task, DateTime now) {
  final date = task.details.dueDate;
  if (date == null) return '';
  final today = DateTime(now.year, now.month, now.day);
  final prefix = !task.completed && date.isBefore(today)
      ? 'Overdue'
      : date == today
      ? 'Today'
      : date == DateTime(today.year, today.month, today.day + 1)
      ? 'Tomorrow'
      : 'Due';
  return '$prefix: ${TaskDetails.dateLabel(date)}';
}

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.now,
    required this.busy,
    this.activity,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });
  final TaskItem task;
  final DateTime now;
  final bool busy;
  final String? activity;
  final VoidCallback onToggle, onEdit, onDelete;
  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with AutomaticKeepAliveClientMixin {
  bool expanded = false;
  bool focused = false;
  @override
  bool get wantKeepAlive => expanded || focused;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final task = widget.task;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: (value) {
        focused = value;
        updateKeepAlive();
      },
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppTheme.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CheckboxListTile(
              value: task.completed,
              onChanged: widget.busy ? null : (_) => widget.onToggle(),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: task.completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Text(task.completed ? 'Completed' : 'Pending'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(
                    'Priority: ${task.details.priority.name}',
                    style: TextStyle(
                      color: task.details.priority == TaskPriority.high
                          ? const Color(0xFFAB263D)
                          : AppTheme.muted,
                    ),
                  ),
                  if (task.details.dueDate != null)
                    Text(taskDueLabel(task, widget.now)),
                  for (final tag in task.details.tags)
                    Semantics(
                      label: 'Tag: $tag',
                      excludeSemantics: true,
                      child: Text('#$tag'),
                    ),
                ],
              ),
            ),
            if (task.details.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.details.notes,
                      maxLines: expanded ? null : 2,
                      overflow: expanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => expanded = !expanded);
                        updateKeepAlive();
                      },
                      child: Text(expanded ? 'Show less' : 'Show more'),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Wrap(
                alignment: WrapAlignment.end,
                children: [
                  if (widget.activity != null)
                    Semantics(liveRegion: true, child: Text(widget.activity!)),
                  TextButton.icon(
                    onPressed: widget.busy ? null : widget.onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: widget.busy ? null : widget.onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

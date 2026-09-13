import 'package:flutter/material.dart';

import '../domain/task_details.dart';
import '../domain/task_filters.dart';

class TaskFilterDialog extends StatefulWidget {
  const TaskFilterDialog({super.key, required this.initial});
  final TaskFilters initial;
  @override
  State<TaskFilterDialog> createState() => _TaskFilterDialogState();
}

class _TaskFilterDialogState extends State<TaskFilterDialog> {
  late TaskStatusFilter status = widget.initial.status;
  late TaskPriority? priority = widget.initial.priority;
  late DueFilter due = widget.initial.due;
  late TaskSort sort = widget.initial.sort;
  late String tag = widget.initial.tag;

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(Icons.tune_rounded),
    title: const Text('Filter and sort'),
    content: SizedBox(
      width: 360,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            DropdownButtonFormField<TaskStatusFilter>(
              isExpanded: true,
              isDense: false,
              itemHeight: null,
              key: const Key('filter-status'),
              initialValue: status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: TaskStatusFilter.values
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.name)),
                  )
                  .toList(),
              onChanged: (item) => status = item!,
            ),
            DropdownButtonFormField<String>(
              isExpanded: true,
              isDense: false,
              itemHeight: null,
              key: const Key('filter-priority'),
              initialValue: priority?.name ?? 'all',
              decoration: const InputDecoration(labelText: 'Priority'),
              items: ['all', ...TaskPriority.values.map((item) => item.name)]
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (item) => priority = item == 'all'
                  ? null
                  : TaskPriority.values.byName(item!),
            ),
            DropdownButtonFormField<DueFilter>(
              isExpanded: true,
              isDense: false,
              itemHeight: null,
              key: const Key('filter-due'),
              initialValue: due,
              decoration: const InputDecoration(labelText: 'Due date'),
              items: DueFilter.values
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.name)),
                  )
                  .toList(),
              onChanged: (item) => due = item!,
            ),
            TextFormField(
              key: const Key('filter-tag'),
              initialValue: tag,
              decoration: const InputDecoration(labelText: 'Exact tag'),
              onChanged: (text) => tag = text,
            ),
            DropdownButtonFormField<TaskSort>(
              isExpanded: true,
              isDense: false,
              itemHeight: null,
              key: const Key('filter-sort'),
              initialValue: sort,
              decoration: const InputDecoration(labelText: 'Sort by'),
              items: TaskSort.values
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.name)),
                  )
                  .toList(),
              onChanged: (item) => sort = item!,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          TaskFilters(
            status: status,
            priority: priority,
            due: due,
            tag: tag,
            sort: sort,
          ),
        ),
        child: const Text('Apply'),
      ),
    ],
  );
}

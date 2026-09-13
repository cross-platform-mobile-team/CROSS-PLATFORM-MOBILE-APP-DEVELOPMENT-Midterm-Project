import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ui_components.dart';
import '../domain/task_filters.dart';

class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({
    super.key,
    required this.total,
    required this.completed,
    required this.selected,
    required this.onSelected,
    required this.online,
    this.actions = const [],
    this.temporary = false,
  });
  final int total;
  final int completed;
  final TaskStatusFilter selected;
  final ValueChanged<TaskStatusFilter> onSelected;
  final bool online;
  final List<Widget> actions;
  final bool temporary;

  @override
  Widget build(BuildContext context) => Container(
    width: 248,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: AppTheme.line)),
    ),
    child: LayoutBuilder(
      builder: (context, size) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BrandTitle(),
                  const SizedBox(height: 12),
                  Text(
                    online
                        ? 'ACCOUNT'
                        : temporary
                        ? 'SAMPLE'
                        : 'LOCAL',
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Padding(
                    padding: EdgeInsets.only(left: 12, bottom: 12),
                    child: Text(
                      'WORKSPACE',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 11,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  for (final item in [
                    (
                      TaskStatusFilter.all,
                      Icons.inbox_outlined,
                      'All tasks',
                      total,
                    ),
                    (
                      TaskStatusFilter.pending,
                      Icons.circle_outlined,
                      'To do',
                      total - completed,
                    ),
                    (
                      TaskStatusFilter.completed,
                      Icons.task_alt_rounded,
                      'Completed tasks',
                      completed,
                    ),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          selected: selected == item.$1,
                          selectedTileColor: const Color(0xFFEEF2FF),
                          selectedColor: AppTheme.accent,
                          hoverColor: const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          minLeadingWidth: 20,
                          horizontalTitleGap: 10,
                          leading: Icon(item.$2, size: 20),
                          title: Text(
                            item.$3,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Semantics(
                            label: '${item.$4} tasks',
                            child: ExcludeSemantics(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${item.$4}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.muted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () => onSelected(item.$1),
                        ),
                      ),
                    ),
                  const Spacer(),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFEEF2FF),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: AppTheme.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              online
                                  ? 'Account workspace'
                                  : temporary
                                  ? 'Sample workspace'
                                  : 'Local workspace',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              online
                                  ? 'Server-backed tasks'
                                  : temporary
                                  ? 'Session only · not saved'
                                  : 'Stored on this device',
                              style: const TextStyle(
                                color: AppTheme.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(spacing: 4, runSpacing: 4, children: actions),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class TaskHeader extends StatelessWidget {
  const TaskHeader({super.key, required this.total, required this.completed});
  final int total;
  final int completed;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR WORKSPACE',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
            color: AppTheme.muted,
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            'Focus on what matters today.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$completed/$total completed',
          style: const TextStyle(color: AppTheme.muted),
        ),
        const SizedBox(height: 12),
        Semantics(
          label: 'Task completion',
          value: '$completed of $total completed',
          child: SizedBox(
            width: 220,
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: ColoredBox(
                color: AppTheme.line,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    heightFactor: 1,
                    widthFactor: total == 0 ? 0 : completed / total,
                    child: const ColoredBox(color: AppTheme.accent),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key, required this.empty});
  final bool empty;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.line),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(
            empty ? Icons.inbox_outlined : Icons.search_off_rounded,
            color: AppTheme.accent,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          empty ? 'All clear for today' : 'No tasks in this view',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          empty
              ? 'No tasks yet. Add your first task above.'
              : 'No matching tasks.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.muted),
        ),
      ],
    ),
  );
}

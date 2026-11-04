import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.errorRed;
      case 'medium':
        return AppTheme.warningOrange;
      case 'low':
      default:
        return AppTheme.secondaryBlue;
    }
  }

  String _formatDueDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final priorityColor = _getPriorityColor(task.priority);

    return Card(
      elevation: task.isCompleted ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isCompleted
              ? (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))
              : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
        ),
      ),
      color: task.isCompleted
          ? (isDark ? const Color(0xFF151E2E) : const Color(0xFFF8FAFC))
          : (isDark ? theme.cardTheme.color : Colors.white),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Custom animated Checkbox
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: task.isCompleted,
                    activeColor: AppTheme.successGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onChanged: onToggleComplete,
                  ),
                ),
                const SizedBox(width: 8),

                // Task Title
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.isCompleted
                          ? (isDark ? Colors.white38 : Colors.grey.shade500)
                          : (isDark ? AppTheme.textLight : AppTheme.textDark),
                    ),
                  ),
                ),

                // Priority Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: task.isCompleted ? 0.08 : 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.priority,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: task.isCompleted
                          ? priorityColor.withValues(alpha: 0.5)
                          : priorityColor,
                    ),
                  ),
                ),
              ],
            ),

            // Optional Description
            if (task.description != null && task.description!.trim().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 48, right: 8, top: 2, bottom: 8),
                child: Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 6),
            const Divider(height: 1, thickness: 0.6),
            const SizedBox(height: 6),

            // Footer: Due Date chip, Edit and Delete buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Due: ${_formatDueDate(task.dueDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: AppTheme.secondaryBlue,
                      tooltip: 'Edit Task',
                      visualDensity: VisualDensity.compact,
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      color: AppTheme.errorRed,
                      tooltip: 'Delete Task',
                      visualDensity: VisualDensity.compact,
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../theme/app_theme.dart';

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDeadline(String dateStr) {
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
    final isSubmitted = assignment.status == 'Submitted';
    final isOverdue = assignment.isOverdue();

    return Card(
      elevation: isSubmitted ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isOverdue
              ? AppTheme.errorRed.withValues(alpha: 0.6)
              : isSubmitted
                  ? (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))
                  : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          width: isOverdue ? 1.5 : 1,
        ),
      ),
      color: isSubmitted
          ? (isDark ? const Color(0xFF151E2E) : const Color(0xFFF8FAFC))
          : (isDark ? theme.cardTheme.color : Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Subject Badge + Status / Overdue Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Subject Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    assignment.subject,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ),

                Row(
                  children: [
                    if (isOverdue) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 12, color: AppTheme.errorRed),
                            SizedBox(width: 4),
                            Text(
                              'OVERDUE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.errorRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSubmitted
                            ? AppTheme.successGreen.withValues(alpha: 0.15)
                            : AppTheme.warningOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        assignment.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSubmitted ? AppTheme.successGreen : AppTheme.warningOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Assignment Title
            Text(
              assignment.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: isSubmitted ? TextDecoration.lineThrough : null,
                color: isSubmitted
                    ? (isDark ? Colors.white38 : Colors.grey.shade500)
                    : (isDark ? AppTheme.textLight : AppTheme.textDark),
              ),
            ),

            // Description (Optional)
            if (assignment.description != null && assignment.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                assignment.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                  decoration: isSubmitted ? TextDecoration.lineThrough : null,
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.6),
            const SizedBox(height: 8),

            // Footer: Deadline & Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 15,
                      color: isOverdue ? AppTheme.errorRed : (isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Deadline: ${_formatDeadline(assignment.deadline)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOverdue
                            ? AppTheme.errorRed
                            : (isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Quick Toggle Button
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: Icon(
                        isSubmitted ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                        size: 16,
                        color: isSubmitted ? AppTheme.secondaryBlue : AppTheme.successGreen,
                      ),
                      label: Text(
                        isSubmitted ? 'Mark Pending' : 'Submit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSubmitted ? AppTheme.secondaryBlue : AppTheme.successGreen,
                        ),
                      ),
                      onPressed: onToggleStatus,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: AppTheme.secondaryBlue,
                      tooltip: 'Edit Assignment',
                      visualDensity: VisualDensity.compact,
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      color: AppTheme.errorRed,
                      tooltip: 'Delete Assignment',
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


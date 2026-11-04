import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exam.dart';
import '../theme/app_theme.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExamCard({
    super.key,
    required this.exam,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, dd MMMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final daysRemaining = exam.getDaysRemaining();

    // Determine Countdown Badge styling
    Color badgeColor;
    String badgeText;
    if (daysRemaining < 0) {
      badgeColor = Colors.grey;
      badgeText = 'Completed';
    } else if (daysRemaining == 0) {
      badgeColor = AppTheme.errorRed;
      badgeText = 'TODAY';
    } else if (daysRemaining == 1) {
      badgeColor = AppTheme.errorRed;
      badgeText = 'TOMORROW';
    } else if (daysRemaining <= 7) {
      badgeColor = AppTheme.warningOrange;
      badgeText = 'In $daysRemaining days';
    } else {
      badgeColor = AppTheme.secondaryBlue;
      badgeText = 'In $daysRemaining days';
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: daysRemaining <= 3 && daysRemaining >= 0
              ? AppTheme.errorRed.withValues(alpha: 0.5)
              : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          width: daysRemaining <= 3 && daysRemaining >= 0 ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Subject Title + Countdown Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exam.subject,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date and Time Chips
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, size: 14, color: AppTheme.secondaryBlue),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(exam.examDate),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: AppTheme.secondaryBlue),
                      const SizedBox(width: 6),
                      Text(
                        exam.examTime,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Optional Notes
            if (exam.notes != null && exam.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes_rounded, size: 15, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exam.notes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 0.6),
            const SizedBox(height: 6),

            // Footer: Edit & Delete buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: AppTheme.secondaryBlue,
                  tooltip: 'Edit Examination',
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: AppTheme.errorRed,
                  tooltip: 'Delete Examination',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


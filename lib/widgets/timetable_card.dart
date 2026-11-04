import 'package:flutter/material.dart';
import '../models/timetable.dart';
import '../theme/app_theme.dart';

class TimetableCard extends StatelessWidget {
  final Timetable timetable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TimetableCard({
    super.key,
    required this.timetable,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Time Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timetable.startTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'to',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timetable.endTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppTheme.secondaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Subject & Room Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timetable.subject,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.meeting_room_outlined,
                        size: 14,
                        color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timetable.room != null && timetable.room!.trim().isNotEmpty
                            ? timetable.room!
                            : 'Room TBA',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions: Edit & Delete
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: AppTheme.secondaryBlue,
                  tooltip: 'Edit Class',
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: AppTheme.errorRed,
                  tooltip: 'Delete Class',
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


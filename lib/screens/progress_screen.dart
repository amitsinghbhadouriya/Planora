import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/exam.dart';
import '../theme/app_theme.dart';
import '../widgets/summary_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  int _totalTasks = 0;
  int _completedTasks = 0;
  int _pendingTasks = 0;

  int _totalAssignments = 0;
  int _submittedAssignments = 0;
  int _pendingAssignments = 0;

  int _totalWeeklyClasses = 0;
  Exam? _nearestExam;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllStatistics();
  }

  Future<void> _loadAllStatistics() async {
    setState(() => _isLoading = true);

    final taskStats = await _dbHelper.getTaskStatistics();
    final assignStats = await _dbHelper.getAssignmentStatistics();
    final classes = await _dbHelper.getAllTimetable();
    final nextExam = await _dbHelper.getNextExam();

    if (mounted) {
      setState(() {
        _totalTasks = taskStats['total'] ?? 0;
        _completedTasks = taskStats['completed'] ?? 0;
        _pendingTasks = taskStats['pending'] ?? 0;

        _totalAssignments = assignStats['total'] ?? 0;
        _submittedAssignments = assignStats['submitted'] ?? 0;
        _pendingAssignments = assignStats['pending'] ?? 0;

        _totalWeeklyClasses = classes.length;
        _nearestExam = nextExam;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double taskCompletionRate =
        _totalTasks > 0 ? (_completedTasks / _totalTasks) : 0.0;
    final int taskPercent = (taskCompletionRate * 100).toInt();

    final double assignmentRate = _totalAssignments > 0
        ? (_submittedAssignments / _totalAssignments)
        : 0.0;
    final int assignmentPercent = (assignmentRate * 100).toInt();

    // Determine performance insight
    String insightTitle;
    String insightMessage;
    Color insightColor;
    IconData insightIcon;

    if (taskPercent >= 80) {
      insightTitle = 'Outstanding Performance! 🚀';
      insightMessage =
          'You are completing more than 80% of your tasks. Maintain this momentum for upcoming exams!';
      insightColor = AppTheme.successGreen;
      insightIcon = Icons.military_tech_rounded;
    } else if (taskPercent >= 50) {
      insightTitle = 'Steady Momentum 📈';
      insightMessage =
          'Good work on clearing tasks. Prioritize your pending assignments to boost completion rates.';
      insightColor = AppTheme.secondaryBlue;
      insightIcon = Icons.trending_up_rounded;
    } else {
      insightTitle = 'Focus Required 🎯';
      insightMessage =
          'You have $_pendingTasks pending tasks and $_pendingAssignments assignments due. Plan your study sessions!';
      insightColor = AppTheme.warningOrange;
      insightIcon = Icons.hourglass_top_rounded;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Progress & Analytics'),
        actions: [
          IconButton(
            tooltip: 'Recalculate Stats',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAllStatistics,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAllStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Big Circular Progress Metric Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Radial Gauge
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: CircularProgressIndicator(
                                    value: taskCompletionRate,
                                    strokeWidth: 9,
                                    backgroundColor: isDark
                                        ? Colors.white10
                                        : Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      taskPercent >= 80
                                          ? AppTheme.successGreen
                                          : taskPercent >= 50
                                              ? AppTheme.secondaryBlue
                                              : AppTheme.warningOrange,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$taskPercent%',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Task Completion Rate',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$_completedTasks of $_totalTasks academic tasks completed successfully.',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppTheme.textDarkSecondary
                                          : AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Motivational Performance Insight Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: insightColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: insightColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(insightIcon, color: insightColor, size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  insightTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: insightColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  insightMessage,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Detailed Metric Grid
                    Text(
                      'Task Breakdown',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.0,
                      children: [
                        SummaryCard(
                          title: 'Total',
                          value: '$_totalTasks',
                          icon: Icons.checklist_rounded,
                          color: AppTheme.primaryNavy,
                        ),
                        SummaryCard(
                          title: 'Done',
                          value: '$_completedTasks',
                          icon: Icons.check_circle_rounded,
                          color: AppTheme.successGreen,
                        ),
                        SummaryCard(
                          title: 'Pending',
                          value: '$_pendingTasks',
                          icon: Icons.pending_rounded,
                          color: AppTheme.warningOrange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Assignment Statistics Card
                    Text(
                      'Assignment Submission Ratio',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Assignments Submitted',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '$_submittedAssignments / $_totalAssignments ($assignmentPercent%)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.secondaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: assignmentRate,
                                minHeight: 8,
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.secondaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.successGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Submitted: $_submittedAssignments',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.warningOrange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Pending: $_pendingAssignments',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Weekly Timetable & Exam Insights
                    Text(
                      'Schedule & Exam Readiness',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Weekly Classes
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.secondaryBlue
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_month_rounded,
                                      color: AppTheme.secondaryBlue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '$_totalWeeklyClasses',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Classes / Week',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Upcoming Exam Card
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorRed
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.school_rounded,
                                      color: AppTheme.errorRed,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _nearestExam != null
                                        ? '${_nearestExam!.getDaysRemaining()}d left'
                                        : 'None',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.errorRed,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _nearestExam != null
                                        ? _nearestExam!.subject
                                        : 'No Exams Ahead',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}

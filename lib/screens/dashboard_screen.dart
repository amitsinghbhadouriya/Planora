import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../services/preferences_service.dart';
import '../models/assignment.dart';
import '../models/exam.dart';
import '../models/timetable.dart';
import '../widgets/summary_card.dart';
import '../widgets/quick_action_button.dart';
import 'exams_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigateTab;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final PreferencesService _prefs = PreferencesService.instance;

  String _studentName = 'Alex';
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _pendingTasks = 0;
  int _dueAssignments = 0;
  List<Timetable> _todayClasses = [];
  Assignment? _nextAssignment;
  Exam? _nextExam;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final name = await _prefs.getStudentName();
    final taskStats = await _dbHelper.getTaskStatistics();
    final assignStats = await _dbHelper.getAssignmentStatistics();
    
    // Determine today's day of week
    final dayOfWeek = DateFormat('EEEE').format(DateTime.now());
    final todaySchedule = await _dbHelper.getTimetableForDay(dayOfWeek);
    final upcomingAssignments = await _dbHelper.getUpcomingAssignments(limit: 1);
    final nextExam = await _dbHelper.getNextExam();

    if (mounted) {
      setState(() {
        _studentName = name;
        _totalTasks = taskStats['total'] ?? 0;
        _completedTasks = taskStats['completed'] ?? 0;
        _pendingTasks = taskStats['pending'] ?? 0;
        _dueAssignments = assignStats['pending'] ?? 0;
        _todayClasses = todaySchedule;
        _nextAssignment = upcomingAssignments.isNotEmpty ? upcomingAssignments.first : null;
        _nextExam = nextExam;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    final double progressPercent =
        _totalTasks > 0 ? (_completedTasks / _totalTasks) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Student Planner',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textLight : AppTheme.primaryNavy,
              ),
            ),
            Text(
              currentDate,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Dashboard',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            tooltip: 'Examinations',
            icon: const Icon(Icons.school_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExamsScreen()),
              ).then((_) => _loadDashboardData());
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onToggleTheme: widget.onToggleTheme,
                    isDarkMode: widget.isDarkMode,
                  ),
                ),
              ).then((_) => _loadDashboardData());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Greeting Header with Real Progress and Student Name
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryNavy, AppTheme.secondaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Student $_studentName 👋',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Overall Task Completion',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          '${(progressPercent * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Live Summary Metrics Grid
              Text(
                'Academic Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.35,
                children: [
                  SummaryCard(
                    title: 'Total Tasks',
                    value: '$_totalTasks',
                    subtitle: 'Recorded',
                    icon: Icons.checklist_rounded,
                    color: AppTheme.secondaryBlue,
                    onTap: () => widget.onNavigateTab(1),
                  ),
                  SummaryCard(
                    title: 'Completed',
                    value: '$_completedTasks',
                    subtitle: 'Done',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppTheme.successGreen,
                    onTap: () => widget.onNavigateTab(1),
                  ),
                  SummaryCard(
                    title: 'Pending Tasks',
                    value: '$_pendingTasks',
                    subtitle: 'To Do',
                    icon: Icons.pending_actions_rounded,
                    color: AppTheme.warningOrange,
                    onTap: () => widget.onNavigateTab(1),
                  ),
                  SummaryCard(
                    title: 'Due Assignments',
                    value: '$_dueAssignments',
                    subtitle: 'Deadlines',
                    icon: Icons.assignment_late_outlined,
                    color: AppTheme.errorRed,
                    onTap: () => widget.onNavigateTab(3),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    QuickActionButton(
                      label: 'New Task',
                      icon: Icons.add_task_rounded,
                      color: AppTheme.primaryNavy,
                      onTap: () => widget.onNavigateTab(1),
                    ),
                    const SizedBox(width: 10),
                    QuickActionButton(
                      label: 'Add Class',
                      icon: Icons.add_alarm_rounded,
                      color: AppTheme.secondaryBlue,
                      onTap: () => widget.onNavigateTab(2),
                    ),
                    const SizedBox(width: 10),
                    QuickActionButton(
                      label: 'Add Assignment',
                      icon: Icons.post_add_rounded,
                      color: AppTheme.warningOrange,
                      onTap: () => widget.onNavigateTab(3),
                    ),
                    const SizedBox(width: 10),
                    QuickActionButton(
                      label: 'Add Exam',
                      icon: Icons.note_add_rounded,
                      color: AppTheme.errorRed,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ExamsScreen()),
                        ).then((_) => _loadDashboardData());
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Today's Timetable Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Schedule",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigateTab(2),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_todayClasses.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded, color: AppTheme.successGreen),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'No scheduled classes for today! Enjoy your self-study time.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: () => widget.onNavigateTab(2),
                          child: const Text('Add Class'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _todayClasses.first.startTime,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _todayClasses.first.subject,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _todayClasses.first.room ?? 'Main Campus',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Upcoming Deadlines Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Assignments',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigateTab(3),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_nextAssignment == null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: AppTheme.successGreen),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'All caught up! No pending assignments.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: () => widget.onNavigateTab(3),
                          child: const Text('Add Assignment'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.assignment_outlined, color: AppTheme.errorRed, size: 20),
                    ),
                    title: Text(
                      _nextAssignment!.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text('Due: ${_nextAssignment!.deadline} • ${_nextAssignment!.subject}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warningOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Pending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warningOrange,
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Examination Alert Banner
              Card(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school_rounded, color: AppTheme.primaryNavy),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nextExam != null
                                  ? '${_nextExam!.subject} (${_nextExam!.getDaysRemaining()} days left)'
                                  : 'No upcoming examinations',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _nextExam != null
                                  ? 'Exam Date: ${_nextExam!.examDate} at ${_nextExam!.examTime}'
                                  : 'Add exam schedules to track revision countdowns',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ExamsScreen()),
                          ).then((_) => _loadDashboardData());
                        },
                        child: const Text('Planner'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

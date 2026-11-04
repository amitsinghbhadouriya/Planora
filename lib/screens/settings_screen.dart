import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/notification_service.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const SettingsScreen({
    super.key,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefs = PreferencesService.instance;
  final NotificationService _notifications = NotificationService.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String _studentName = 'Alex';
  bool _notifyTasks = true;
  bool _notifyAssignments = true;
  bool _notifyExams = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final name = await _prefs.getStudentName();
    final tasks = await _prefs.getNotifyTasks();
    final assigns = await _prefs.getNotifyAssignments();
    final exams = await _prefs.getNotifyExams();

    if (mounted) {
      setState(() {
        _studentName = name;
        _notifyTasks = tasks;
        _notifyAssignments = assigns;
        _notifyExams = exams;
        _isLoading = false;
      });
    }
  }

  // Edit Student Name Dialog
  Future<void> _showEditNameDialog() async {
    final controller = TextEditingController(text: _studentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Student Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Student Name',
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await _prefs.setStudentName(newName);
      setState(() => _studentName = newName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Name updated to "$newName"'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Clear All Data Confirmation
  Future<void> _confirmClearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Planner Data?'),
        content: const Text(
          'Warning: This action will permanently erase all SQLite database records: tasks, timetable classes, assignments, and exam schedules. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Erase All Data'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.clearAllData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All SQLite records cleared successfully'),
            backgroundColor: AppTheme.errorRed,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Seed Sample College Data
  Future<void> _confirmSeedSampleData() async {
    await _dbHelper.seedInitialSampleData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loaded sample BCA tasks, lectures & exams into SQLite!'),
          backgroundColor: AppTheme.secondaryBlue,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Trigger Instant Test Notification
  Future<void> _triggerTestNotification() async {
    await _notifications.requestPermissions();
    await _notifications.showInstantNotification(
      id: 999,
      title: 'Smart Student Planner 🔔',
      body: 'Notifications are working! You will receive study reminders here.',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent to system tray!'),
          backgroundColor: AppTheme.primaryNavy,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Section: Student Profile
                _buildSectionHeader('STUDENT PROFILE'),
                Card(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded, color: AppTheme.primaryNavy),
                    ),
                    title: Text(
                      _studentName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: const Text('Active Student Profile'),
                    trailing: OutlinedButton(
                      onPressed: _showEditNameDialog,
                      child: const Text('Edit'),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Section: Appearance
                _buildSectionHeader('APPEARANCE'),
                Card(
                  child: SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.secondaryBlue.withValues(alpha: 0.2)
                            : Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: isDark ? AppTheme.secondaryBlue : Colors.amber.shade800,
                      ),
                    ),
                    title: const Text(
                      'Dark Theme',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      isDark ? 'Slate Navy Dark Mode' : 'Clean Modern Light Mode',
                    ),
                    value: isDark,
                    onChanged: (val) {
                      if (widget.onToggleTheme != null) {
                        widget.onToggleTheme!();
                      }
                      _prefs.setIsDarkMode(val);
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Section: Reminders & Notifications
                _buildSectionHeader('NOTIFICATIONS & ALERTS'),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.task_alt_rounded, color: AppTheme.primaryNavy),
                        title: const Text('Task Reminders'),
                        subtitle: const Text('Alert on upcoming daily tasks'),
                        value: _notifyTasks,
                        onChanged: (val) {
                          setState(() => _notifyTasks = val);
                          _prefs.setNotifyTasks(val);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.assignment_outlined, color: AppTheme.warningOrange),
                        title: const Text('Assignment Deadlines'),
                        subtitle: const Text('Alert 24 hours before submission'),
                        value: _notifyAssignments,
                        onChanged: (val) {
                          setState(() => _notifyAssignments = val);
                          _prefs.setNotifyAssignments(val);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.school_rounded, color: AppTheme.errorRed),
                        title: const Text('Examination Countdowns'),
                        subtitle: const Text('Reminders for approaching finals'),
                        value: _notifyExams,
                        onChanged: (val) {
                          setState(() => _notifyExams = val);
                          _prefs.setNotifyExams(val);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications_active_outlined, color: AppTheme.secondaryBlue),
                        title: const Text('Send Test Notification'),
                        subtitle: const Text('Verify system tray alerts and sound'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _triggerTestNotification,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section: Database Management
                _buildSectionHeader('DATABASE MANAGEMENT'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.cloud_download_outlined, color: AppTheme.secondaryBlue),
                        title: const Text('Load Demo College Data'),
                        subtitle: const Text('Populate realistic tasks, timetable, and exams for viva demo'),
                        onTap: _confirmSeedSampleData,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.delete_forever_rounded, color: AppTheme.errorRed),
                        title: const Text(
                          'Clear All Data',
                          style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('Permanently erase all local SQLite database tables'),
                        onTap: _confirmClearAllData,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section: About App
                _buildSectionHeader('APPLICATION INFO'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryNavy.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.school_rounded, color: AppTheme.primaryNavy),
                            ),
                            const SizedBox(width: 14),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Smart Student Planner',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Version 1.0.0 (Release Build)',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        const Text(
                          'An offline-first academic management system developed using Flutter, Dart, and SQLite (sqflite). Designed for college students to manage tasks, assignments, lecture timetables, and exam revision with zero cloud dependency.',
                          style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Icon(Icons.verified_user_outlined, size: 16, color: AppTheme.successGreen),
                            SizedBox(width: 6),
                            Text(
                              'Offline SQLite Storage • 100% Private',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.textDarkSecondary
              : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

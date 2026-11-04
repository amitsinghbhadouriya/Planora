class AppConstants {
  // App Details
  static const String appName = 'Smart Student Planner';
  static const String appVersion = '1.0.0';
  static const String defaultStudentName = 'Alex';

  // Database Constants
  static const String dbName = 'smart_student_planner.db';
  static const int dbVersion = 1;

  // Task Priorities
  static const String priorityHigh = 'High';
  static const String priorityMedium = 'Medium';
  static const String priorityLow = 'Low';
  static const List<String> priorities = [priorityHigh, priorityMedium, priorityLow];

  // Assignment Statuses
  static const String statusPending = 'Pending';
  static const String statusSubmitted = 'Submitted';

  // Weekly Schedule Days
  static const List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  // Notification Channel
  static const String notificationChannelId = 'student_planner_channel';
  static const String notificationChannelName = 'Academic Reminders';
  static const String notificationChannelDesc =
      'Reminders for deadlines, classes, and examinations';
}

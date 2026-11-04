import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyStudentName = 'student_name';
  static const String _keyIsDarkMode = 'is_dark_mode';
  static const String _keyNotifyTasks = 'notify_tasks';
  static const String _keyNotifyAssignments = 'notify_assignments';
  static const String _keyNotifyExams = 'notify_exams';

  // Singleton instance
  static final PreferencesService instance = PreferencesService._init();
  PreferencesService._init();

  Future<String> getStudentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStudentName) ?? 'Alex';
  }

  Future<void> setStudentName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStudentName, name.trim().isEmpty ? 'Alex' : name.trim());
  }

  Future<bool> getIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDarkMode) ?? false;
  }

  Future<void> setIsDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDarkMode, isDark);
  }

  Future<bool> getNotifyTasks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifyTasks) ?? true;
  }

  Future<void> setNotifyTasks(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyTasks, enabled);
  }

  Future<bool> getNotifyAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifyAssignments) ?? true;
  }

  Future<void> setNotifyAssignments(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyAssignments, enabled);
  }

  Future<bool> getNotifyExams() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifyExams) ?? true;
  }

  Future<void> setNotifyExams(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyExams, enabled);
  }
}


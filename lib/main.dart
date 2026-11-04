import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
import 'services/preferences_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline local notifications
  await NotificationService.instance.initialize();

  // Load saved theme preference
  final isDark = await PreferencesService.instance.getIsDarkMode();

  runApp(SmartStudentPlannerApp(initialDarkMode: isDark));
}

class SmartStudentPlannerApp extends StatefulWidget {
  final bool initialDarkMode;

  const SmartStudentPlannerApp({
    super.key,
    this.initialDarkMode = false,
  });

  @override
  State<SmartStudentPlannerApp> createState() => _SmartStudentPlannerAppState();
}

class _SmartStudentPlannerAppState extends State<SmartStudentPlannerApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Student Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: MainNavigationScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

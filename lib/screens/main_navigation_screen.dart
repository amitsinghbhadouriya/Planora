import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'tasks_screen.dart';
import 'timetable_screen.dart';
import 'assignments_screen.dart';
import 'progress_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const MainNavigationScreen({
    super.key,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // IndexedStack preserves the state of all tabs so that form inputs,
    // scroll positions, and states are not lost when switching tabs.
    final List<Widget> screens = [
      DashboardScreen(
        onNavigateTab: _onTabSelected,
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
      const TasksScreen(),
      const TimetableScreen(),
      const AssignmentsScreen(),
      const ProgressScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
      ),
    );
  }
}


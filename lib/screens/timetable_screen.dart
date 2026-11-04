import 'package:flutter/material.dart';
import '../models/timetable.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/timetable_card.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final List<String> _daysOfWeek = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  late TabController _tabController;
  int _selectedDayIndex = 0;
  List<Timetable> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Default to today if Monday-Saturday, otherwise Monday
    final today = DateTime.now().weekday; // 1 = Monday, 6 = Saturday, 7 = Sunday
    _selectedDayIndex = (today >= 1 && today <= 6) ? today - 1 : 0;

    _tabController = TabController(
      length: _daysOfWeek.length,
      vsync: this,
      initialIndex: _selectedDayIndex,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedDayIndex = _tabController.index;
        });
        _loadClasses();
      }
    });

    _loadClasses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    final day = _daysOfWeek[_selectedDayIndex];
    final classes = await _dbHelper.getTimetableForDay(day);

    setState(() {
      _classes = classes;
      _isLoading = false;
    });
  }

  // Delete Class with Confirmation Dialog
  Future<void> _confirmDeleteClass(Timetable item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class?'),
        content: Text(
          'Are you sure you want to remove "${item.subject}" from ${item.day}\'s timetable?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && item.id != null) {
      await _dbHelper.deleteTimetable(item.id!);
      _loadClasses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class deleted from timetable'),
            backgroundColor: AppTheme.errorRed,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Helper to parse "HH:mm AM/PM" or "09:30 AM" into TimeOfDay
  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.trim().split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (parts.length > 1) {
        final period = parts[1].toUpperCase();
        if (period == 'PM' && hour < 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  // Add / Edit Class Bottom Sheet Modal
  void _showClassFormDialog({Timetable? classToEdit}) {
    final isEditing = classToEdit != null;
    final formKey = GlobalKey<FormState>();

    final subjectController =
        TextEditingController(text: classToEdit?.subject ?? '');
    final roomController =
        TextEditingController(text: classToEdit?.room ?? '');
    String selectedDay = classToEdit?.day ?? _daysOfWeek[_selectedDayIndex];

    TimeOfDay startTime = classToEdit != null
        ? _parseTime(classToEdit.startTime)
        : const TimeOfDay(hour: 9, minute: 30);

    TimeOfDay endTime = classToEdit != null
        ? _parseTime(classToEdit.endTime)
        : const TimeOfDay(hour: 10, minute: 30);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEditing ? 'Edit Class Schedule' : 'Add New Class',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const Divider(height: 16),

                      // Subject Name Input
                      TextFormField(
                        controller: subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Subject Name *',
                          hintText: 'e.g. Database Management Systems',
                          prefixIcon: Icon(Icons.menu_book_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Subject name cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Classroom / Lab Room Input
                      TextFormField(
                        controller: roomController,
                        decoration: const InputDecoration(
                          labelText: 'Classroom / Lab (Optional)',
                          hintText: 'e.g. Room 304 or Computer Lab 2',
                          prefixIcon: Icon(Icons.meeting_room_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Day Selector Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedDay,
                        decoration: const InputDecoration(
                          labelText: 'Day of the Week',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                        items: _daysOfWeek.map((day) {
                          return DropdownMenuItem<String>(
                            value: day,
                            child: Text(day),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedDay = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Time Selection Pickers
                      Row(
                        children: [
                          // Start Time Picker
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start Time',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: startTime,
                                    );
                                    if (picked != null) {
                                      setModalState(() => startTime = picked);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: isDark
                                          ? const Color(0xFF0F172A)
                                          : Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          startTime.format(context),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.access_time_rounded,
                                          size: 18,
                                          color: AppTheme.secondaryBlue,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // End Time Picker
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'End Time',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: endTime,
                                    );
                                    if (picked != null) {
                                      setModalState(() => endTime = picked);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: isDark
                                          ? const Color(0xFF0F172A)
                                          : Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          endTime.format(context),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.access_time_filled_rounded,
                                          size: 18,
                                          color: AppTheme.secondaryBlue,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Submit Button with Strict Time Chronology Validation
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            // Validate that end time is later than start time
                            final startMinutes = startTime.hour * 60 + startTime.minute;
                            final endMinutes = endTime.hour * 60 + endTime.minute;

                            if (endMinutes <= startMinutes) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Invalid Time: Class ending time must be later than starting time.',
                                  ),
                                  backgroundColor: AppTheme.errorRed,
                                  duration: Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            final formattedStart = startTime.format(context);
                            final formattedEnd = endTime.format(context);

                            if (isEditing) {
                              final updated = classToEdit.copyWith(
                                subject: subjectController.text.trim(),
                                room: roomController.text.trim().isEmpty
                                    ? null
                                    : roomController.text.trim(),
                                day: selectedDay,
                                startTime: formattedStart,
                                endTime: formattedEnd,
                              );
                              await _dbHelper.updateTimetable(updated);
                            } else {
                              final newClass = Timetable(
                                subject: subjectController.text.trim(),
                                room: roomController.text.trim().isEmpty
                                    ? null
                                    : roomController.text.trim(),
                                day: selectedDay,
                                startTime: formattedStart,
                                endTime: formattedEnd,
                              );
                              await _dbHelper.insertTimetable(newClass);
                            }

                            if (ctx.mounted) Navigator.pop(ctx);

                            // Switch to the target day if changed
                            final targetIndex = _daysOfWeek.indexOf(selectedDay);
                            if (targetIndex != -1 && targetIndex != _selectedDayIndex) {
                              _tabController.animateTo(targetIndex);
                            } else {
                              _loadClasses();
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing
                                        ? 'Class schedule updated!'
                                        : 'Class added to timetable!',
                                  ),
                                  backgroundColor: AppTheme.successGreen,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Text(
                            isEditing ? 'Save Changes' : 'Add Class',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Timetable'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppTheme.primaryNavy,
          labelColor: AppTheme.primaryNavy,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _daysOfWeek.map((day) => Tab(text: day)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClassFormDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Class'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadClasses,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: _classes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _classes[index];
                      return TimetableCard(
                        timetable: item,
                        onEdit: () => _showClassFormDialog(classToEdit: item),
                        onDelete: () => _confirmDeleteClass(item),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    final currentDay = _daysOfWeek[_selectedDayIndex];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 64,
                color: AppTheme.secondaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Classes on $currentDay',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No lecture schedules found for $currentDay. Tap "+ Add Class" to add a course, subject, or lab session.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

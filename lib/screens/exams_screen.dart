import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exam.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/exam_card.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Exam> _exams = [];
  bool _isLoading = true;
  bool _upcomingOnly = false;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() => _isLoading = true);
    final exams = await _dbHelper.getAllExams(upcomingOnly: _upcomingOnly);

    setState(() {
      _exams = exams;
      _isLoading = false;
    });
  }

  // Delete Exam with Confirmation
  Future<void> _confirmDeleteExam(Exam exam) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Exam?'),
        content: Text(
          'Are you sure you want to remove "${exam.subject}" from your exam planner?',
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

    if (confirmed == true && exam.id != null) {
      await _dbHelper.deleteExam(exam.id!);
      _loadExams();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exam schedule removed'),
            backgroundColor: AppTheme.errorRed,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Parse time string to TimeOfDay
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
      return const TimeOfDay(hour: 10, minute: 0);
    }
  }

  // Add / Edit Exam Modal Bottom Sheet
  void _showExamFormDialog({Exam? examToEdit}) {
    final isEditing = examToEdit != null;
    final formKey = GlobalKey<FormState>();

    final subjectController = TextEditingController(text: examToEdit?.subject ?? '');
    final notesController = TextEditingController(text: examToEdit?.notes ?? '');

    DateTime selectedDate = examToEdit != null
        ? DateTime.tryParse(examToEdit.examDate) ?? DateTime.now()
        : DateTime.now().add(const Duration(days: 14));

    TimeOfDay selectedTime = examToEdit != null
        ? _parseTime(examToEdit.examTime)
        : const TimeOfDay(hour: 10, minute: 0);

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
                            isEditing ? 'Edit Examination' : 'Schedule Examination',
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

                      // Subject Name
                      TextFormField(
                        controller: subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Subject / Course Title *',
                          hintText: 'e.g. Operating Systems Final Theory',
                          prefixIcon: Icon(Icons.school_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Subject title cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date & Time Pickers
                      Row(
                        children: [
                          // Date Picker
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Exam Date',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime(2024),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      setModalState(() => selectedDate = picked);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      borderRadius: BorderRadius.circular(12),
                                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('dd MMM yyyy').format(selectedDate),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 16,
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

                          // Time Picker
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Exam Time',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: selectedTime,
                                    );
                                    if (picked != null) {
                                      setModalState(() => selectedTime = picked);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      borderRadius: BorderRadius.circular(12),
                                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedTime.format(context),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Notes / Syllabus Units Input
                      TextFormField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Syllabus Notes / Hall Location (Optional)',
                          hintText: 'e.g. Units 1–4, Room 102. Bring Hall Ticket & Scientific Calculator',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final formattedDate = selectedDate.toIso8601String().split('T').first;
                            final formattedTime = selectedTime.format(context);

                            if (isEditing) {
                              final updated = examToEdit.copyWith(
                                subject: subjectController.text.trim(),
                                examDate: formattedDate,
                                examTime: formattedTime,
                                notes: notesController.text.trim().isEmpty
                                    ? null
                                    : notesController.text.trim(),
                              );
                              await _dbHelper.updateExam(updated);
                            } else {
                              final newExam = Exam(
                                subject: subjectController.text.trim(),
                                examDate: formattedDate,
                                examTime: formattedTime,
                                notes: notesController.text.trim().isEmpty
                                    ? null
                                    : notesController.text.trim(),
                              );
                              await _dbHelper.insertExam(newExam);
                            }

                            if (ctx.mounted) Navigator.pop(ctx);
                            _loadExams();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing
                                        ? 'Examination updated successfully'
                                        : 'Examination scheduled successfully',
                                  ),
                                  backgroundColor: AppTheme.successGreen,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Text(
                            isEditing ? 'Save Changes' : 'Schedule Exam',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        title: const Text('Examination Planner'),
        actions: [
          Row(
            children: [
              Text(
                _upcomingOnly ? 'Upcoming' : 'All Exams',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              IconButton(
                tooltip: _upcomingOnly ? 'Show All Exams' : 'Show Upcoming Only',
                icon: Icon(
                  _upcomingOnly ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
                  color: _upcomingOnly ? AppTheme.primaryNavy : null,
                ),
                onPressed: () {
                  setState(() => _upcomingOnly = !_upcomingOnly);
                  _loadExams();
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExamFormDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Exam'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exams.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadExams,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: _exams.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final exam = _exams[index];
                      return ExamCard(
                        exam: exam,
                        onEdit: () => _showExamFormDialog(examToEdit: exam),
                        onDelete: () => _confirmDeleteExam(exam),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 64,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _upcomingOnly ? 'No Upcoming Exams' : 'No Exams Scheduled',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _upcomingOnly
                  ? 'All scheduled exams have already taken place.'
                  : 'Tap "+ Add Exam" below to track mid-terms, practicals, and semester finals.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

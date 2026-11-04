import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/assignment_card.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Assignment> _assignments = [];
  bool _isLoading = true;

  // Filter states
  String _statusFilter = 'All'; // 'All', 'Pending', 'Submitted'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    setState(() => _isLoading = true);

    final assignments = await _dbHelper.getAllAssignments(
      status: _statusFilter == 'All' ? null : _statusFilter,
      searchQuery: _searchQuery,
    );

    setState(() {
      _assignments = assignments;
      _isLoading = false;
    });
  }

  // Toggle Submission Status
  Future<void> _toggleAssignmentStatus(Assignment assignment) async {
    if (assignment.id == null) return;
    await _dbHelper.toggleAssignmentStatus(assignment.id!, assignment.status);
    _loadAssignments();

    final isNowSubmitted = assignment.status == 'Pending';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNowSubmitted
                ? 'Assignment marked as submitted! 🎉'
                : 'Assignment moved back to pending',
          ),
          backgroundColor:
              isNowSubmitted ? AppTheme.successGreen : AppTheme.secondaryBlue,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Delete Assignment with Confirmation
  Future<void> _confirmDeleteAssignment(Assignment assignment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Assignment?'),
        content: Text(
          'Are you sure you want to delete "${assignment.title}"? This cannot be undone.',
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

    if (confirmed == true && assignment.id != null) {
      await _dbHelper.deleteAssignment(assignment.id!);
      _loadAssignments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment deleted successfully'),
            backgroundColor: AppTheme.errorRed,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Add / Edit Assignment Bottom Sheet
  void _showAssignmentFormDialog({Assignment? assignmentToEdit}) {
    final isEditing = assignmentToEdit != null;
    final formKey = GlobalKey<FormState>();

    final titleController =
        TextEditingController(text: assignmentToEdit?.title ?? '');
    final subjectController =
        TextEditingController(text: assignmentToEdit?.subject ?? '');
    final descController =
        TextEditingController(text: assignmentToEdit?.description ?? '');
    String selectedStatus = assignmentToEdit?.status ?? 'Pending';

    DateTime selectedDeadline = assignmentToEdit != null
        ? DateTime.tryParse(assignmentToEdit.deadline) ?? DateTime.now()
        : DateTime.now().add(const Duration(days: 3));

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
                            isEditing ? 'Edit Assignment' : 'New Assignment',
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

                      // Assignment Title
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Assignment Title *',
                          hintText: 'e.g. Data Structures Binary Trees Project',
                          prefixIcon: Icon(Icons.assignment_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Assignment title cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Subject Name
                      TextFormField(
                        controller: subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Course / Subject Name *',
                          hintText: 'e.g. Data Structures & Algorithms',
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

                      // Description
                      TextFormField(
                        controller: descController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Instructions / Requirements (Optional)',
                          hintText: 'e.g. Include source code, diagrams and viva report',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Submission Deadline Picker
                      const Text(
                        'Submission Deadline',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDeadline,
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDeadline = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event_available_rounded, color: AppTheme.secondaryBlue),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('EEEE, dd MMMM yyyy').format(selectedDeadline),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              const Text('Change', style: TextStyle(color: AppTheme.secondaryBlue)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Status Selection (Pending vs Submitted)
                      const Text(
                        'Submission Status',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Pending', 'Submitted'].map((status) {
                          final isSelected = selectedStatus == status;
                          final color = status == 'Submitted'
                              ? AppTheme.successGreen
                              : AppTheme.warningOrange;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(status),
                              selected: isSelected,
                              selectedColor: color.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color: isSelected ? color : null,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: isSelected ? color : Colors.grey.shade300,
                              ),
                              onSelected: (val) {
                                if (val) {
                                  setModalState(() => selectedStatus = status);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final formattedDeadline =
                                selectedDeadline.toIso8601String().split('T').first;
                            final todayStr =
                                DateTime.now().toIso8601String().split('T').first;

                            if (isEditing) {
                              final updated = assignmentToEdit.copyWith(
                                title: titleController.text.trim(),
                                subject: subjectController.text.trim(),
                                description: descController.text.trim().isEmpty
                                    ? null
                                    : descController.text.trim(),
                                deadline: formattedDeadline,
                                status: selectedStatus,
                              );
                              await _dbHelper.updateAssignment(updated);
                            } else {
                              final newAssignment = Assignment(
                                title: titleController.text.trim(),
                                subject: subjectController.text.trim(),
                                description: descController.text.trim().isEmpty
                                    ? null
                                    : descController.text.trim(),
                                deadline: formattedDeadline,
                                status: selectedStatus,
                                createdAt: todayStr,
                              );
                              await _dbHelper.insertAssignment(newAssignment);
                            }

                            if (ctx.mounted) Navigator.pop(ctx);
                            _loadAssignments();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing
                                        ? 'Assignment updated successfully'
                                        : 'Assignment created successfully',
                                  ),
                                  backgroundColor: AppTheme.successGreen,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Text(
                            isEditing ? 'Save Changes' : 'Create Assignment',
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
        title: const Text('Assignments Tracker'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAssignmentFormDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Assignment'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title, subject, or notes...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _loadAssignments();
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
                _loadAssignments();
              },
            ),
          ),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ['All', 'Pending', 'Submitted'].map((status) {
                final isSelected = _statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryNavy.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppTheme.primaryNavy : null,
                    ),
                    onSelected: (val) {
                      setState(() => _statusFilter = status);
                      _loadAssignments();
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 6),

          // Assignments List / Empty / Loading State
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _assignments.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadAssignments,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: _assignments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final assignment = _assignments[index];
                            return AssignmentCard(
                              assignment: assignment,
                              onToggleStatus: () =>
                                  _toggleAssignmentStatus(assignment),
                              onEdit: () => _showAssignmentFormDialog(
                                assignmentToEdit: assignment,
                              ),
                              onDelete: () =>
                                  _confirmDeleteAssignment(assignment),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasActiveFilter = _searchQuery.isNotEmpty || _statusFilter != 'All';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.warningOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in_rounded,
                size: 64,
                color: AppTheme.warningOrange,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasActiveFilter ? 'No matching assignments' : 'No assignments found',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilter
                  ? 'Try clearing your search query or changing filter chips.'
                  : 'Tap "+ Add Assignment" below to track homework, lab reports, and deadlines.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

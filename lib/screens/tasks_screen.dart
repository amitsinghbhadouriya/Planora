import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Task> _tasks = [];
  bool _isLoading = true;

  // Filter & Search states
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Pending', 'Completed'
  String _priorityFilter = 'All'; // 'All', 'High', 'Medium', 'Low'
  String _sortOrder = 'ASC'; // 'ASC' or 'DESC'

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    int? completedParam;
    if (_statusFilter == 'Pending') completedParam = 0;
    if (_statusFilter == 'Completed') completedParam = 1;

    final tasks = await _dbHelper.getAllTasks(
      priority: _priorityFilter == 'All' ? null : _priorityFilter,
      isCompleted: completedParam,
      searchQuery: _searchQuery,
      sortByDeadline: _sortOrder,
    );

    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  // Toggle Completion Status
  Future<void> _toggleTaskStatus(Task task) async {
    final newStatus = !task.isCompleted;
    await _dbHelper.toggleTaskStatus(task.id!, newStatus);
    _loadTasks();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'Marked task as completed! 🎉' : 'Marked task as pending',
          ),
          backgroundColor: newStatus ? AppTheme.successGreen : AppTheme.secondaryBlue,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Delete Task with Confirmation Dialog
  Future<void> _confirmDeleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This cannot be undone.',
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

    if (confirmed == true && task.id != null) {
      await _dbHelper.deleteTask(task.id!);
      _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted successfully'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Show Add / Edit Modal Bottom Sheet
  void _showTaskFormDialog({Task? taskToEdit}) {
    final isEditing = taskToEdit != null;
    final formKey = GlobalKey<FormState>();

    final titleController = TextEditingController(text: taskToEdit?.title ?? '');
    final descController = TextEditingController(text: taskToEdit?.description ?? '');
    String selectedPriority = taskToEdit?.priority ?? 'Medium';
    DateTime selectedDate = taskToEdit != null
        ? DateTime.tryParse(taskToEdit.dueDate) ?? DateTime.now()
        : DateTime.now().add(const Duration(days: 1));

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
                            isEditing ? 'Edit Task' : 'Create New Task',
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

                      // Task Title Input
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task Title *',
                          hintText: 'e.g. Complete Operating Systems Lab',
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Task title cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Task Description Input
                      TextFormField(
                        controller: descController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Add notes, textbook references, or sub-tasks',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Priority Selection
                      const Text(
                        'Priority Level',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Low', 'Medium', 'High'].map((priority) {
                          final isSelected = selectedPriority == priority;
                          Color color;
                          if (priority == 'High') {
                            color = AppTheme.errorRed;
                          } else if (priority == 'Medium') {
                            color = AppTheme.warningOrange;
                          } else {
                            color = AppTheme.secondaryBlue;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(priority),
                              selected: isSelected,
                              selectedColor: color.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color: isSelected ? color : (isDark ? Colors.white70 : Colors.black87),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: isSelected ? color : Colors.grey.shade300,
                              ),
                              onSelected: (val) {
                                if (val) {
                                  setModalState(() => selectedPriority = priority);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Due Date Picker
                      const Text(
                        'Due Date',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, color: AppTheme.secondaryBlue),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('EEEE, dd MMMM yyyy').format(selectedDate),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              const Text('Change', style: TextStyle(color: AppTheme.secondaryBlue)),
                            ],
                          ),
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
                            final todayStr = DateTime.now().toIso8601String().split('T').first;

                            if (isEditing) {
                              final updated = taskToEdit.copyWith(
                                title: titleController.text.trim(),
                                description: descController.text.trim().isEmpty
                                    ? null
                                    : descController.text.trim(),
                                priority: selectedPriority,
                                dueDate: formattedDate,
                              );
                              await _dbHelper.updateTask(updated);
                            } else {
                              final newTask = Task(
                                title: titleController.text.trim(),
                                description: descController.text.trim().isEmpty
                                    ? null
                                    : descController.text.trim(),
                                priority: selectedPriority,
                                dueDate: formattedDate,
                                isCompleted: false,
                                createdAt: todayStr,
                              );
                              await _dbHelper.insertTask(newTask);
                            }

                            if (ctx.mounted) Navigator.pop(ctx);
                            _loadTasks();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing
                                        ? 'Task updated successfully'
                                        : 'Task created successfully',
                                  ),
                                  backgroundColor: AppTheme.successGreen,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Text(
                            isEditing ? 'Save Changes' : 'Create Task',
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks & Deadlines'),
        actions: [
          // Sort Toggle Button
          IconButton(
            tooltip: _sortOrder == 'ASC' ? 'Sort by Deadline (Earliest)' : 'Sort by Deadline (Latest)',
            icon: Icon(
              _sortOrder == 'ASC' ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            ),
            onPressed: () {
              setState(() {
                _sortOrder = _sortOrder == 'ASC' ? 'DESC' : 'ASC';
              });
              _loadTasks();
            },
          ),
          // Seed Sample Data Button (Helpful for Live Classroom Demo)
          IconButton(
            tooltip: 'Load Sample Tasks',
            icon: const Icon(Icons.playlist_add_rounded),
            onPressed: () async {
              await _dbHelper.seedInitialSampleData();
              _loadTasks();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Loaded sample college tasks into SQLite!'),
                    backgroundColor: AppTheme.secondaryBlue,
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskFormDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks by title or notes...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _loadTasks();
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
                _loadTasks();
              },
            ),
          ),

          // Status & Priority Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // Status Filter Chips
                ...['All', 'Pending', 'Completed'].map((status) {
                  final isSelected = _statusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryNavy.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppTheme.primaryNavy : null,
                      ),
                      onSelected: (val) {
                        setState(() => _statusFilter = status);
                        _loadTasks();
                      },
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Container(
                  height: 20,
                  width: 1,
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                ),
                const SizedBox(width: 8),

                // Priority Filter Chips
                ...['All', 'High', 'Medium', 'Low'].map((priority) {
                  final isSelected = _priorityFilter == priority;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(priority == 'All' ? 'All Priorities' : '$priority Priority'),
                      selected: isSelected,
                      selectedColor: AppTheme.secondaryBlue.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppTheme.secondaryBlue : null,
                      ),
                      onSelected: (val) {
                        setState(() => _priorityFilter = priority);
                        _loadTasks();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Tasks List or Empty / Loading State
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: _tasks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            return TaskCard(
                              task: task,
                              onToggleComplete: (_) => _toggleTaskStatus(task),
                              onEdit: () => _showTaskFormDialog(taskToEdit: task),
                              onDelete: () => _confirmDeleteTask(task),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // Modern Empty State Illustration Widget
  Widget _buildEmptyState() {
    final hasActiveFilter = _searchQuery.isNotEmpty ||
        _statusFilter != 'All' ||
        _priorityFilter != 'All';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasActiveFilter ? Icons.search_off_rounded : Icons.task_alt_rounded,
                size: 64,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasActiveFilter ? 'No matching tasks' : 'No tasks yet!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilter
                  ? 'Try adjusting your search query or filter chips.'
                  : 'Tap the "+ Add Task" button below to plan your study schedule and assignments.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            if (hasActiveFilter) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _statusFilter = 'All';
                    _priorityFilter = 'All';
                  });
                  _loadTasks();
                },
                child: const Text('Reset Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

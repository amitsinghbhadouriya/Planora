class Task {
  final int? id;
  final String title;
  final String? description;
  final String dueDate;
  final String priority; // 'High', 'Medium', 'Low'
  final bool isCompleted;
  final String createdAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.priority = 'Medium',
    this.isCompleted = false,
    required this.createdAt,
  });

  // Convert Task instance to a Map for SQLite insertion and update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'priority': priority,
      'is_completed': isCompleted ? 1 : 0, // SQLite stores boolean as 1 or 0
      'created_at': createdAt,
    };
  }

  // Create a Task instance from a SQLite row Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] as String,
      priority: map['priority'] as String? ?? 'Medium',
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  // CopyWith helper to create updated Task instances immutably
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? dueDate,
    String? priority,
    bool? isCompleted,
    String? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


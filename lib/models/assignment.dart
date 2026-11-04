class Assignment {
  final int? id;
  final String title;
  final String subject;
  final String? description;
  final String deadline; // YYYY-MM-DD
  final String status;   // 'Pending', 'Submitted'
  final String createdAt;

  Assignment({
    this.id,
    required this.title,
    required this.subject,
    this.description,
    required this.deadline,
    this.status = 'Pending',
    required this.createdAt,
  });

  // Convert Assignment instance to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'description': description,
      'deadline': deadline,
      'status': status,
      'created_at': createdAt,
    };
  }

  // Create Assignment instance from SQLite row Map
  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'] as int?,
      title: map['title'] as String,
      subject: map['subject'] as String,
      description: map['description'] as String?,
      deadline: map['deadline'] as String,
      status: map['status'] as String? ?? 'Pending',
      createdAt: map['created_at'] as String,
    );
  }

  // Check if assignment is overdue
  bool isOverdue() {
    if (status == 'Submitted') return false;
    try {
      final dueDate = DateTime.parse(deadline);
      final today = DateTime.now();
      final dateOnlyToday = DateTime(today.year, today.month, today.day);
      return dueDate.isBefore(dateOnlyToday);
    } catch (_) {
      return false;
    }
  }

  // CopyWith helper
  Assignment copyWith({
    int? id,
    String? title,
    String? subject,
    String? description,
    String? deadline,
    String? status,
    String? createdAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


class Exam {
  final int? id;
  final String subject;
  final String examDate; // YYYY-MM-DD
  final String examTime; // HH:mm AM/PM
  final String? notes;

  Exam({
    this.id,
    required this.subject,
    required this.examDate,
    required this.examTime,
    this.notes,
  });

  // Convert Exam instance to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'exam_date': examDate,
      'exam_time': examTime,
      'notes': notes,
    };
  }

  // Create Exam instance from SQLite row Map
  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'] as int?,
      subject: map['subject'] as String,
      examDate: map['exam_date'] as String,
      examTime: map['exam_time'] as String,
      notes: map['notes'] as String?,
    );
  }

  // Calculate days remaining until examination
  int getDaysRemaining() {
    try {
      final parsedDate = DateTime.parse(examDate);
      final today = DateTime.now();
      final dateOnlyToday = DateTime(today.year, today.month, today.day);
      final dateOnlyExam = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      return dateOnlyExam.difference(dateOnlyToday).inDays;
    } catch (_) {
      return 0;
    }
  }

  // CopyWith helper
  Exam copyWith({
    int? id,
    String? subject,
    String? examDate,
    String? examTime,
    String? notes,
  }) {
    return Exam(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      examDate: examDate ?? this.examDate,
      examTime: examTime ?? this.examTime,
      notes: notes ?? this.notes,
    );
  }
}


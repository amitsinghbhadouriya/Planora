import 'package:flutter_test/flutter_test.dart';
import 'package:smart_student_planner/models/task.dart';
import 'package:smart_student_planner/models/timetable.dart';
import 'package:smart_student_planner/models/assignment.dart';
import 'package:smart_student_planner/models/exam.dart';

void main() {
  group('Task Model Unit Tests', () {
    test('Task toMap and fromMap serialization', () {
      final task = Task(
        id: 1,
        title: 'Complete Operating Systems Lab',
        description: 'Process scheduling algorithms',
        dueDate: '2026-11-15',
        priority: 'High',
        isCompleted: false,
        createdAt: '2026-11-04',
      );

      final map = task.toMap();
      expect(map['id'], 1);
      expect(map['title'], 'Complete Operating Systems Lab');
      expect(map['is_completed'], 0);

      final fromMapTask = Task.fromMap(map);
      expect(fromMapTask.id, task.id);
      expect(fromMapTask.title, task.title);
      expect(fromMapTask.isCompleted, false);
    });

    test('Task copyWith updates immutably', () {
      final task = Task(
        id: 2,
        title: 'Initial Title',
        dueDate: '2026-11-10',
        createdAt: '2026-11-04',
      );

      final updated = task.copyWith(
        title: 'Updated Title',
        isCompleted: true,
      );

      expect(updated.id, 2);
      expect(updated.title, 'Updated Title');
      expect(updated.isCompleted, true);
      expect(task.title, 'Initial Title'); // Original remains unchanged
    });
  });

  group('Timetable Model Unit Tests', () {
    test('Timetable serialization and properties', () {
      final timetable = Timetable(
        id: 10,
        subject: 'Database Management Systems',
        day: 'Monday',
        startTime: '09:30 AM',
        endTime: '10:30 AM',
        room: 'Room 304',
      );

      final map = timetable.toMap();
      expect(map['subject'], 'Database Management Systems');
      expect(map['day'], 'Monday');
      expect(map['room'], 'Room 304');

      final reconstructed = Timetable.fromMap(map);
      expect(reconstructed.subject, timetable.subject);
      expect(reconstructed.startTime, timetable.startTime);
    });
  });

  group('Assignment Model Unit Tests', () {
    test('Assignment overdue detection logic', () {
      // Past deadline (overdue)
      final pastAssignment = Assignment(
        title: 'Past Homework',
        subject: 'C++ Programming',
        deadline: '2020-01-01',
        status: 'Pending',
        createdAt: '2020-01-01',
      );
      expect(pastAssignment.isOverdue(), isTrue);

      // Past deadline but submitted (not overdue)
      final submittedAssignment = Assignment(
        title: 'Submitted Homework',
        subject: 'C++ Programming',
        deadline: '2020-01-01',
        status: 'Submitted',
        createdAt: '2020-01-01',
      );
      expect(submittedAssignment.isOverdue(), isFalse);

      // Future deadline (not overdue)
      final futureAssignment = Assignment(
        title: 'Future Homework',
        subject: 'Data Science',
        deadline: '2030-12-31',
        status: 'Pending',
        createdAt: '2026-11-04',
      );
      expect(futureAssignment.isOverdue(), isFalse);
    });
  });

  group('Exam Model Unit Tests', () {
    test('Exam days remaining calculation', () {
      final now = DateTime.now();
      final targetDate = now.add(const Duration(days: 7));
      final formattedTarget =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

      final exam = Exam(
        subject: 'Java Final Exam',
        examDate: formattedTarget,
        examTime: '10:00 AM',
        notes: 'Units 1 to 4',
      );

      expect(exam.getDaysRemaining(), 7);
    });
  });
}


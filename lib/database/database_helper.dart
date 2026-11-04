import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/timetable.dart';
import '../models/assignment.dart';
import '../models/exam.dart';

class DatabaseHelper {
  static const String _databaseName = 'smart_student_planner.db';
  static const int _databaseVersion = 1;

  // Table Names
  static const String tableTasks = 'tasks';
  static const String tableTimetable = 'timetable';
  static const String tableAssignments = 'assignments';
  static const String tableExams = 'exams';

  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tasks Table
    await db.execute('''
      CREATE TABLE $tableTasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT NOT NULL,
        priority TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    // 2. Timetable Table
    await db.execute('''
      CREATE TABLE $tableTimetable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        day TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        room TEXT
      )
    ''');

    // 3. Assignments Table
    await db.execute('''
      CREATE TABLE $tableAssignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        description TEXT,
        deadline TEXT NOT NULL,
        status TEXT DEFAULT 'Pending',
        created_at TEXT
      )
    ''');

    // 4. Exams Table
    await db.execute('''
      CREATE TABLE $tableExams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        exam_date TEXT NOT NULL,
        exam_time TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema migrations here if databaseVersion increases in future updates
  }

  // ==========================================
  // 1. TASK CRUD OPERATIONS
  // ==========================================

  Future<int> insertTask(Task task) async {
    final db = await instance.database;
    return await db.insert(
      tableTasks,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getAllTasks({
    String? priority,
    int? isCompleted,
    String? searchQuery,
    String? sortByDeadline, // 'ASC' or 'DESC'
  }) async {
    final db = await instance.database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (priority != null && priority.isNotEmpty && priority != 'All') {
      whereClauses.add('priority = ?');
      whereArgs.add(priority);
    }

    if (isCompleted != null) {
      whereClauses.add('is_completed = ?');
      whereArgs.add(isCompleted);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('(title LIKE ? OR description LIKE ?)');
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;
    final orderBy = sortByDeadline != null
        ? 'due_date $sortByDeadline'
        : 'is_completed ASC, due_date ASC';

    final result = await db.query(
      tableTasks,
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy,
    );

    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db.update(
      tableTasks,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> toggleTaskStatus(int id, bool isCompleted) async {
    final db = await instance.database;
    return await db.update(
      tableTasks,
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableTasks,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, int>> getTaskStatistics() async {
    final db = await instance.database;
    final totalResult = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableTasks'),
    ) ?? 0;

    final completedResult = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableTasks WHERE is_completed = 1'),
    ) ?? 0;

    final pendingResult = totalResult - completedResult;

    return {
      'total': totalResult,
      'completed': completedResult,
      'pending': pendingResult,
    };
  }

  // ==========================================
  // 2. TIMETABLE CRUD OPERATIONS
  // ==========================================

  Future<int> insertTimetable(Timetable timetable) async {
    final db = await instance.database;
    return await db.insert(
      tableTimetable,
      timetable.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Timetable>> getAllTimetable() async {
    final db = await instance.database;
    final result = await db.query(tableTimetable, orderBy: 'day, start_time ASC');
    return result.map((map) => Timetable.fromMap(map)).toList();
  }

  Future<List<Timetable>> getTimetableForDay(String day) async {
    final db = await instance.database;
    final result = await db.query(
      tableTimetable,
      where: 'day = ?',
      whereArgs: [day],
      orderBy: 'start_time ASC',
    );
    return result.map((map) => Timetable.fromMap(map)).toList();
  }

  Future<int> updateTimetable(Timetable timetable) async {
    final db = await instance.database;
    return await db.update(
      tableTimetable,
      timetable.toMap(),
      where: 'id = ?',
      whereArgs: [timetable.id],
    );
  }

  Future<int> deleteTimetable(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableTimetable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // 3. ASSIGNMENT CRUD OPERATIONS
  // ==========================================

  Future<int> insertAssignment(Assignment assignment) async {
    final db = await instance.database;
    return await db.insert(
      tableAssignments,
      assignment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Assignment>> getAllAssignments({
    String? status,
    String? searchQuery,
  }) async {
    final db = await instance.database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (status != null && status.isNotEmpty && status != 'All') {
      whereClauses.add('status = ?');
      whereArgs.add(status);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('(title LIKE ? OR subject LIKE ? OR description LIKE ?)');
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final result = await db.query(
      tableAssignments,
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'deadline ASC',
    );

    return result.map((map) => Assignment.fromMap(map)).toList();
  }

  Future<List<Assignment>> getUpcomingAssignments({int limit = 3}) async {
    final db = await instance.database;
    final result = await db.query(
      tableAssignments,
      where: 'status = ?',
      whereArgs: ['Pending'],
      orderBy: 'deadline ASC',
      limit: limit,
    );
    return result.map((map) => Assignment.fromMap(map)).toList();
  }

  Future<int> updateAssignment(Assignment assignment) async {
    final db = await instance.database;
    return await db.update(
      tableAssignments,
      assignment.toMap(),
      where: 'id = ?',
      whereArgs: [assignment.id],
    );
  }

  Future<int> toggleAssignmentStatus(int id, String currentStatus) async {
    final newStatus = currentStatus == 'Submitted' ? 'Pending' : 'Submitted';
    final db = await instance.database;
    return await db.update(
      tableAssignments,
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAssignment(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableAssignments,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, int>> getAssignmentStatistics() async {
    final db = await instance.database;
    final total = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableAssignments'),
    ) ?? 0;

    final submitted = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM $tableAssignments WHERE status = 'Submitted'"),
    ) ?? 0;

    final pending = total - submitted;

    return {
      'total': total,
      'submitted': submitted,
      'pending': pending,
    };
  }

  // ==========================================
  // 4. EXAM CRUD OPERATIONS
  // ==========================================

  Future<int> insertExam(Exam exam) async {
    final db = await instance.database;
    return await db.insert(
      tableExams,
      exam.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Exam>> getAllExams({bool upcomingOnly = false}) async {
    final db = await instance.database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (upcomingOnly) {
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      whereClause = 'exam_date >= ?';
      whereArgs = [todayStr];
    }

    final result = await db.query(
      tableExams,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'exam_date ASC, exam_time ASC',
    );
    return result.map((map) => Exam.fromMap(map)).toList();
  }

  Future<Exam?> getNextExam() async {
    final db = await instance.database;
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final result = await db.query(
      tableExams,
      where: 'exam_date >= ?',
      whereArgs: [todayStr],
      orderBy: 'exam_date ASC, exam_time ASC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Exam.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateExam(Exam exam) async {
    final db = await instance.database;
    return await db.update(
      tableExams,
      exam.toMap(),
      where: 'id = ?',
      whereArgs: [exam.id],
    );
  }

  Future<int> deleteExam(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableExams,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // 5. SAMPLE SEEDING & DATABASE MANAGEMENT
  // ==========================================

  Future<void> seedInitialSampleData() async {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T').first;
    final tomorrowStr = now.add(const Duration(days: 1)).toIso8601String().split('T').first;
    final nextWeekStr = now.add(const Duration(days: 7)).toIso8601String().split('T').first;
    final twoWeeksStr = now.add(const Duration(days: 14)).toIso8601String().split('T').first;

    // Seed Tasks
    await insertTask(Task(
      title: 'Complete DBMS Lab Assignment 3',
      description: 'Write SQL queries for normalization and indexing',
      dueDate: tomorrowStr,
      priority: 'High',
      isCompleted: false,
      createdAt: todayStr,
    ));

    await insertTask(Task(
      title: 'Prepare Java OOP Presentation',
      description: 'Create 10 slides on Inheritance & Polymorphism',
      dueDate: nextWeekStr,
      priority: 'Medium',
      isCompleted: false,
      createdAt: todayStr,
    ));

    await insertTask(Task(
      title: 'Submit College Library Books',
      description: 'Return Operating Systems reference textbook',
      dueDate: todayStr,
      priority: 'Low',
      isCompleted: true,
      createdAt: todayStr,
    ));

    // Seed Timetable (Sample Monday & Tuesday classes)
    await insertTimetable(Timetable(
      subject: 'Database Management Systems',
      day: 'Monday',
      startTime: '09:30 AM',
      endTime: '10:30 AM',
      room: 'Room 304',
    ));

    await insertTimetable(Timetable(
      subject: 'Java Programming Lab',
      day: 'Monday',
      startTime: '10:45 AM',
      endTime: '12:45 PM',
      room: 'Computer Lab 2',
    ));

    await insertTimetable(Timetable(
      subject: 'Data Structures & Algorithms',
      day: 'Tuesday',
      startTime: '10:00 AM',
      endTime: '11:00 AM',
      room: 'Room 201',
    ));

    // Seed Assignments
    await insertAssignment(Assignment(
      title: 'Data Structures Mini-Project',
      subject: 'Data Structures',
      description: 'Implement binary search tree with graphical console visualizer',
      deadline: nextWeekStr,
      status: 'Pending',
      createdAt: todayStr,
    ));

    await insertAssignment(Assignment(
      title: 'Web Technologies HTML5/CSS Report',
      subject: 'Web Technologies',
      description: 'Document responsive grid design patterns',
      deadline: tomorrowStr,
      status: 'Submitted',
      createdAt: todayStr,
    ));

    // Seed Exams
    await insertExam(Exam(
      subject: 'Database Systems Mid-Term',
      examDate: twoWeeksStr,
      examTime: '10:00 AM',
      notes: 'Units 1 to 3 covering ER Diagrams, Relational Algebra and SQL DDL/DML',
    ));

    await insertExam(Exam(
      subject: 'Operating Systems Theory',
      examDate: now.add(const Duration(days: 18)).toIso8601String().split('T').first,
      examTime: '02:00 PM',
      notes: 'Process scheduling algorithms and Deadlock prevention',
    ));
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete(tableTasks);
    await db.delete(tableTimetable);
    await db.delete(tableAssignments);
    await db.delete(tableExams);
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}


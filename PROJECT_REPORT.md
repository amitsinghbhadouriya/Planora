# ACADEMIC PROJECT REPORT: SMART STUDENT PLANNER

**Degree**: Bachelor of Computer Applications (BCA)  
**Project Title**: Smart Student Planner Application  
**Technologies**: Flutter, Dart, SQLite (sqflite), Material Design 3  
**Platform**: Android (Offline-First)  

---

## 1. ABSTRACT

Modern college students face significant academic fragmentation. Managing lectures across a six-day timetable, tracking multiple assignment deadlines, preparing for upcoming semester examinations, and balancing daily self-study tasks often relies on disparate tools such as paper notebooks, messaging groups, and generic calendar apps. 

The **Smart Student Planner** is an individual college-level software engineering project designed to centralize and automate academic activity tracking into a unified, modern mobile application. Built using the Flutter framework and Dart programming language, the application implements an **offline-first SQLite architecture** via the `sqflite` package. 

Key modules include an automated **Home Dashboard**, **Task Management** with priority tagging and search, a **Weekly College Timetable** with time-chronology validation, an **Assignment Tracker** with automatic overdue alerts, an **Examination Planner** with days-remaining countdowns, and a **Study Progress Analytics** engine with radial completion gauges. All data operations are persistent, parameterized, and operate independently of an internet connection.

---

## 2. PROBLEM STATEMENT & NEED FOR THE SYSTEM

### 2.1 The Problem
College coursework requires students to balance numerous simultaneous responsibilities:
1. Daily assignments across 5–6 courses with strict deadlines.
2. Fluctuating weekly lecture schedules across diverse lecture halls and computer laboratories.
3. Mid-term and final examination dates requiring advance study schedules.
4. Difficulty in measuring daily productivity and study progress.

Existing solutions either require constant internet connectivity (cloud-dependent apps), display intrusive advertisements, or present cluttered interfaces that are not tailored for college academic structures.

### 2.2 The Solution
The Smart Student Planner provides an offline, privacy-first Android application adhering to Material Design 3 principles. It functions without login friction, requires zero internet access, stores all records securely in a local SQLite relational database (`smart_student_planner.db`), and provides immediate visual feedback on academic discipline.

---

## 3. SYSTEM REQUIREMENTS

### 3.1 Software Requirements
- **Operating System**: Windows 10/11, macOS, or Linux
- **Development Kit**: Flutter SDK v3.0 or higher
- **Programming Language**: Dart SDK v3.0 or higher
- **Database Engine**: SQLite 3.x (managed via `sqflite: ^2.4.1`)
- **IDE**: Android Studio / Visual Studio Code / Antigravity IDE
- **Target Platform**: Android API Level 21 (Lollipop) through API Level 34+ (Android 14)

### 3.2 Hardware Requirements
- **Development PC**: Minimum 8GB RAM (16GB recommended for emulator), Intel Core i3/i5 or AMD Ryzen processor, 10GB free disk space.
- **Testing Device**: Android physical smartphone or Android Virtual Device (AVD).

---

## 4. SYSTEM ARCHITECTURE

The application is structured into four distinct architectural layers, ensuring modularity, testability, and maintainability:

```text
┌──────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│   DashboardScreen  •  TasksScreen  •  TimetableScreen         │
│   AssignmentsScreen  •  ExamsScreen  •  ProgressScreen        │
│   Widgets: TaskCard, TimetableCard, AssignmentCard, ExamCard │
└──────────────────────────────┬───────────────────────────────┘
                               │
┌──────────────────────────────▼───────────────────────────────┐
│                     SERVICE & STATE LAYER                    │
│   PreferencesService (SharedPreferences)                     │
│   NotificationService (flutter_local_notifications)          │
│   IndexedStack State Management & Theme Controllers          │
└──────────────────────────────┬───────────────────────────────┘
                               │
┌──────────────────────────────▼───────────────────────────────┐
│                       DATA MODEL LAYER                       │
│   Task  •  Timetable  •  Assignment  •  Exam                 │
│   (toMap, fromMap, copyWith, isOverdue, getDaysRemaining)    │
└──────────────────────────────┬───────────────────────────────┘
                               │
┌──────────────────────────────▼───────────────────────────────┐
│                   PERSISTENCE LAYER (SQLite)                 │
│   DatabaseHelper (Singleton Pattern)                         │
│   smart_student_planner.db (tasks, timetable, assignments)   │
└──────────────────────────────────────────────────────────────┘
```

---

## 5. DATABASE SCHEMA SPECIFICATION

The application utilizes **SQLite** for relational data storage. All database access is funneled through `DatabaseHelper.instance`.

```text
+------------------------------------+       +------------------------------------+
|               tasks                |       |             timetable              |
+------------------------------------+       +------------------------------------+
| id (PK, AUTOINCREMENT)             |       | id (PK, AUTOINCREMENT)             |
| title (TEXT NOT NULL)              |       | subject (TEXT NOT NULL)            |
| description (TEXT)                 |       | day (TEXT NOT NULL)                |
| due_date (TEXT NOT NULL)           |       | start_time (TEXT NOT NULL)         |
| priority (TEXT NOT NULL)           |       | end_time (TEXT NOT NULL)           |
| is_completed (INTEGER DEFAULT 0)   |       | room (TEXT)                        |
| created_at (TEXT)                  |       +------------------------------------+
+------------------------------------+
                                             +------------------------------------+
+------------------------------------+       |               exams                |
|            assignments             |       +------------------------------------+
+------------------------------------+       | id (PK, AUTOINCREMENT)             |
| id (PK, AUTOINCREMENT)             |       | subject (TEXT NOT NULL)            |
| title (TEXT NOT NULL)              |       | exam_date (TEXT NOT NULL)          |
| subject (TEXT NOT NULL)            |       | exam_time (TEXT NOT NULL)          |
| description (TEXT)                 |       | notes (TEXT)                       |
| deadline (TEXT NOT NULL)           |       +------------------------------------+
| status (TEXT DEFAULT 'Pending')    |
| created_at (TEXT)                  |
+------------------------------------+
```

---

## 6. MODULE-WISE FUNCTIONALITY

### Module 1: Home Dashboard (`dashboard_screen.dart`)
- **Student Profile Greeting**: Displays custom student name retrieved from `PreferencesService`.
- **Dynamic Completion Rate**: Visual linear progress bar calculated from real SQLite task completions.
- **Academic Overview Grid**: 4 live metric cards (Total Tasks, Completed Tasks, Pending Tasks, Due Assignments).
- **Today's Lecture Snapshot**: Checks the current day of the week (`DateFormat('EEEE')`) and displays the immediate next class and room number.
- **Approaching Exam Alert**: Highlights upcoming examinations with days remaining.
- **Quick Action Bar**: Shortcuts to add tasks, classes, assignments, and exams.

### Module 2: Task Management (`tasks_screen.dart`)
- Full CRUD operations (Create, Read, Update, Delete) with SQLite persistence.
- Form validation ensuring task titles cannot be submitted empty.
- Priority levels: High (Red), Medium (Orange), Low (Blue).
- Strikethrough visual feedback and checkbox toggle for completed tasks.
- Real-time search by title or description.
- Filter chips for status (`All`, `Pending`, `Completed`) and priority (`High`, `Medium`, `Low`).
- Deadline sorting (Earliest to Latest / Latest to Earliest).

### Module 3: Timetable Management (`timetable_screen.dart`)
- Monday to Saturday TabBar navigation with automatic selection of today's day.
- Class scheduling with subject, room/laboratory number, start time, and end time.
- **Time Validation**: Strict logic ensures `endTime` is chronologically later than `startTime` (`endMinutes > startMinutes`).
- Delete confirmation dialog.

### Module 4: Assignment Tracker (`assignments_screen.dart`)
- Assignment tracking with subject tagging, requirements notes, and calendar deadline.
- Status toggle: One-tap transition between "Pending" and "Submitted".
- **Overdue Engine**: Dynamic comparison of deadline date against current date displays a highlighted red border and `OVERDUE` badge for late submissions.
- Filter chips: `All`, `Pending`, `Submitted`.

### Module 5: Examination Planner (`exams_screen.dart`)
- Subject, date, time, and syllabus unit notes.
- Automatic day countdowns: `TODAY`, `TOMORROW`, `In X days`, and `Completed`.
- Chronological ordering ensuring the nearest exam is always on top.
- Filter between Upcoming Exams and All Exams.

### Module 6: Study Progress Analytics (`progress_screen.dart`)
- Custom radial gauge displaying exact task completion percentage.
- Dynamic performance insight banner based on academic discipline.
- Assignment submission breakdown bar.
- Weekly lecture load density counter.
- Nearest examination countdown display.

### Module 7: Settings & Local Preferences (`settings_screen.dart`)
- Editable student profile name synced to the Home Dashboard.
- Light Mode / Dark Mode toggle using `shared_preferences`.
- Notification switches for tasks, assignments, and exams.
- Send Test Notification button.
- Instant Sample Data Seeder & Safe Database Eraser with confirmation dialog.

---

## 7. TEST CASES AND VERIFICATION MATRIX

| Test ID | Test Scenario | Input Data | Expected Result | Status |
| :--- | :--- | :--- | :--- | :--- |
| **TC-01** | Add new task with valid data | Title: "DBMS Lab 3", Priority: High | Record inserted into SQLite; list updates | **PASS** |
| **TC-02** | Add task with empty title | Title: "" (blank) | Form validation error: "Task title cannot be empty" | **PASS** |
| **TC-03** | Toggle task completion | Tap checkbox on Task | `is_completed` toggles to 1 in SQLite; strikethrough applied | **PASS** |
| **TC-04** | Delete task confirmation | Tap Delete on Task -> Confirm | Record deleted from table; SnackBar confirms | **PASS** |
| **TC-05** | Timetable invalid time validation | Start: 11:00 AM, End: 10:00 AM | Error: "Class ending time must be later than starting time" | **PASS** |
| **TC-06** | Timetable valid time insertion | Start: 09:30 AM, End: 10:30 AM | Class saved and displayed under selected day | **PASS** |
| **TC-07** | Assignment overdue detection | Deadline: Yesterday, Status: Pending | Card displays red border and "OVERDUE" chip | **PASS** |
| **TC-08** | Assignment submission toggle | Tap "Submit" button | Status updates to "Submitted"; overdue chip removed | **PASS** |
| **TC-09** | Exam countdown calculation | Exam date: 14 days from today | Exam card displays "In 14 days" badge | **PASS** |
| **TC-10** | Dashboard live metric sync | Add 1 task and mark 1 completed | Dashboard counters and progress bar update automatically | **PASS** |
| **TC-11** | App restart offline persistence | Add records -> Terminate app -> Reopen | All records remain intact in SQLite database | **PASS** |
| **TC-12** | Theme toggle persistence | Switch to Dark Theme -> Reopen app | Dark theme remains active via `SharedPreferences` | **PASS** |

---

## 8. TEACHER VIVA VOCE QUESTIONS & ANSWERS

### Q1: Why did you choose SQLite (`sqflite`) instead of Firebase or an online backend?
> **Answer**: This application is specifically architected as an **offline-first academic planner**. Students need to access their timetable, notes, and deadlines inside lecture halls, basements, or areas with poor internet connectivity. SQLite operates completely locally on the device with zero network latency, zero operational costs, and complete student privacy.

### Q2: What is the purpose of the `DatabaseHelper` Singleton?
> **Answer**: In SQLite, having multiple open connection instances can lead to database locks, memory leaks, and concurrency race conditions. By using a private constructor (`DatabaseHelper._init()`) and a static instance (`DatabaseHelper.instance`), we ensure that the entire application shares one thread-safe SQLite connection.

### Q3: Explain `toMap()` and `fromMap()` in your Dart models.
> **Answer**: SQLite stores data as key-value column pairs (`Map<String, dynamic>`), whereas Flutter UI widgets require strongly typed Dart objects (`Task`, `Assignment`). 
> - `toMap()` converts a Dart object into a Map for `db.insert()` and `db.update()`.
> - `fromMap()` is a factory constructor that recreates a strongly typed Dart object from raw SQLite query rows.

### Q4: How does `IndexedStack` improve the user experience compared to regular screen navigation?
> **Answer**: If we rebuild screens using standard routes, the state of the screen is lost every time the student changes tabs. `IndexedStack` keeps all 5 main screens loaded in memory, preserving user input, scroll position, and filter selections.

### Q5: How do you prevent SQL Injection in your database queries?
> **Answer**: We never concatenate user inputs directly into SQL strings. Instead, we use **parameterized queries** with `?` placeholders (e.g., `where: 'id = ?', whereArgs: [id]`). The SQLite engine parses the query structure before substituting arguments safely.

### Q6: How is the ending time validated against the starting time in Timetable?
> **Answer**: We convert both `startTime` and `endTime` into total elapsed minutes from midnight:
> `startMinutes = startTime.hour * 60 + startTime.minute`
> `endMinutes = endTime.hour * 60 + endTime.minute`
> If `endMinutes <= startMinutes`, the form validation rejects the submission and displays an error message.

### Q7: What is the difference between `SharedPreferences` and `SQLite`?
> **Answer**: `SharedPreferences` is a lightweight key-value store suitable for primitive types (booleans, strings) like the theme preference (`isDarkMode`) or student name. SQLite is a full relational database management system suitable for structured tables requiring search, filtering, and indexing.

---

## 9. ADVANTAGES & LIMITATIONS

### Advantages:
1. **100% Offline Independence**: Works everywhere without mobile data or Wi-Fi.
2. **Instant UI Response**: Zero network latency; all database operations run in local asynchronous thread pools.
3. **Clean Material Design 3**: Modern aesthetic with rounded cards, custom color-coding, and dark mode.
4. **Data Integrity**: Parameterized queries, input validation, and delete confirmation dialogs prevent data corruption and accidental loss.

### Limitations:
1. **Single-Device Storage**: Data is stored locally on the phone and does not automatically sync across multiple devices.
2. **Manual Timetable Entry**: Class schedules must be entered by the student or loaded via the built-in demo seeder.

---

## 10. FUTURE SCOPE & CONCLUSION

### Future Scope:
- Integration of OCR (Optical Character Recognition) to scan printed college timetable notices directly into SQLite.
- Export and import functionality (JSON / CSV backup) to transfer data across devices.
- Audio note recording for quick lecture reminders.
- Home screen widget for Android showing the next lecture and pending tasks.

### Conclusion:
The **Smart Student Planner** successfully fulfills all objectives of a practical, modern, and reliable academic organizer. It demonstrates full-stack client-side engineering using Flutter, Dart, and SQLite, and provides college students with a secure, offline tool to maximize their academic productivity.


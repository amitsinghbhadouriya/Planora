# Smart Student Planner

> A modern, offline-first Android application developed in Flutter & Dart for college students to manage tasks, lecture timetables, assignment deadlines, examination schedules, and study analytics.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![Database](https://img.shields.io/badge/SQLite-sqflite-003B57?logo=sqlite)](https://pub.dev/packages/sqflite)
[![Design](https://img.shields.io/badge/Material%20Design-3-6750A4)](https://m3.material.io)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com)

---

## 📌 Project Overview

**Smart Student Planner** is an individual college-level BCA final-year project designed to solve academic fragmentation. Rather than juggling multiple paper diaries, messaging groups, and generic calendar apps, students can manage their daily coursework, college timetable, pending homework, and exam countdowns in one unified, offline-first dashboard.

### Core Objectives
1. **Daily Task Management**: Priority-tagged task tracking with instant completion status.
2. **Weekly Timetable**: Monday to Saturday class scheduling with room numbers and start/end time validation.
3. **Assignment Tracking**: Due date tracking with automatic overdue calculation and status toggling.
4. **Examination Planner**: Chronological exam dates with real-time countdown badges (`TODAY`, `TOMORROW`, `In X days`).
5. **Study Analytics**: Dynamically generated completion percentage and academic discipline insights computed directly from SQLite records.
6. **100% Offline Storage**: Powered by local SQLite (`sqflite`) and `shared_preferences` without cloud or external API dependencies.

---

## 🏗️ Architecture & Folder Structure

The project follows a clean separation of concerns:

```text
smart_student_planner/
├── pubspec.yaml
└── lib/
    ├── main.dart                      # Application bootstrap, theme loader & notification initialization
    ├── database/
    │   └── database_helper.dart       # Singleton SQLite helper with parameterized CRUD queries
    ├── models/
    │   ├── task.dart                  # Task model with SQLite serialization & priority levels
    │   ├── timetable.dart             # Lecture schedule model with day & time intervals
    │   ├── assignment.dart            # Assignment model with overdue detection helper
    │   └── exam.dart                  # Examination model with countdown calculation
    ├── screens/
    │   ├── main_navigation_screen.dart # IndexedStack persistent 5-tab navigation shell
    │   ├── dashboard_screen.dart       # Live overview, completion progress & timetable snapshots
    │   ├── tasks_screen.dart          # Task CRUD with search, priority & status filter chips
    │   ├── timetable_screen.dart      # Weekly timetable with Monday-Saturday tabs & time validation
    │   ├── assignments_screen.dart    # Assignment tracking with overdue highlights
    │   ├── exams_screen.dart          # Exam planner with countdown chips & syllabus notes
    │   ├── progress_screen.dart       # Productivity analytics with radial completion gauge
    │   └── settings_screen.dart       # Profile editing, theme toggle, and database utilities
    ├── services/
    │   ├── preferences_service.dart   # SharedPreferences persistence for user settings
    │   └── notification_service.dart  # Offline Android local notification alerts
    ├── theme/
    │   └── app_theme.dart             # Material 3 light (#F5F7FB) & dark (#0F172A) themes
    └── widgets/
        ├── custom_bottom_nav.dart     # Material 3 bottom navigation bar
        ├── summary_card.dart          # Reusable academic metric card
        ├── quick_action_button.dart   # Dashboard quick-action shortcuts
        ├── task_card.dart             # Task card with color-coded priority and checkbox
        ├── timetable_card.dart        # Lecture schedule slot card
        ├── assignment_card.dart       # Assignment card with overdue warning badge
        └── exam_card.dart             # Exam card with countdown indicator
```

---

## 💾 SQLite Database Design (`smart_student_planner.db`)

All tables are created automatically with parameterized queries:

### 1. `tasks`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique Task ID |
| `title` | TEXT | NOT NULL | Task title |
| `description`| TEXT | NULLABLE | Notes / sub-tasks |
| `due_date` | TEXT | NOT NULL | ISO date string (`YYYY-MM-DD`) |
| `priority` | TEXT | NOT NULL | `'High'`, `'Medium'`, `'Low'` |
| `is_completed`| INTEGER| DEFAULT 0 | `1` = Completed, `0` = Pending |
| `created_at` | TEXT | NULLABLE | Creation timestamp |

### 2. `timetable`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique Schedule ID |
| `subject` | TEXT | NOT NULL | Course / subject title |
| `day` | TEXT | NOT NULL | `'Monday'` to `'Saturday'` |
| `start_time` | TEXT | NOT NULL | Lecture start time (`09:30 AM`) |
| `end_time` | TEXT | NOT NULL | Lecture end time (`10:30 AM`) |
| `room` | TEXT | NULLABLE | Classroom / Hall number |

### 3. `assignments`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique Assignment ID |
| `title` | TEXT | NOT NULL | Assignment name |
| `subject` | TEXT | NOT NULL | Subject / course |
| `description`| TEXT | NULLABLE | Requirements & guidelines |
| `deadline` | TEXT | NOT NULL | Submission deadline date |
| `status` | TEXT | DEFAULT 'Pending' | `'Pending'` or `'Submitted'` |
| `created_at` | TEXT | NULLABLE | Creation timestamp |

### 4. `exams`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique Exam ID |
| `subject` | TEXT | NOT NULL | Course name |
| `exam_date` | TEXT | NOT NULL | Examination date (`YYYY-MM-DD`) |
| `exam_time` | TEXT | NOT NULL | Examination time (`10:00 AM`) |
| `notes` | TEXT | NULLABLE | Syllabus units, room, items |

---

## 🚀 Setup & Execution Guide

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows/mobile) (version >= 3.0.0)
- Android Studio or VS Code with Flutter extension
- Android Virtual Device (AVD) or physical Android device with USB debugging enabled

### Run Instructions
```bash
# 1. Clone or navigate to the project directory
cd "c:\Users\Asus\OneDrive\Documents\Android project"

# 2. Generate Android platform files (if not already generated)
flutter create --org com.smartplanner --project-name smart_student_planner .

# 3. Install packages
flutter pub get

# 4. Run the app in debug mode
flutter run

# 5. Build release APK for college submission
flutter build apk --release
```
The generated APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🎨 Color Palette & Design System

- **Primary**: Deep Navy Blue (`#173B63`)
- **Secondary**: Light Blue (`#4A90E2`)
- **Background (Light)**: `#F5F7FB`
- **Surface / Card (Light)**: `#FFFFFF`
- **Background (Dark)**: `#0F172A`
- **Surface / Card (Dark)**: `#1E293B`
- **Priority High / Error**: `#D32F2F`
- **Priority Medium / Warning**: `#ED6C02`
- **Success / Completed**: `#2E7D32`

---

## 📄 License
This project was developed for academic purposes as an individual college BCA Capstone Project.

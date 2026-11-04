# Changelog: Smart Student Planner

All notable changes to the Smart Student Planner application are documented in this file.

---

## [1.0.0] - 2026-11-04 - Initial Release (BCA Capstone)

### Added
- **Core Architecture & Configuration**:
  - Material Design 3 light (`#F5F7FB`) and dark (`#0F172A`) themes.
  - Custom bottom navigation bar with 5 primary destinations.
  - State preservation using `IndexedStack`.
- **Database Engine**:
  - SQLite local database (`smart_student_planner.db`) via `sqflite`.
  - Four relational tables: `tasks`, `timetable`, `assignments`, `exams`.
  - Parameterized CRUD queries with sample college data seeder.
- **Task Management**:
  - Add, edit, delete (with confirmation), and complete tasks.
  - Priority levels (`High`, `Medium`, `Low`) with color-coded chips.
  - Real-time search by title or notes.
  - Status filters (`All`, `Pending`, `Completed`) and deadline sorting.
- **Timetable Management**:
  - Monday to Saturday schedule tabs.
  - Start and end time pickers with strict chronology validation (`endMinutes > startMinutes`).
  - Classroom / laboratory location tagging.
- **Assignment Tracker**:
  - Submission deadline monitoring.
  - Dynamic overdue alert calculation (`isOverdue()`).
  - One-tap status toggle between `Pending` and `Submitted`.
- **Examination Planner**:
  - Chronological exam schedule with syllabus notes.
  - Dynamic countdown badges (`TODAY`, `TOMORROW`, `In X days`).
  - Filter toggle between `Upcoming Only` and `All Exams`.
- **Study Progress Analytics**:
  - Real-time task completion radial gauge.
  - Dynamic academic discipline feedback banner.
  - Assignment submission ratio and weekly lecture density.
- **Settings & Preferences**:
  - Editable student profile name synced to the Home Dashboard.
  - Persistent Dark Mode toggle via `shared_preferences`.
  - Notification preference switches with instant test alert trigger.
  - Safe database eraser and demo data loader.
- **Documentation & QA**:
  - Academic project report with viva voce questions and answers (`PROJECT_REPORT.md`).
  - 12-stage live classroom presentation guide (`DEMO_GUIDE.md`).
  - Unit and widget automated testing suite (`test/`).

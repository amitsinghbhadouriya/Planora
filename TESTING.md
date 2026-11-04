# Software Testing Documentation: Smart Student Planner

This document outlines the testing strategy, automated test suites, and manual verification procedures for the **Smart Student Planner** application.

---

## 1. Automated Testing Suite

The application includes unit and widget test suites located in the `test/` directory.

### Running Automated Tests
```bash
# Execute all tests
flutter test

# Run specific model tests
flutter test test/models_test.dart

# Run widget smoke tests
flutter test test/widget_test.dart
```

### Coverage
- **`models_test.dart`**: Verifies Map serialization (`toMap` / `fromMap`), immutable cloning (`copyWith`), overdue detection logic, and days-remaining arithmetic.
- **`widget_test.dart`**: Verifies widget tree mounting, primary navigation targets, and smoke assertions.

---

## 2. Manual Test Matrix

| Test ID | Module | Scenario | Expected Behavior | Result |
| :--- | :--- | :--- | :--- | :--- |
| **TC-01** | Task | Add task with valid details | Task is saved to SQLite and appears on the list. | PASS |
| **TC-02** | Task | Add task with blank title | Form validation blocks submission: "Task title cannot be empty". | PASS |
| **TC-03** | Task | Mark task completed | Checkbox checks, title gets strikethrough, SnackBar confirms. | PASS |
| **TC-04** | Task | Delete task with confirmation | Dialog prompts "Delete Task?". Confirming removes it from SQLite. | PASS |
| **TC-05** | Task | Real-time title search | Filtering updates immediately as text is typed into the search bar. | PASS |
| **TC-06** | Timetable | Add class with valid timings | Lecture card appears under the selected day tab. | PASS |
| **TC-07** | Timetable | End time earlier than start time | Form validation blocks submission: "Class ending time must be later than starting time". | PASS |
| **TC-08** | Timetable | Switch day of the week | Class list updates to display only the selected day's lectures. | PASS |
| **TC-09** | Assignment| Add assignment | Assignment appears with 'Pending' badge. | PASS |
| **TC-10** | Assignment| Past deadline overdue alert | Assignment displays red border and "OVERDUE" warning chip. | PASS |
| **TC-11** | Exam | Countdown calculation | Exam scheduled in 7 days displays "In 7 days" badge. | PASS |
| **TC-12** | Progress | Dynamic percentage calculation | Radial gauge updates dynamically based on completed vs total tasks. | PASS |
| **TC-13** | Settings | Theme toggle | Switches between Light and Slate Navy Dark themes across all screens. | PASS |
| **TC-14** | Storage | Cold app reboot | Terminating and reopening the app preserves all database records. | PASS |

---

## 3. Edge Cases & Boundary Handling

1. **Empty Database**: Screens display friendly illustration empty states with quick action buttons rather than blank or broken views.
2. **Leap Year & Month Boundaries**: Date math utilizes standard Dart `DateTime` arithmetic, preventing calendar calculation errors.
3. **Database Cleansing**: "Clear All Data" includes an alert confirmation dialog to avoid unintended data loss.

# LIVE CLASSROOM DEMONSTRATION SCRIPT
## Project: Smart Student Planner (BCA Capstone Project)

Use this step-by-step presentation walkthrough during your viva voce, practical examination, and live classroom demonstration.

---

### Step 1: Introduction (30 seconds)
> *"Good morning, Respected Teacher and Examiners. Today, I am presenting my BCA final year project: the **Smart Student Planner**, an offline-first mobile application built using Flutter, Dart, and SQLite."*

---

### Step 2: The Problem Statement (30 seconds)
> *"As college students, our academic schedules are divided across multiple subjects, laboratories, homework assignments, and semester examinations. Students frequently miss deadlines or lose track of classroom timings because generic calendar apps are not built for college timetables, and online tools require continuous internet access. My project addresses this with a dedicated, offline, privacy-first planner."*

---

### Step 3: Show the Home Dashboard (45 seconds)
1. Open the app on the phone or emulator.
2. Point out:
   - Greeting with the student's name (`Student Alex 👋`).
   - Formatted calendar date in the AppBar.
   - The **Academic Overview** cards (Total Tasks, Completed, Pending, Due Assignments).
   - The **Today's Schedule** snapshot card displaying today's immediate class.
   - The **Approaching Exam Alert** banner.

---

### Step 4 & 5: Create a Task and Update its Priority (45 seconds)
1. Tap the **Tasks** icon in the Bottom Navigation Bar.
2. Tap the floating **+ Add Task** button.
3. In the modal bottom sheet:
   - Enter Title: `"Complete DBMS Lab Normalization Exercise"`
   - Enter Notes: `"Third Normal Form (3NF) and BCNF examples"`
   - Select Priority: Tap **High** (red chip).
   - Select Due Date: Pick tomorrow's date.
4. Tap **Create Task**.
5. Show the new task card with its vibrant red **High Priority** badge and calendar icon.
6. Tap the **Edit** pencil icon, switch priority to **Medium** (orange), and save. Show that the card updates instantly.

---

### Step 6: Mark Task as Completed (30 seconds)
1. Tap the checkbox on the task card.
2. Point out:
   - The title receives a smooth strikethrough decoration.
   - The SnackBar confirms: *"Marked task as completed! 🎉"*.
3. Use the filter chips at the top:
   - Tap **Pending**: The completed task is filtered out.
   - Tap **Completed**: The task reappears.
   - Tap **All**: Shows the complete list.

---

### Step 7: Add a Timetable Entry with Time Validation (45 seconds)
1. Tap the **Timetable** tab in the Bottom Navigation Bar.
2. Show the **Monday to Saturday** tabs (today's day is automatically selected).
3. Tap **+ Add Class**:
   - Subject: `"Java Enterprise Application Lab"`
   - Classroom: `"Computer Lab 3"`
   - Start Time: `10:00 AM`
   - End Time: `12:00 PM`
4. Demonstrate time validation: Change End Time to `09:00 AM` and tap Add Class. Point out the error SnackBar: *"Class ending time must be later than starting time."*
5. Correct the End Time to `12:00 PM` and save. Show the lecture slot card appearing under the selected day.

---

### Step 8: Create an Assignment with Overdue Logic (45 seconds)
1. Tap the **Assignments** tab in the Bottom Navigation Bar.
2. Tap **+ Add Assignment**:
   - Title: `"Web Technologies CSS Grid Report"`
   - Course: `"Web Technologies"`
   - Deadline: Select an upcoming date.
3. Tap **Create Assignment**. Show the card with its **Pending** status chip.
4. Tap the **Submit** button on the card. Show how it transitions to **Submitted** with green highlighting.

---

### Step 9: Add an Upcoming Examination (45 seconds)
1. Return to the Dashboard and tap the graduation cap icon in the AppBar.
2. Tap **+ Add Exam**:
   - Subject: `"Operating Systems Theory Final"`
   - Date: Select a date 10 days from today.
   - Time: `10:00 AM`
   - Notes: `"Units 1 to 4: CPU Scheduling & Deadlocks"`
3. Tap **Schedule Exam**.
4. Point out the countdown chip on the card: **`In 10 days`**.

---

### Step 10: Show the Updated Study Progress Analytics (45 seconds)
1. Tap the **Progress** tab in the Bottom Navigation Bar.
2. Point out:
   - The large **Circular Radial Gauge** displaying the updated completion percentage.
   - The **Dynamic Performance Banner** evaluating current student productivity.
   - The **Assignment Submission Ratio** progress bar.
   - The **Weekly Class Load** and **Nearest Exam Countdown**.
   - Emphasize to the teacher that every number is calculated live from the SQLite database!

---

### Step 11: Explain the SQLite Database & Architecture (1 minute)
> *"Under the hood, all information is stored locally in `smart_student_planner.db` using the `sqflite` package. We have four relational tables: `tasks`, `timetable`, `assignments`, and `exams`. We use parameterized queries to prevent SQL injection, and all operations execute asynchronously without blocking the UI thread."*

---

### Step 12: Demonstrate Persistent Offline Storage (App Restart) (30 seconds)
1. Minimize and completely close the application (swipe it away from recent apps).
2. Relaunch the app.
3. Show that:
   - The student name is preserved.
   - All tasks, classes, assignments, and exams remain saved.
   - The dashboard statistics are intact.
> *"This confirms that the application has zero cloud dependency and guarantees 100% offline persistence."*

---

### Conclusion (15 seconds)
> *"This concludes my demonstration of the Smart Student Planner. Thank you, and I am now ready to answer any questions."*

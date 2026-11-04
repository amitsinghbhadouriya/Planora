import 'package:flutter_test/flutter_test.dart';
import 'package:smart_student_planner/main.dart';
import 'package:smart_student_planner/widgets/custom_bottom_nav.dart';

void main() {
  testWidgets('SmartStudentPlannerApp smoke test and navigation verification',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const SmartStudentPlannerApp(initialDarkMode: false));

    // Verify that the title appears
    expect(find.text('Smart Student Planner'), findsOneWidget);

    // Verify that the custom bottom navigation bar renders
    expect(find.byType(CustomBottomNav), findsOneWidget);

    // Verify that primary navigation labels exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Timetable'), findsOneWidget);
    expect(find.text('Assignments'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
  });
}


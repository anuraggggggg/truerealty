import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truerealtycrm/screen/telecaller_dashboard_screen.dart';

void main() {
  testWidgets('Telecaller dashboard screen renders all metric cards and badges correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(428, 926),
        builder: (context, child) => const MaterialApp(
          home: TelecallerDashboardScreen(),
        ),
      ),
    );

    // Verify Title and Subtitle in Header
    expect(find.text('Telecaller Dashboard'), findsOneWidget);
    expect(
      find.text("Welcome back, Telecaller Test. Here's your today's overview."),
      findsOneWidget,
    );

    // Verify key metric card titles are present
    expect(find.text('TOTAL ASSIGNED\nLEADS'), findsOneWidget);
    expect(find.text('NEW LEADS'), findsOneWidget);
    expect(find.text("TODAY'S\nFOLLOWUPS"), findsOneWidget);
    expect(find.text('MISSED\nFOLLOW-UPS'), findsOneWidget);
    expect(find.text('HOT LEADS'), findsOneWidget);
    expect(find.text('COLD LEADS'), findsOneWidget);
    expect(find.text('INTERESTED LEADS'), findsOneWidget);
    expect(find.text('NOT INTERESTED'), findsOneWidget);
    expect(find.text('SITE VISIT SCHEDULED'), findsOneWidget);

    // Verify parsed Converted Leads multi-line title elements
    expect(find.text('CONVERTED\nLEADS'), findsOneWidget);

    // Verify badge labels
    expect(find.text('Today'), findsNWidgets(3)); // New Leads ("Today"), Today's Followups ("Today"), and Daily Calling Trend ("Today")
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('This Month'), findsOneWidget);

    // Verify some metrics values
    expect(find.text('05'), findsNWidgets(4)); // Total Assigned (05), Missed Followups (05), Interested Leads (05), and one more somewhere else.
    expect(find.text('00'), findsNWidgets(16)); // Remaining cards have '00'
  });

  testWidgets('Telecaller dashboard screen renders Site Visits section', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(428, 926),
        builder: (context, child) => const MaterialApp(
          home: TelecallerDashboardScreen(),
        ),
      ),
    );

    expect(find.text('Site Visits'), findsOneWidget);
    expect(find.text('Aniket Singh'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);
    expect(find.text('View All ›'), findsOneWidget);
  });
}

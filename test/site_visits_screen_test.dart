
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truerealtycrm/screen/site_visits_screen.dart';

void main() {
  testWidgets('SiteVisitDetailsScreen renders without overflow', (WidgetTester tester) async {
    // Build the app with a specific size to simulate a device that might cause overflow
    await tester.binding.setSurfaceSize(const Size(320, 600));
    await tester.pumpWidget(const MaterialApp(home: SiteVisitDetailsScreen()));

    // Verify it doesn't throw any errors
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/screen/leads_screen.dart';

void main() {
  testWidgets('Leads screen header renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(428, 926),
        builder: (context, child) => ChangeNotifierProvider(
          create: (_) => LeadProvider(),
          child: const MaterialApp(
            home: LeadListWidget(),
          ),
        ),
      ),
    );

    expect(find.text('Lead List'), findsNWidgets(2));
    expect(find.text('Add Lead'), findsOneWidget);
  });
}

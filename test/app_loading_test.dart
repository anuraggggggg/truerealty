import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truerealtycrm/widget/app_loading.dart';

void main() {
  testWidgets('list skeleton fits a 320dp mobile viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: AppListSkeleton(itemCount: 3, itemHeight: 132),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppSkeleton), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('skeleton supports reduced motion', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: AppSkeleton(height: 100),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}

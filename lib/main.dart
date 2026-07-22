import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/dashboard_provider.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/provider/tasks_provider.dart';
import 'package:truerealtycrm/provider/reports_provider.dart';
import 'package:truerealtycrm/provider/site_visits_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truerealtycrm/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LeadProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => SiteVisitProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(428, 926),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final baseIconSize = 22.sp;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TrueRoot Realty CRM',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),
              textTheme: GoogleFonts.interTextTheme(),
              iconTheme: IconThemeData(size: baseIconSize),
              primaryIconTheme: IconThemeData(size: baseIconSize),
              appBarTheme: AppBarTheme(
                iconTheme: IconThemeData(size: baseIconSize),
                actionsIconTheme: IconThemeData(size: baseIconSize),
              ),
              iconButtonTheme: IconButtonThemeData(
                style: IconButton.styleFrom(
                  iconSize: baseIconSize,
                ),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedIconTheme: IconThemeData(size: baseIconSize),
                unselectedIconTheme: IconThemeData(size: baseIconSize - 1),
              ),
              useMaterial3: true,
            ),
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppRouter.login,
          );
        },
      ),
    );
  }
}


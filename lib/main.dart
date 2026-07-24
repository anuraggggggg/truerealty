import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/dashboard_provider.dart';
import 'package:truerealtycrm/provider/access_control_provider.dart';
import 'package:truerealtycrm/provider/attendance_provider.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/auto_assignment_provider.dart';
import 'package:truerealtycrm/provider/contact_lead_provider.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/provider/integration_provider.dart';
import 'package:truerealtycrm/provider/lead_master_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/provider/notification_provider.dart';
import 'package:truerealtycrm/provider/payroll_provider.dart';
import 'package:truerealtycrm/provider/project_provider.dart';
import 'package:truerealtycrm/provider/tasks_provider.dart';
import 'package:truerealtycrm/provider/reports_provider.dart';
import 'package:truerealtycrm/provider/site_visits_provider.dart';
import 'package:truerealtycrm/provider/system_provider.dart';
import 'package:truerealtycrm/provider/upload_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'package:truerealtycrm/screen/dashboard_screen.dart';
import 'package:truerealtycrm/screen/login_screen.dart';

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
        ChangeNotifierProvider(create: (_) => SystemProvider()),
        ChangeNotifierProvider(create: (_) => AccessControlProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => PayrollProvider()),
        ChangeNotifierProvider(create: (_) => LeadProvider()),
        ChangeNotifierProvider(create: (_) => ContactLeadProvider()),
        ChangeNotifierProvider(create: (_) => LeadMasterProvider()),
        ChangeNotifierProvider(create: (_) => AutoAssignmentProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProvider(create: (_) => IntegrationProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SiteVisitProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider()),
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
                style: IconButton.styleFrom(iconSize: baseIconSize),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedIconTheme: IconThemeData(size: baseIconSize),
                unselectedIconTheme: IconThemeData(size: baseIconSize - 1),
              ),
              useMaterial3: true,
            ),
            onGenerateRoute: AppRouter.generateRoute,
            home: const _SessionGate(),
          );
        },
      ),
    );
  }
}

class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  Future<void>? _loadSession;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSession ??= context.read<AuthProvider>().loadSavedSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadSession,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return context.watch<AuthProvider>().isAuthenticated
            ? const DashboardScreen()
            : const LoginScreen();
      },
    );
  }
}
